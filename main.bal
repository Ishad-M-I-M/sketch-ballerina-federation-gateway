import ballerina/graphql;

service on new graphql:Listener(9000) {

    final Client resolvers;
    function init() returns error? {
        self.resolvers = check new;
    }

    resource function get astronaut(int id) returns Astronaut|error {
        AstronautSubgraph astronaut_ = check self.resolvers->astronaut(id.toString());
        return new Astronaut(self.resolvers, astronaut_.id, astronaut_.name);
    }

    resource function get astronauts() returns Astronaut[]|error {
        AstronautSubgraph[] astronauts = check self.resolvers->astronauts();
        return astronauts.map(function(AstronautSubgraph astronaut) returns Astronaut {
            return new Astronaut(self.resolvers, astronaut.id, astronaut.name);
        });
    }

    resource function get mission(int id) returns Mission|error {
        MissionSubgraph mission = check self.resolvers->mission(id.toString());
        return new Mission(self.resolvers, mission.id, mission.designation, mission.startDate, mission.endDate);
    }

    resource function get missions() returns Mission[]|error {
        MissionSubgraph[] missions = check self.resolvers->missions();
        return missions.map(function(MissionSubgraph mission) returns Mission {
            return new Mission(self.resolvers, mission.id, mission.designation, mission.startDate, mission.endDate);
        });
    }

}
