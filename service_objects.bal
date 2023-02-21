
// Service objects are generated for all type definitions in the supergraph sdl.
// All objects will have a resolver object as a field and will be used to resolve the nested looping fields. 

service class Mission {
    private Client 'client;
    private string id;
    private string designation;
    private string? startDate;
    private string? endDate;

    public function init(Client 'client, string id, string designation, string? startDate, string? endDate) {
        self.'client = 'client;
        self.id = id;
        self.designation = designation;
        self.startDate = startDate;
        self.endDate = endDate;
    }

    resource function get id() returns string {
        return self.id;
    }

    resource function get designation() returns string {
        return self.designation;
    }

    resource function get startDate() returns string? {
        return self.startDate;
    }

    resource function get endDate() returns string? {
        return self.endDate;
    }

    resource function get crew() returns Astronaut[]|error {

        // TODO: Generalize this logic

        AstronautSubgraph[] astronauts = check self.'client->astronauts();
        MissionSubgraph mission = check self.'client->mission(self.id);
        return astronauts.filter(function(AstronautSubgraph astronaut) returns boolean {
            return !(mission.crew.map(function(MissionSubgraphAstronaut astronaut_) returns string {
                return astronaut_.id;
            }).indexOf(astronaut.id) is ());
        }).map(function(AstronautSubgraph astronaut) returns Astronaut {
            return new (self.'client, astronaut.id, astronaut.name);
        });
    }
}

service class Astronaut {
    private Client 'client;
    private string id;
    private string name;

    public function init(Client 'client, string id, string name) {
        self.'client = 'client;
        self.id = id;
        self.name = name;
    }

    resource function get id() returns string {
        return self.id;
    }

    resource function get name() returns string {
        return self.name;
    }

    resource function get missions() returns Mission[]|error {

        // TODO: Generalize this logic

        MissionSubgraph[] missions = check self.'client->missions();
        return missions.filter(function(MissionSubgraph mission) returns boolean {
            return !(mission.crew.map(function(MissionSubgraphAstronaut astronaut) returns string {
                return astronaut.id;
            }).indexOf(self.id) is ());
        }).map(function(MissionSubgraph mission) returns Mission {
            return new (self.'client, mission.id, mission.designation, mission.startDate, mission.endDate);
        });
    }
}
