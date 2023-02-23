import ballerina/graphql;
import ballerina/io;

public function filterFields(string[] keys, map<graphql:fieldDocument> fields) returns map<graphql:fieldDocument> {
    map<graphql:fieldDocument> queryField = {};
    foreach var key in keys {
        queryField[key] = fields[key];
    }
    return queryField;
}

service class Astronaut {

    // map to keep track of the fields along with the resolving subgraph
    map<string> fieldMap = {
        "id": "astronauts",
        "name": "astronauts",
        "missions": "missions"
    };
    private int id;
    private string? name;
    private MissionRecord[]? missions;

    function init(map<graphql:fieldDocument> fields, map<graphql:Client> clients, int id, string? name = (), MissionRecord[]? missions = ()) returns error? {
        self.id = id;
        self.name = name;
        self.missions = missions;

        io:println(fields);

        map<string[]> resolve = {};
        foreach var 'field in fields.keys() {
            resolve[self.fieldMap.get('field)] = (resolve[self.fieldMap.get('field)] is ()) ? ['field] : [...<string[]>resolve[self.fieldMap.get('field)], 'field];
        }

        io:println(resolve);

        foreach var [key, value] in resolve.entries() {
            if (key == "astronauts") {
                graphql:Client? 'client = clients[key];
                if ('client is ()) {
                    panic error("Client not found for the service");
                }
                DocumentBuilder query = new ("astronaut", filterFields(value, fields), {"id": self.id});

                io:println(query.getQueryString());

                AstronautRecordResponse response = check 'client->execute(query.getQueryString());
                self.name = response.data.astronaut.name;
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
                io:print(query);
                EntityAstronautResponse response = check 'client->execute(query);
                self.missions = response.data._entities[0].missions;

                MissionRecord[] missionRecords = [];

            }
        }

    }

    resource function get id() returns int {
        return self.id;
    }

    resource function get name() returns string? {
        return self.name;
    }

    resource function get missions() returns MissionRecord[]? {
        return self.missions;
    }

}

service class Mission {

    map<string> fieldMap = {
        "id": "missions",
        "designation": "missions",
        "startDate": "missions",
        "endDate": "missions",
        "crew": "astronauts"
    };

    private int id;
    private string? designation;
    private string? startDate;
    private string? endDate;
    private AstronautRecord[]? crew;

    function init(map<graphql:fieldDocument> fields, map<graphql:Client> clients, int id, string? designation = (), string? startDate = (), string? endDate = (), AstronautRecord[]? crew = ()) returns error? {
        self.id = id;
        self.designation = designation;
        self.startDate = startDate;
        self.endDate = endDate;
        self.crew = crew;

        map<string[]> resolve = {};
        foreach var 'field in fields.keys() {
            resolve[self.fieldMap.get('field)] = (resolve[self.fieldMap.get('field)] is ()) ? ['field] : [...<string[]>resolve[self.fieldMap.get('field)], 'field];
        }

        foreach var [key, value] in resolve.entries() {
            if (key == "astronauts") {
                graphql:Client? 'client = clients[key];
                if ('client is ()) {
                    panic error("Client not found for the service");
                }
                string query = string `query {
    _entities(representations:[]){
        ... on Astronaut{
            ${buildQueryString(filterFields(value, fields))}
        }
    }
                }`;
            }
            else if (key == "missions") {
                graphql:Client? 'client = clients[key];
                if ('client is ()) {
                    panic error("Client not found for the service");
                }

            }
        }

    }
}
