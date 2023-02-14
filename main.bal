import ballerina/graphql;

public type Mission record {|
    int id;
    int[] crew;
    string designation;
    string startDate;
    string endDate;
|};

public type Astronaut record {|
    int id;
    string name;
|};

service on new graphql:Listener(9000) {

    final graphql:Client astronaut_client;
    final graphql:Client mission_client;

    function init() returns error? {
        self.astronaut_client = check new ("http://localhost:4001");
        self.mission_client = check new ("http://localhost:4002");
    }

    resource function get astronaut(int id) returns Astronaut|error {
        Astronaut astronaut = check self.astronaut(id);
        return astronaut;
    }

    private function astronaut(int id) returns Astronaut|error {
        string query = string `query {
            astronaut(id: ${id}){
                id
                name
            }
        }`;

        Astronaut astronaut = check self.astronaut_client->executeWithType(query);
        return astronaut;
    }

    private function missions() returns Mission[]|error {
        string query = string `query {
            missions{
                id
                crew
                designation
                startDate
                endDate
            }
        }`;

        Mission[] missions = check self.mission_client->executeWithType(query);
        return missions;
    }
}
