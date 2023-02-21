import ballerina/graphql;

service on new graphql:Listener(9000) {

    final Client 'client;
    function init() returns error? {
        self.'client = check new;
    }

    resource function get astronaut(int id) returns Astronaut|error {
        AstronautSubgraph astronaut_ = check self.'client->astronaut(id.toString());
        return new Astronaut(self.'client, astronaut_.id, astronaut_.name);
    }

    resource function get astronauts() returns Astronaut[]|error {
        AstronautSubgraph[] astronauts = check self.'client->astronauts();
        return astronauts.map(function(AstronautSubgraph astronaut) returns Astronaut {
            return new Astronaut(self.'client, astronaut.id, astronaut.name);
        });
    }

    resource function get mission(int id) returns Mission|error {
        MissionSubgraph mission = check self.'client->mission(id.toString());
        return new Mission(self.'client, mission.id, mission.designation, mission.startDate, mission.endDate);
    }

    resource function get missions() returns Mission[]|error {
        MissionSubgraph[] missions = check self.'client->missions();
        return missions.map(function(MissionSubgraph mission) returns Mission {
            return new Mission(self.'client, mission.id, mission.designation, mission.startDate, mission.endDate);
        });
    }

}
