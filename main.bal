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
        return new Astronaut('field.getQueryDocument(), self.clients, {id: id.toString()});
    }

    resource function get astronauts(graphql:Field 'field) returns Astronaut[]|error {
        if (self.clients["astronauts"] == ()) {
            return error("Client not found");
        }
        else {
            graphql:Client 'client = <graphql:Client>self.clients["astronauts"];

            string query = string `query{
                astronauts {
                    ${buildQueryString(filterFields(["id", "name"], 'field.getQueryDocument()))}
                }
            }`;

            AstronautsRecordResponse result = check 'client->execute(query);
            return result.data.astronauts.map(function(AstronautRecord astronaut) returns Astronaut {
                Astronaut|error _astronaut = new ('field.getQueryDocument(), self.clients, astronaut);
                if (_astronaut is Astronaut) {
                    return _astronaut;
                }
                else {
                    panic error("Error while creating the astronaut");
                }
            });
        }
    }

    resource function get mission(graphql:Field 'field, int id) returns Mission|error {
        return new Mission('field.getQueryDocument(), self.clients, {id: id.toString()});
    }

    resource function get missions(graphql:Field 'field) returns Mission[]|error {
        if (self.clients["missions"] == ()) {
            return error("Client not found");
        }
        else {
            graphql:Client 'client = <graphql:Client>self.clients["missions"];

            string query = string `query{
                missions {
                    ${buildQueryString('field.getQueryDocument())}
                }
            }`;

            MissionsRecordResponse result = check 'client->execute(query);
            return result.data.missions.map(function(MissionRecord mission) returns Mission {
                Mission|error _mission = new ('field.getQueryDocument(), self.clients, mission);
                if (_mission is Mission) {
                    return _mission;
                }
                else {
                    panic error("Error while creating the mission");
                }
            });
        }
    }

}
