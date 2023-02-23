import ballerina/graphql;
import ballerina/io;

public service class Mission {

    map<string> fieldMap = {
        "id": "missions",
        "designation": "missions",
        "startDate": "missions",
        "endDate": "missions",
        "crew": "missions"
    };

    private string id;
    private string? designation = ();
    private string? startDate = ();
    private string? endDate = ();
    private Astronaut[]? crew = ();

    function init(map<graphql:fieldDocument> fields, map<graphql:Client> clients, MissionRecord fetchedFields) returns error? {

        // Assigning the already fetched fields
        // For the key field
        io:println("\n\n[DEBUG - MISSION] Fetched Fields :\n", fetchedFields);
        if (fetchedFields.id is ()) {
            panic error("ID is required");
        }
        else {
            self.id = <string>fetchedFields.id;
            _ = fields.remove("id");
        }

        // For the rest fields
        if !(fetchedFields.designation is ()) {
            self.designation = fetchedFields.designation;
            _ = fields.remove("designation");
        }

        if !(fetchedFields?.startDate is ()) {
            self.startDate = fetchedFields?.startDate;
            _ = fields.remove("startDate");
        }

        if !(fetchedFields?.endDate is ()) {
            self.endDate = fetchedFields?.endDate;
            _ = fields.remove("endDate");
        }

        if !(fetchedFields.crew is ()) {
            map<graphql:fieldDocument> crewFields = <map<graphql:fieldDocument>>fields["crew"];
            self.crew = (<AstronautRecord[]>fetchedFields.crew).map(
                    function(AstronautRecord astronaut) returns Astronaut {
                Astronaut|error _astronaut = new (crewFields, clients, astronaut);
                if (_astronaut is Astronaut) {
                    return _astronaut;
                }
                else {
                    panic error("Error while creating the astronaut");
                }
            }
                );
            _ = fields.remove("crew");
        }

        // Resolving the fields which are requested and not fetched yet.
        io:println("\n\n[DEBUG - MISSION] Remaining Fields to fetch :\n", fields);

        map<string[]> resolve = {};
        foreach var 'field in fields.keys() {
            resolve[self.fieldMap.get('field)] = (resolve[self.fieldMap.get('field)] is ()) ? ['field] : [...<string[]>resolve[self.fieldMap.get('field)], 'field];
        }

        io:println("\n\n[DEBUG - MISSION] Cients resolving the fields :\n", resolve);

        foreach var [key, value] in resolve.entries() {
            if (key == "missions") {
                graphql:Client? 'client = clients[key];
                if ('client is ()) {
                    panic error("Client not found for the service");
                }
                string query = string `query {
                        mission(id: ${self.id}) {
                            ${buildQueryString(filterFields(value, fields))}
                        }
                    }`;

                io:println("\n\n[DEBUG - MISSION] Query to fetch from the missions subgraph:\n", query);

                MissionRecordResponse response = check 'client->execute(query);
                MissionRecord result = response.data.mission;

                // Assigning the fetched fields
                if !(result.designation is ()) {
                    self.designation = result.designation;
                }

                if !(result?.startDate is ()) {
                    self.startDate = result?.startDate;
                }

                if !(result?.endDate is ()) {
                    self.endDate = result?.endDate;
                }

                if !(result.crew is ()) {
                    map<graphql:fieldDocument> crewFields = <map<graphql:fieldDocument>>fields["crew"];
                    self.crew = (<AstronautRecord[]>result.crew).map(
                    function(AstronautRecord astronaut) returns Astronaut {
                        Astronaut|error _astronaut = new (crewFields, clients, astronaut);
                        if (_astronaut is Astronaut) {
                            return _astronaut;
                        }
                        else {
                            panic error("Error while creating the astronaut");
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

    resource function get designation() returns string? {
        return self.designation;
    }

    resource function get startDate() returns string? {
        return self.startDate;
    }

    resource function get endDate() returns string? {
        return self.endDate;
    }

    resource function get crew() returns Astronaut[]? {
        return self.crew;
    }
}
