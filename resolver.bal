import ballerina/graphql;

public class Resolver {

    // map of clients objects.
    private map<graphql:Client> clients;

    private unResolvableField[] toBeResolved;

    // The final result of the resolver. Created an composed while resolving by `resolve()`.
    private Union|Union[] result;

    private string[] currentPath;

    public isolated function init(map<graphql:Client> clients, Union|Union[] result, unResolvableField[] unResolvableFields, string[] currentPath) {
        self.clients = clients;
        self.result = result;
        self.toBeResolved = unResolvableFields;
        self.currentPath = currentPath;
    }

    public isolated function resolve() returns Union|Union[]|error {
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

                string key = queryPlan.get('record.parent).key;
                string[] ids = check self.getIdsInPath(self.result, path, 'record.parent);

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
                        Resolver resolver = new (self.clients, self.result, propertiesNotResolved, convertPathToString('record.'field.getPath()));
                        var result = check resolver.resolve();
                        self.result = check resolver.resolve().ensureType();
                    }

                }

            }
            else {
                // Cannot resolve directly and compose.
                // Iterated through the self.result and resolve the fields util it falls for base condition.
                Union[] results = [];

                string[] path = self.getEffectivePath('record.'field);
                json pointer = self.result;

                string element = path.shift();
                while element != "@" {
                    pointer = (<map<json>>pointer)[element];
                    element = path.shift();
                }

                foreach var item in <Union[]>pointer {
                    Resolver resolver = new (self.clients, item, ['record], convertPathToString('record.'field.getPath()));
                    Union composedResult = check resolver.resolve().ensureType();
                    results.push(composedResult);
                }

                _ = check self.compose(self.result, results, self.getEffectivePath('record.'field));

            }

        }

        return self.result;
    }

    // helper functions.

    // Compose results to the final result. i.e. to the `result` object.
    private isolated function compose(json finalResult, json resultToCompose, string[] path) returns error? {
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
                pointer = (<map<json>>pointer)[element];
            }
            element = pathCopy.shift();
        }

        if pointer is map<json> && resultToCompose is map<json> {
            compose(pointer, resultToCompose, element);
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
            if pointer is Union {
                ids.push((<map<json>>pointer)[key].toString());
            }
            else if pointer is Union[] {
                foreach var element in pointer {
                    ids.push((<map<json>>element)[key].toString());
                }
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
