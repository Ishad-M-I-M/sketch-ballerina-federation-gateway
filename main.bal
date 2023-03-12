import ballerina/graphql;
import ballerina/io;

@graphql:ServiceConfig {
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

        if subfields is () {
            return error("Invalid graphql document");
        }

        string queryString = wrapwithQuery("astronaut", buildQueryString(subfields, "Astronaut", "astronauts", resolver), {"id": id.toString()});

        AstronautResponse response = check 'client->execute(queryString);

        Astronaut result = response.data.astronaut;

        _ = resolver.pushToIds([id.toString()]);

        ResolvedRecord[] records = check resolver.execute();

        var finalResult = check composeResults(result, records);

        return <Astronaut>finalResult;
    }

    resource function get astronauts(graphql:Field 'field) returns Astronaut[]|error {
        Resolver resolver = new Resolver(self.clients);

        graphql:Client 'client = self.clients.get("astronauts");

        graphql:Field[]? subfields = 'field.getSubfields();

        if subfields is () {
            return error("Invalid graphql document");
        }

        string queryString = wrapwithQuery("astronauts", buildQueryString(subfields, "Astronaut", "astronauts", resolver));

        AstronautsResponse response = check 'client->execute(queryString);

        Astronaut[] result = response.data.astronauts;

        _ = resolver.pushToIds(from var astronaut in result
            select astronaut.id.toString());

        ResolvedRecord[] records = check resolver.execute();

        var finalResult = check composeResults(result, records);

        if finalResult is Union[] {
            return finalResult.cloneWithType();
        } else {
            return error("Invalid results");
        }
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
