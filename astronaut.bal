import ballerina/graphql;
import ballerina/io;

public service class Astronaut {
    // map to keep track of the fields along with the resolving subgraph
    map<string> fieldMap = {
        "id": "astronauts",
        "name": "astronauts",
        "missions": "missions"
    };
    private string id;
    private string? name = ();
    private Mission[]? missions = ();

    function init(map<graphql:fieldDocument> fields, map<graphql:Client> clients, AstronautRecord fetchedFields) returns error? {

        // Assigning the already fetched fields
        // For the key field
        io:println("\n\n[DEBUG - ASTRONAUT] Fetched Fields :\n", fetchedFields);
        if (fetchedFields.id is ()) {
            panic error("ID is required");
        }
        else {
            self.id = <string>fetchedFields.id;
            _ = fields.remove("id");
        }

        // For the rest fields
        if !(fields.keys().indexOf("name") is () && fetchedFields.name is ()) {
            self.name = fetchedFields.name;
            _ = fields.remove("name");
        }

        if !(fields.keys().indexOf("missions") is () && fetchedFields.missions is ()) {
            map<graphql:fieldDocument> missionsFields = <map<graphql:fieldDocument>>fields["missions"];
            self.missions = (<MissionRecord[]>fetchedFields.missions).map(
                function(MissionRecord mission) returns Mission {
                Mission|error _mission = new (missionsFields, clients, mission);
                if (_mission is Mission) {
                    return _mission;
                }
                else {
                    panic error("Error while creating the mission");
                }
            }
            );
            _ = fields.remove("missions");
        }

        // Resolving the fields which are requested and not fetched yet.
        io:println("\n\n[DEBUG - ASTRONAUT] Remaining Fields to fetch :\n", fields);

        map<string[]> resolve = {};
        foreach var 'field in fields.keys() {
            resolve[self.fieldMap.get('field)] = (resolve[self.fieldMap.get('field)] is ()) ? ['field] : [...<string[]>resolve[self.fieldMap.get('field)], 'field];
        }

        io:println("\n\n[DEBUG - ASTRONAUT] Cients resolving the fields :\n", resolve);

        foreach var [key, value] in resolve.entries() {
            if (key == "astronauts") {
                graphql:Client? 'client = clients[key];
                if ('client is ()) {
                    panic error("Client not found for the service");
                }
                string query = string `query {
                    astronaut(id: ${self.id}) {
                        ${buildQueryString(filterFields(value, fields))}
                    }
                }`;

                io:println("\n\n[DEBUG - ASTRONAUT] Query to fetch from the astronuts subgraph:\n", query);

                AstronautRecordResponse response = check 'client->execute(query);
                AstronautRecord result = response.data.astronaut;

                // Assigning the fetched fields
                if !(fields.keys().indexOf("name") is () && result.name is ()) {
                    self.name = result.name;
                }

            }
            else if (key == "missions") {
                graphql:Client? 'client = clients[key];
                if ('client is ()) {
                    panic error("Client not found for the service");
                }

                string query = string `query {
                    _entities(representations:[
                    {
                        __typename: "Astronaut"
                        id: ${self.id}
                    }    
                    ]){
                        ... on Astronaut{
                            ${buildQueryString(filterFields(value, fields))}
                        }
                    }
                }`;
                io:print("\n\n[DEBUG - ASTRONAUT] qury to fetch missions:\n", query);
                EntityAstronautResponse response = check 'client->execute(query);
                AstronautRecord result = <AstronautRecord>response.data._entities[0];

                if !(fields.keys().indexOf("missions") is () && result.missions is ()) {
                    map<graphql:fieldDocument> missionsFields = <map<graphql:fieldDocument>>fields["missions"];
                    self.missions = (<MissionRecord[]>result.missions).map(
                        function(MissionRecord mission) returns Mission {
                        Mission|error _mission = new (missionsFields, clients, mission);
                        if (_mission is Mission) {
                            return _mission;
                        }
                        else {
                            panic error("Error while creating the mission");
                        }
                    }
                    );
                }

            }
        }

    }

    resource function get id() returns string {
        return self.id;
    }

    resource function get name() returns string? {
        return self.name;
    }

    resource function get missions() returns Mission[]? {
        return self.missions;
    }

}
