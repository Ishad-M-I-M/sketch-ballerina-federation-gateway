// Need to generate by code modifier plugin
import initial_impl.core;
import ballerina/graphql;

//Entry point to gateway. Will be generated

@graphql:ServiceConfig {
    graphiql: {
        enabled: true,
        path: "/graphiql"
    }
}
service on new graphql:Listener(9000) {

    // Map to keep the client objects. The client objects will be created once.
    private map<graphql:Client> clients;

    function init() returns error? {
        self.clients = {
            "astronauts": check new graphql:Client("http://localhost:4001"),
            "missions": check new graphql:Client("http://localhost:4002")
        };
    }

    isolated resource function get astronaut(int id, graphql:Field 'field) returns Astronaut|error {
        graphql:Client 'client = self.clients.get(ASTRONAUTS);
        core:QueryFieldClassifier classifier = new ('field, queryPlan, ASTRONAUTS);

        string fieldString = classifier.getFieldString();
        core:unResolvableField[] propertiesNotResolved = classifier.getUnresolvableFields();

        string queryString = core:wrapwithQuery("astronaut", fieldString, {"id": id.toString()});
        AstronautResponse response = check 'client->execute(queryString);

        Astronaut result = response.data.astronaut;

        core:Resolver resolver = new (self.clients, queryPlan, result, "Astronaut", propertiesNotResolved, ["astronaut"]);
        return resolver.getResult().ensureType();

    }

    isolated resource function get astronauts(graphql:Field 'field) returns Astronaut[]|error {
        graphql:Client 'client = self.clients.get(ASTRONAUTS);
        core:QueryFieldClassifier classifier = new ('field, queryPlan, ASTRONAUTS);

        string fieldString = classifier.getFieldString();
        core:unResolvableField[] propertiesNotResolved = classifier.getUnresolvableFields();

        string queryString = core:wrapwithQuery("astronauts", fieldString);
        AstronautsResponse response = check 'client->execute(queryString);

        Astronaut[] result = response.data.astronauts;

        core:Resolver resolver = new (self.clients, queryPlan, result, "Astronaut", propertiesNotResolved, ["astronauts"]);
        return resolver.getResult().ensureType();

    }

    isolated resource function get mission(int id, graphql:Field 'field) returns Mission|error {
        graphql:Client 'client = self.clients.get(MISSIONS);
        core:QueryFieldClassifier classifier = new ('field, queryPlan, MISSIONS);

        string fieldString = classifier.getFieldString();
        core:unResolvableField[] propertiesNotResolved = classifier.getUnresolvableFields();

        string queryString = core:wrapwithQuery("mission", fieldString, {"id": id.toString()});
        MissionResponse response = check 'client->execute(queryString);

        Mission result = response.data.mission;

        core:Resolver resolver = new (self.clients, queryPlan, result, "Mission", propertiesNotResolved, ["mission"]);
        return resolver.getResult().ensureType();

    }

    isolated resource function get missions(graphql:Field 'field) returns Mission[]|error {
        graphql:Client 'client = self.clients.get(MISSIONS);
        core:QueryFieldClassifier classifier = new ('field, queryPlan, MISSIONS);

        string fieldString = classifier.getFieldString();
        core:unResolvableField[] propertiesNotResolved = classifier.getUnresolvableFields();

        string queryString = core:wrapwithQuery("missions", fieldString);
        MissionsResponse response = check 'client->execute(queryString);

        Mission[] result = response.data.missions;

        core:Resolver resolver = new (self.clients, queryPlan, result, "Mission", propertiesNotResolved, ["missions"]);
        return resolver.getResult().ensureType();
    }

}
