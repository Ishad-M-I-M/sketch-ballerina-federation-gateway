import ballerina/log;
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

    public isolated function resolve() returns json|error {
        // Resolve the fields that are not resolvable.

        foreach var 'record in self.toBeResolved {

            // Check whether the field need to be resolved is nested by zero or one level.
            // These can be resolved and composed directly to the result.
            if 'record.'field.getPath().slice(self.currentPath.length()).filter(e => e == "@").length() <= 1 {

                // field resolving client.
                string clientName = queryPlan.get('record.parent).fields.get('record.'field.getName()).'client;

                graphql:Client 'client = self.clients.get(clientName);

                string[] path = self.getEffectivePath('record.'field);

                int? index = path.indexOf("@");
                if !(index is ()) {
                    path = path.slice(0, index);
                }
                else {
                    path = path.slice(0, path.length() - 1);
                }

                string key = queryPlan.get('record.parent).key;
                string[] ids = check self.getIdsInPath(self.result, path, self.resultType);

                if 'record.'field.getUnwrappedType().kind == "SCALAR" {

                    string queryString = wrapWithEntityRepresentation('record.parent, key, ids, 'record.'field.getName());

                    EntityResponse result = check 'client->execute(queryString);

                    _ = check self.compose(self.result, result.data._entities, self.getEffectivePath('record.'field));
                }
                else {
                    QueryPropertyClassifier classifier = new ('record.'field, clientName);

                    string propertyString = classifier.getPropertyStringWithRoot();

                    string queryString = wrapWithEntityRepresentation('record.parent, key, ids, propertyString);

                    EntityResponse response = check 'client->execute(queryString);

                    _ = check self.compose(self.result, response.data._entities, self.getEffectivePath('record.'field));

                    unResolvableField[] propertiesNotResolved = classifier.getUnresolvableFields();

                    if (propertiesNotResolved.length() > 0) {
                        Resolver resolver = new (self.clients, self.result, self.resultType, propertiesNotResolved, self.currentPath);
                        _ = check resolver.resolve();
                    }

                }

            }
            else {
                // Cannot resolve directly and compose.
                // Iterated through the self.result and resolve the fields util it falls for base condition.

                string[] path = self.getEffectivePath('record.'field);
                string[] pathToCompose = [];
                json pointer = self.result;
                string pointerType = self.resultType;

                string element = path.shift();
                pathToCompose.push(element);

                while element != "@" {
                    pointer = (<map<json>>pointer)[element];
                    pointerType = queryPlan.get(pointerType).fields.get(element).'type;
                    element = path.shift();
                    pathToCompose.push(element);
                }

                string[] currentPath = self.currentPath.clone();
                currentPath.push(...pathToCompose);

                if pointer is json[] {
                    foreach var i in 0 ..< pointer.length() {
                        Resolver resolver = new (self.clients, pointer[i], pointerType, ['record], currentPath);
                        _ = check resolver.resolve();
                    }
                }
                else {
                    log:printDebug("Error: Cannot resolve the field as pointer :" + pointer.toString() + " is not an array.");
                }

            }

        }

        return self.result;
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
                        _ = check self.compose(pointer[i], resultToCompose[i], pathCopy);
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
                        log:printDebug(element.toString() + " is not found in pointer :" + pointer.toString());
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
    // The path should contain upto a '@' element.
    // Don't support '@' elements in the path.
    private isolated function getIdsInPath(json pointer, string[] path, string parentType) returns string[]|error {

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
        return 'field.getPath().slice(self.currentPath.length()).'map(
                        isolated function(string|int element) returns string {
            return element is int ? "@" : element;
        });
    }

}
