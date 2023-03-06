import ballerina/graphql;
import ballerina/io;

@graphql:ServiceConfig{
    graphiql: {
        enabled: true,
        path: "/testing"
    }
}
service on new graphql:Listener(9000) {

    private map<graphql:Client> clients;

    function init() returns error? {
        self.clients = {
            "astronauts": check new graphql:Client("http://localhost:4001"),
            "missions": check new graphql:Client("http://localhost:4002")
        };
    }

    resource function get astronaut(graphql:Field 'field, int id) returns Astronaut|error {
        Resolver resolver = new Resolver(self.clients);

        graphql:Client 'client = self.clients.get("astronauts");

        graphql:Field[]? subfields = 'field.getSubfields();

        if subfields is (){
            return error("Invalid graphql document");
        }        

        AstronautResponse response = check 'client->execute(wrapwithQuery("astronaut", buildQueryString(subfields, "astronauts", resolver), {"id": id.toString()}));

        ResolvedRecord[] records = resolver.execute();

        Astronaut result = response.data.astronaut;

        while (records.length() > 0) {
            ResolvedRecord 'record = records.pop();

            // TODO: compose with the `result` to prepare the final result.
        }

        return result;
    }

    resource function get astronauts(graphql:Field 'field) returns Astronaut[]|error {
        io:println('field.getType());
        return error("Not implemented");
    }

    resource function get mission(graphql:Field 'field, int id) returns Mission|error {
        io:println('field.getType());
        return error("Not implemented");
    }

    resource function get missions(graphql:Field 'field) returns Mission[]|error {
        // "id", "designation", "startDate", "endDate", "crew" - solved directly from the `missions` client.
        // "crew"."name" - resolved from the `astronauts` client using _entities query.
        io:println('field.getType());
        return error("Not implemented");
    }

}
