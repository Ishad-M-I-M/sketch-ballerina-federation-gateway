import ballerina/io;
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

        //adding key field even not requested.
        map<graphql:fieldDocument> fields = 'field.getQueryDocument();
        fields["id"] = ();

        return new Astronaut(fields, self.clients, {id: id.toString()});
    }

    resource function get astronauts(graphql:Field 'field) returns Astronaut[]|error {

        //adding key field even not requested.
        map<graphql:fieldDocument> fields = 'field.getQueryDocument();
        fields["id"] = ();

        io:println("\n\n[DEBUG - MAIN] requested fields:\n", fields);

        if (self.clients["astronauts"] == ()) {
            return error("Client not found");
        }
        else {
            graphql:Client 'client = <graphql:Client>self.clients["astronauts"];

            string query = string `query{
                astronauts {
                    ${buildQueryString(filterFields(fields.keys(), fields))}
                }
            }`;

            io:println("\n\n[DEBUG - MAIN] query to fetch astronauts:\n", query);

            AstronautsRecordResponse result = check 'client->execute(query);
            return result.data.astronauts.map(function(AstronautRecord astronaut) returns Astronaut {
                Astronaut|error _astronaut = new (fields, self.clients, astronaut);
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

        //adding key field even not requested.
        map<graphql:fieldDocument> fields = 'field.getQueryDocument();
        fields["id"] = ();

        return new Mission(fields, self.clients, {id: id.toString()});
    }

    resource function get missions(graphql:Field 'field) returns Mission[]|error {

        //adding key field even not requested.
        map<graphql:fieldDocument> fields = 'field.getQueryDocument();
        fields["id"] = ();

        if (self.clients["missions"] == ()) {
            return error("Client not found");
        }
        else {
            graphql:Client 'client = <graphql:Client>self.clients["missions"];

            string query = string `query{
                missions {
                    ${buildQueryString(fields)}
                }
            }`;

            MissionsRecordResponse result = check 'client->execute(query);
            return result.data.missions.map(function(MissionRecord mission) returns Mission {
                Mission|error _mission = new (fields, self.clients, mission);
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
