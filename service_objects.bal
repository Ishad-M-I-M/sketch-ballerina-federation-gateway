import ballerina/graphql;
import ballerina/io;

public function filterFields(string[] keys, map<graphql:fieldDocument> fields) returns map<graphql:fieldDocument> {
    map<graphql:fieldDocument> queryField = {};
    foreach var key in keys {
        queryField[key] = fields[key];
    }
    return queryField;
}

public function getFieldsToFetch(map<anydata> fetchedFields, map<graphql:fieldDocument> fields) returns string[] {
    string[] fieldsToFetch = [];
    foreach var [key, value] in fields.entries() {
        if (value is graphql:fieldDocument) {
            if !(fetchedFields.keys().indexOf(key) is ()) {
                fieldsToFetch.push(key);
            }
        }
    }
    return fieldsToFetch;
}

service class Astronaut {
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
        if !(fetchedFields.name is ()) {
            self.name = fetchedFields.name;
            _ = fields.remove("name");
        }

        if !(fetchedFields.missions is ()) {
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
                if !(result.name is ()) {
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

                if !(result.missions is ()) {
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

service class Mission {

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
