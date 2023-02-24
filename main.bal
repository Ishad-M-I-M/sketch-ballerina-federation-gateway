import ballerina/io;
import ballerina/graphql;

service on new graphql:Listener(9000) {

    map<graphql:Client> clients = {};

    function init() returns error? {
        self.clients = {
            "astronauts": check new graphql:Client("http://localhost:4001"),
            "missions": check new graphql:Client("http://localhost:4002")
        };
    }

    resource function get astronaut(graphql:Field 'field, int id) returns Astronaut|error {

    }

    resource function get astronauts(graphql:Field 'field) returns Astronaut[]|error {

    }

    resource function get mission(graphql:Field 'field, int id) returns Mission|error {

    }

    resource function get missions(graphql:Field 'field) returns Mission[]|error {
        // "id", "designation", "startDate", "endDate", "crew" - solved directly from the `missions` client.
        // "crew"."name" - resolved from the `astronauts` client using _entities query.
    }

    private function resolveAstronaut(map<graphql:fieldDocument> 'field, int id) returns Astronaut|error {
        // "id", "name" - solved directly from the `astronauts` client.
        // "missions" - resolved from the `missions` client using `_entities` query.

        // What if requested:
        // query{
        //     astronaut(id: ${id}){
        //         id
        //         name
        //         missions{
        //             id
        //             designation
        //             startDate
        //             endDate
        //             crew{
        //                 name
        //                 missions{
        //                      designation
        //                 }
        //             }
        //         }
        //     }
        // }

        // request to `astronauts` client:
        // path: []
        // query {
        //     astronaut(id: ${id}){
        //         id
        //         name
        //     }
        // }

        // request to `missions` client:
        // path: ["astronaut"]
        // query{
        //     _entities(representations: [
        //         {
        //             __typename: "Astronaut"
        //            "id": ${id}
        //         }
        //     ]){
        //         ... on Astronaut{
        //             missions{
        //                 id
        //                 designation
        //                 startDate
        //                 endDate
        //                 crew{
        //                     id                 <-- need to fetch even not requested.
        //                     missions{
        //                         designation  
        //                      }
        //                 }
        //             }
        //         }
        //     }
        // }

        // How to resolve `name` of `crew`?.
        // Parse through the 'field document while assigning the fetched values. Fetch and assign the fields that are null.

    }

}
