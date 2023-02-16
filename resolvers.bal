import ballerina/graphql;

// Functions to fetch data from all subgraphs
// Each function represent a Query type defined in the subgraph sdl
// Query strings are declared according to the types generated in `types.bal`

class Resolvers {

    // client objects to connect with subgraphs
    final graphql:Client astronaut_client;
    final graphql:Client mission_client;

    public function init() returns error? {
        self.astronaut_client = check new ("http://localhost:4001");
        self.mission_client = check new ("http://localhost:4002");
    }

    public function astronaut(string id) returns AstronautSubgraph|error {
        string query = string `query {
            astronaut(id: ${id}){
                id
                name
            }
        }`;

        AstronautSubgraphResponse response = check self.astronaut_client->executeWithType(query);
        return response.data.astronaut;
    }

    public function astronauts() returns AstronautSubgraph[]|error {
        string query = string `query {
            astronauts{
                id
                name
            }
        }`;

        AstronautsSubgraphResponse response = check self.astronaut_client->executeWithType(query);
        return response.data.astronauts;
    }

    public function mission(string id) returns MissionSubgraph|error {
        string query = string `query {
            mission(id: ${id}){
                id
                crew {
                    id
                }
                designation
                startDate
                endDate
            }
        }`;

        MissionSubgraphResponse response = check self.mission_client->executeWithType(query);
        return response.data.mission;
    }

    public function missions() returns MissionSubgraph[]|error {
        string query = string `query {
            missions{
                id
                crew {
                    id
                }
                designation
                startDate
                endDate
            }
        }`;

        MissionsSubgraphResponse response = check self.mission_client->executeWithType(query);
        return response.data.missions;
    }
}
