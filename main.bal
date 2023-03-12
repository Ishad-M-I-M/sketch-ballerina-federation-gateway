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

    resource function get astronaut(int id, graphql:Field 'field) returns Astronaut|error {
        graphql:Client 'client = self.clients.get("astronauts");
        QueryPropertyClassifier classifier = new ('field, "astronauts");

        string propertyString = classifier.getPropertyString();
        unResolvableField[] propertiesNotResolved = classifier.getUnresolvableFields();

        string queryString = wrapwithQuery("astronaut", propertyString, {"id": id.toString()});
        AstronautResponse response = check 'client->execute(queryString);

        Astronaut result = response.data.astronaut;

        if (propertiesNotResolved.length() > 0) {
            Resolver resolver = new (self.clients, result, propertiesNotResolved, ["astronaut"]);
            return resolver.resolve().ensureType();
        }
        else {
            return result;
        }
    }

    resource function get astronauts(graphql:Field 'field) returns Astronaut[]|error {

        graphql:Client 'client = self.clients.get("astronauts");
        QueryPropertyClassifier classifier = new ('field, "astronauts");

        string propertyString = classifier.getPropertyString();
        unResolvableField[] propertiesNotResolved = classifier.getUnresolvableFields();

        string queryString = wrapwithQuery("astronauts", propertyString);
        AstronautsResponse response = check 'client->execute(queryString);

        Astronaut[] result = response.data.astronauts;

        if (propertiesNotResolved.length() > 0) {
            Resolver resolver = new (self.clients, result, propertiesNotResolved, ["astronauts"]);
            return resolver.resolve().ensureType();
        }
        else {
            return result;
        }

    }

    resource function get mission(int id, graphql:Field 'field) returns Mission|error {
        graphql:Client 'client = self.clients.get("missions");
        QueryPropertyClassifier classifier = new ('field, "missions");

        string propertyString = classifier.getPropertyString();
        unResolvableField[] propertiesNotResolved = classifier.getUnresolvableFields();

        string queryString = wrapwithQuery("mission", propertyString, {"id": id.toString()});
        MissionResponse response = check 'client->execute(queryString);

        Mission result = response.data.mission;

        if (propertiesNotResolved.length() > 0) {
            Resolver resolver = new (self.clients, result, propertiesNotResolved, ["mission"]);
            return resolver.resolve().ensureType();
        }
        else {
            return result;
        }
    }

    resource function get missions(graphql:Field 'field) returns Mission[]|error {
        graphql:Client 'client = self.clients.get("missions");
        QueryPropertyClassifier classifier = new ('field, "missions");

        string propertyString = classifier.getPropertyString();
        unResolvableField[] propertiesNotResolved = classifier.getUnresolvableFields();

        string queryString = wrapwithQuery("missions", propertyString);
        MissionsResponse response = check 'client->execute(queryString);

        Mission[] result = response.data.missions;

        if (propertiesNotResolved.length() > 0) {
            Resolver resolver = new (self.clients, result, propertiesNotResolved, ["missions"]);
            return resolver.resolve().ensureType();
        }
        else {
            return result;
        }
    }

}
