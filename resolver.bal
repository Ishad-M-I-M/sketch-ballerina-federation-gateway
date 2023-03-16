import ballerina/graphql;

public class Resolver {

    // map of clients objects.
    private map<graphql:Client> clients;

    private unResolvableField[] toBeResolved;

    // The final result of the resolver. Created an composed while resolving by `resolve()`.
    private json result;

    private string resultType;

    private string[] currentPath;

    public isolated function init(map<graphql:Client> clients, json result, string resultType, unResolvableField[] unResolvableFields, string[] currentPath) {
        self.clients = clients;
        self.result = result;
        self.resultType = resultType;
        self.toBeResolved = unResolvableFields;
        self.currentPath = currentPath; // Path upto the result fields.
    }

    public isolated function getResult() returns json|error {
        if self.toBeResolved.length() > 0 {
            check self.resolve();
        }
        return self.result;
    }

    isolated function resolve() returns error? {
        // Resolve the fields which are not resolved yet.
        while self.toBeResolved.length() > 0 {
            unResolvableField 'record = self.toBeResolved.shift();

            // Check whether the field need to be resolved is nested by zero or one level.
            // These can be resolved and composed directly to the result.
            if 'record.'field.getPath().slice(self.currentPath.length()).filter(e => e == "@").length() < 1 {

                string clientName = queryPlan.get('record.parent).fields.get('record.'field.getName()).'client;

                graphql:Client 'client = self.clients.get(clientName);

                // Get the ids from the current results to resolve by reference.
                string[] path = self.getEffectivePath('record.'field);

                path = path.slice(0, path.length() - 1);

                string[] ids = check self.getIdsInPath(self.result, path, self.resultType);

                string key = queryPlan.get('record.parent).key;

                if 'record.'field.getUnwrappedType().kind == "SCALAR" {
                    // If the field type is a scalar type, just pass the field name wrapped with entity representation.
                    string queryString = wrapWithEntityRepresentation('record.parent, key, ids, 'record.'field.getName());

                    EntityResponse result = check 'client->execute(queryString);

                    check self.compose(self.result, result.data._entities, self.getEffectivePath('record.'field));
                }
                else {
                    // Else need to classify the fields and resolve them accordingly.
                    QueryFieldClassifier classifier = new ('record.'field, clientName);

                    string fieldString = classifier.getFieldStringWithRoot();

                    string queryString = wrapWithEntityRepresentation('record.parent, key, ids, fieldString);

                    EntityResponse response = check 'client->execute(queryString);

                    check self.compose(self.result, response.data._entities, self.getEffectivePath('record.'field));

                    unResolvableField[] propertiesNotResolved = classifier.getUnresolvableFields();

                    if (propertiesNotResolved.length() > 0) {
                        Resolver resolver = new (self.clients, self.result, self.resultType, propertiesNotResolved, self.currentPath);
                        check resolver.resolve();
                    }

                }

            }
            else {
                // Cannot resolve directly and compose.
                // Iterated through the self.result and resolve the fields by recursively calling the `resolve()` function 
                // while updating the path.

                string[] currentPath = self.currentPath.clone();
                json pointer = self.result;
                string pointerType = self.resultType;

                string[] path = self.getEffectivePath('record.'field);
                string element = path.shift();
                currentPath.push(element);

                // update the pointer and related information till it finds a @ element.
                while element != "@" {
                    pointer = (<map<json>>pointer).get(element);
                    pointerType = queryPlan.get(pointerType).fields.get(element).'type;
                    element = path.shift();
                    currentPath.push(element);
                }

                // Iterate over the list in current pointer and compose the results into the inner fields.
                if pointer is json[] {
                    foreach var i in 0 ..< pointer.length() {
                        Resolver resolver = new (self.clients, pointer[i], pointerType, ['record], currentPath);
                        check resolver.resolve();
                    }
                }
                else {
                    return error("Error: Cannot resolve the field.");
                }

            }

        }
    }

    // helper functions.

    // Compose results to the final result. i.e. to the `result` object.
    isolated function compose(json finalResult, json resultToCompose, string[] path) returns error? {
        string[] pathCopy = path.clone();
        json pointer = finalResult;
        string element = pathCopy.shift();

        while (pathCopy.length() > 0) {
            if element == "@" {
                if resultToCompose is json[] && pointer is json[] {
                    foreach var i in 0 ..< resultToCompose.length() {
                        check self.compose(pointer[i], resultToCompose[i], pathCopy);
                    }
                    return;
                }
                else {
                    // Ideally should not be thrown
                    return error("Error: Cannot compose into the result.");
                }
            }
            else {
                if pointer is map<json> {
                    if (pointer.hasKey(element)) {
                        pointer = pointer.get(element);
                    }
                    else {
                        return error(element.toString() + " is not found in pointer :" + pointer.toString());
                    }
                }
                else {
                    // Ideally should not be thrown
                    return error("Error: Cannot compose into the result.");
                }

            }
            element = pathCopy.shift();
        }

        if pointer is map<json> {
            if resultToCompose is map<json> {
                compose(pointer, resultToCompose, element);
            }
            else if resultToCompose is json[] {
                compose(pointer, <map<json>>resultToCompose[0], element);
            }
            else {
                // Ideally should not be thrown
                return error("Error: Cannot compose into the result.");
            }

        }
        else {
            // Ideally should not be thrown
            return error("Error: Cannot compose into the result.");
        }
    }

    // Get the ids of the entities in the path from the current result.
    // The path should contain upto a '@' element if it is an array. ( should not include @ in the path).
    isolated function getIdsInPath(json pointer, string[] path, string parentType) returns string[]|error {

        if path.length() == 0 {
            string key = queryPlan.get(parentType).key;
            string[] ids = [];
            if pointer is json[] {
                foreach var element in pointer {
                    ids.push((<map<json>>element)[key].toString());
                }
            }
            else if pointer is map<json> {
                ids.push(pointer[key].toString());
            }
            else {
                return error("Error: Cannot get ids from the result.");
            }

            return ids;
        }

        string element = path.shift();
        json newPointer = (<map<json>>pointer)[element];
        string fieldType = queryPlan.get(parentType).fields.get(element).'type;

        return self.getIdsInPath(newPointer, path, fieldType);

    }

    private isolated function getEffectivePath(graphql:Field 'field) returns string[] {
        return convertPathToStringArray('field.getPath().slice(self.currentPath.length()));
    }

}
