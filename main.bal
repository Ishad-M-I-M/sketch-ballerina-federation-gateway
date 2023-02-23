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
        return new Astronaut('field.getQueryDocument(), self.clients, id);
    }

    // resource function get astronauts() returns Astronaut[]|error {
    //     AstronautSubgraph[] astronauts = check self.'client->astronauts();
    //     return astronauts.map(function(AstronautSubgraph astronaut) returns Astronaut {
    //         return new Astronaut(self.'client, astronaut.id, astronaut.name);
    //     });
    // }

    // resource function get mission(int id) returns Mission|error {
    //     MissionSubgraph mission = check self.'client->mission(id.toString());
    //     return new Mission(self.'client, mission.id, mission.designation, mission?.startDate, mission?.endDate);
    // }

    // resource function get missions() returns Mission[]|error {
    //     MissionSubgraph[] missions = check self.'client->missions();
    //     return missions.map(function(MissionSubgraph mission) returns Mission {
    //         return new Mission(self.'client, mission.id, mission.designation, mission?.startDate, mission?.endDate);
    //     });
    // }

}
