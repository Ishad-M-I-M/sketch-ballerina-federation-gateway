import ballerina/graphql;

public type Mission record {|
    string id;
    string[] crew;
    string designation;
    string? startDate;
    string? endDate;
|};

public type Astronaut record {|
    string id;
    string name;
|};

type AstronautResponse record {
    record {|Astronaut astronaut;|} data;
};

type AstronautsResponse record {
    record {|Astronaut[] astronauts;|} data;
};

type MissionResponse record {
    record {|Mission mission;|} data;
};

type MissionsResponse record {
    record {|Mission[] missions;|} data;
};

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

    resource function get astronauts() returns Astronaut[]|error {
        Astronaut[] astronauts = check self.astronauts();
        return astronauts;
    }

    resource function get mission(int id) returns Mission|error {
        Mission mission = check self.mission(id);
        return mission;
    }

    resource function get missions() returns Mission[]|error {
        Mission[] missions = check self.missions();
        return missions;
    }

    private function astronaut(int id) returns Astronaut|error {
        string query = string `query {
            astronaut(id: ${id}){
                id
                name
            }
        }`;

        AstronautResponse response = check self.astronaut_client->executeWithType(query);
        return response.data.astronaut;
    }

    private function astronauts() returns Astronaut[]|error {
        string query = string `query {
            astronauts{
                id
                name
            }
        }`;

        AstronautsResponse response = check self.astronaut_client->executeWithType(query);
        return response.data.astronauts;
    }

    private function mission(int id) returns Mission|error {
        string query = string `query {
            mission(id: ${id}){
                id
                crew
                designation
                startDate
                endDate
            }
        }`;

        MissionResponse response = check self.mission_client->executeWithType(query);
        return response.data.mission;
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

        MissionsResponse response = check self.mission_client->executeWithType(query);
        return response.data.missions;
    }
}
