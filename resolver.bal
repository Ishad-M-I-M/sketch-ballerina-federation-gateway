import ballerina/graphql;

public class Resolver {

    // map of clients objects.
    private map<graphql:Client> clients;

    private unResolvableField[] toBeResolved;

    // The final result of the resolver. Created an composed while resolving by `resolve()`.
    private Union|Union[] result;

    private string[] currentPath;

    public function init(map<graphql:Client> clients, Union|Union[] result, unResolvableField[] unResolvableFields, string[] currentPath) {
        self.clients = clients;
        self.result = result;
        self.toBeResolved = unResolvableFields;
        self.currentPath = currentPath;
    }

    public isolated function resolve() returns Union|Union[]|error {
        // Resolve the fields that are not resolvable.
        foreach var 'record in self.toBeResolved {
            // field resolving client.
            string clientName = queryPlan.get('record.parent).fields.get('record.'field.getName()).'client;

            graphql:Client 'client = self.clients.get(clientName);

            if 'record.'field.getUnwrappedType().kind == "SCALAR" {
                string queryString = wrapWithEntityRepresentation('record.parent, [], 'record.'field.getName());
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
                    foreach var i in 0 ... (resultToCompose.length() - 1) {
                        _ = check self.compose(pointer[i], resultToCompose[i], pathCopy);
                    }
                    return;
                }
                else {
                    return error("Error: Cannot compose into the result.");
                }
            }
            else {
                pointer = (<map<json>>pointer)[element];
            }
            element = pathCopy.shift();
        }

        if pointer is map<json> && resultToCompose is map<json> {
            pointer[element] = resultToCompose[element];
        }
        else {
            return error("Error: Cannot compose into the result.");
        }
    }

    // Get the ids of the entities in the path from the current result.
    private isolated function getIdsInPath(string[] path) returns string[] {

        return [];
    }

}
