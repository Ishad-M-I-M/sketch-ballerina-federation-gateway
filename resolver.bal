import ballerina/graphql;

type RemovedRecords record {|
    graphql:Field[] fields; // updated map of fields.
    string[] path; // path to the field.
|};

type ModifiedField record {|
    graphql:Field[] fields; // updated map of fields.
    RemovedRecords[] removedRecords;
|};

type toBeResolveRecord record {|
    string parentType;
    graphql:Field 'field;
|};

public class Resolver {

    private toBeResolveRecord[] toBeResolved;
    private string[][] ids;
    private ResolvedRecord[] results;
    private map<graphql:Client> clients;

    function init(map<graphql:Client> clients) {
        self.clients = clients;
        self.toBeResolved = [];
        self.ids = [];
        self.results = [];
    }

    private function resolveReference(ResolveRecord 'record) returns Union|Union[]|error {
        // push the resolved results to `self.results` array.
        // if there's remaining fields to be resolved, push to `self.toBeResolved` array.
        graphql:Client 'client = self.clients.get('record.'client);

        if 'record.typename == "Astronaut" {

            if 'record.'client == "missions" {
                // Cannot resolve the `name` field of `crew`

            }
            else if 'record.'client == "astronauts" {
                // Cannot resolve the `missions`.

            }
            else {
                return error("Unknown client");
            }

        }
        else if 'record.typename == "Mission" {

        }
        else {
            return error("Unknown type");
        }

        return error("Not implemented");
    }

    private function checkForFieldsAndRemove(graphql:Field[] 'field, string[] fieldKey, string[] path) returns ModifiedField {
        // Go deepen into the record and remove the fields wich exactly matched the given path.
        // ex:
        // 'field = {
        // "missions": {
        //     "id": (),
        //     "crew": {
        //         "id": ()    
        //         "name": ()
        //         "missions": {
        //             "designation": ()
        //             "crew": {
        //                 "id": ()    
        //                 "name": ()
        //                      }
        //                  }
        //              }
        //          }
        //      } 

        // The above 'field object will be modified as below when this methods called as : checkForFieldsAndRemove('field, ["crew", "name"])
        // 'field = {
        // "missions": {
        //     "id": (),
        //     "crew": {
        //         "id": ()
        //         "missions": {
        //             "designation": ()
        //             "crew": {
        //                 "id": ()
        //                      }
        //                  }
        //              }
        //          }
        //      } 
        // 
        // AND will return the paths of the removed fields as below:
        // {
        //     fields: {"name" : ()},
        //     path: ["missions", "@", "crew"]
        // }
        // {
        //     fields: {"name" : ()},
        //     path: ["missions", "@", "crew", "missions", "@", "crew"]
        // }
        //
        // The `@` in the path indicates that the field is an array.

        return {
            fields: 'field,
            removedRecords: []
        };
    }

    public isolated function pushToResolve(graphql:Field 'field, string parentType) {
        self.toBeResolved.push({
            parentType: parentType,
            'field: 'field
        });
    }

    public isolated function pushToIds(string[] ids) {
        self.ids.push(ids);
    }

    public isolated function execute() returns ResolvedRecord[]|error {
        // iterate till the toBeResolved is empty.

        while self.toBeResolved.length() > 0 {
            toBeResolveRecord 'record = self.toBeResolved.pop();
            string[] ids = self.ids.pop();

            string clientName = queryPlan.get('record.parentType).fields.get('record.'field.getName()).'client;

            string propertyString = buildQueryString(['record.'field], 'record.parentType, clientName, self);

            string queryString = wrapWithEntityRepresentation('record.parentType, ids, propertyString);

            graphql:Client 'client = self.clients.get(clientName);

            if 'record.parentType == "Astronaut" {
                EntityAstronautResponse result = check 'client->execute(queryString);
                self.results.push({
                    typename: 'record.parentType,
                    path: 'record.'field.getPath().'map(n => n.toString()),
                    result: result.data._entities
                });
            }
            else if 'record.parentType == "Mission" {
                EntityMissionResponse result = check 'client->execute(queryString);
            }
            else {
                return error("Unknown type");
            }

        }

        return self.results;
    }

    // public function resolveAstronaut(graphql:Field[] 'field, int? id) returns Astronaut|Astronaut[]|error {
    //     graphql:fieldDocument fields = ();
    //     string[] ids = [];

    //     Astronaut|Astronaut[] resolvedResult;

    //     graphql:Client? 'client = self.clients["astronauts"];
    //     if 'client is () {
    //         return error("Client not found");
    //     }

    //     if !('field.keys().indexOf("missions") is ()) {
    //         fields = 'field.get("missions");
    //         _ = 'field.remove("missions");
    //     }

    //     if id is () {
    //         string query = wrapwithQuery("astronauts", buildQueryString('field));
    //         AstronautsResponse result = check 'client->execute(query);

    //         foreach Astronaut astronaut in result.data.astronauts {
    //             ids.push(astronaut.id.toString());
    //         }

    //         resolvedResult = result.data.astronauts;
    //     }
    //     else {
    //         string query = wrapwithQuery("astronaut", buildQueryString('field), {"id": id.toString()});
    //         AstronautResponse result = check 'client->execute(query);
    //         ids.push(id.toString());
    //         resolvedResult = result.data.astronaut;
    //     }

    //     if fields is () {
    //         return resolvedResult;
    //     }

    //     self.toBeResolved.push({
    //         path: [],
    //         ids: ids,
    //         fields: fields,
    //         typename: "Astronaut",
    //         'client: 'client
    //     });

    //     // "id", "name" - solved directly from the `astronauts` client.
    //     // "missions" - resolved from the `missions` client using `_entities` query.

    //     // What if requested:
    //     // query{
    //     //     astronaut(id: ${id}){
    //     //         id
    //     //         name
    //     //         missions{
    //     //             id
    //     //             designation
    //     //             startDate
    //     //             endDate
    //     //             crew{
    //     //                 name
    //     //                 missions{
    //     //                      designation
    //     //                 }
    //     //             }
    //     //         }
    //     //     }
    //     // }

    //     // request to `astronauts` client:
    //     // path: []
    //     // query {
    //     //     astronaut(id: ${id}){
    //     //         id
    //     //         name
    //     //     }
    //     // }

    //     // request to `missions` client:
    //     // path: ["astronaut"]
    //     // query{
    //     //     _entities(representations: [
    //     //         {
    //     //             __typename: "Astronaut"
    //     //            "id": ${id}
    //     //         }
    //     //     ]){
    //     //         ... on Astronaut{
    //     //             missions{
    //     //                 id
    //     //                 designation
    //     //                 startDate
    //     //                 endDate
    //     //                 crew{
    //     //                     id                 <-- need to fetch even not requested.
    //     //                     missions{
    //     //                         designation  
    //     //                      }
    //     //                 }
    //     //             }
    //     //         }
    //     //     }
    //     // }

    //     // How to resolve `name` of `crew`?.
    //     return error("Not implemented");

    // }

    // public function resolveMission(graphql:Field[] 'field, int id) returns Mission|error {
    //     // "id", "designation", "startDate", "endDate" - solved directly from the `missions` client.
    //     // "crew" - resolved from the `astronauts` client using `_entities` query.
    //     return error("Not implemented");
    // }

}
