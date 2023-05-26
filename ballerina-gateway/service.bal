import ballerina/graphql;
import ballerina/log;

final graphql:Client MISSIONS_CLIENT = check new graphql:Client("http://localhost:5002");
final graphql:Client ASTRONAUTS_CLIENT = check new graphql:Client("http://localhost:5001");

isolated function getClient(string clientName) returns graphql:Client {
    match clientName {
        "missions" => {
            return MISSIONS_CLIENT;
        }
        "astronauts" => {
            return ASTRONAUTS_CLIENT;
        }
        _ => {
            panic error("Client not found");
        }
    }
}

configurable int PORT = 9000;

isolated service on new graphql:Listener(PORT) {
    isolated function init() {
        log:printInfo(string `💃 Server ready at port: ${PORT}`);
    }

    isolated resource function get astronaut(graphql:Field 'field, graphql:Context context, int id)
                                                                                            returns Astronaut|error {
        QueryFieldClassifier classifier = new ('field, queryPlan, ASTRONAUTS);
        string fieldString = classifier.getFieldString();
        UnResolvableField[] propertiesNotResolved = classifier.getUnresolvableFields();
        string queryString = wrapwithQuery("astronaut", fieldString, {"id": getParamAsString(id)});
        astronautResponse|graphql:ClientError response = ASTRONAUTS_CLIENT->execute(queryString);

        // Form the result by the arguments provided.
        Astronaut result = {
            id: id
        };
        graphql:ErrorDetail[] errors = [];
        if (response is graphql:ClientError) {
            // Since still it is abled to resolve the other fields adding the error message in to the context and proceed.
            appendUnableToResolveErrorDetail(errors, 'field);
        } else {
            result = response.data.astronaut;
        }
        Resolver resolver = new (queryPlan, result.toJson(), "Astronaut", propertiesNotResolved, ["astronaut"], errors);
        json finalResult = resolver.getResult();
        addErrorsToGraphqlContext(context, errors);
        return finalResult.cloneWithType();
    }
    isolated resource function get astronauts(graphql:Field 'field, graphql:Context context) returns Astronaut[]|error {
        QueryFieldClassifier classifier = new ('field, queryPlan, ASTRONAUTS);
        string fieldString = classifier.getFieldString();
        UnResolvableField[] propertiesNotResolved = classifier.getUnresolvableFields();
        string queryString = wrapwithQuery("astronauts", fieldString);
        astronautsResponse|graphql:ClientError response = ASTRONAUTS_CLIENT->execute(queryString);
        graphql:ErrorDetail[] errors = [];
        Astronaut[] result = [];
        if (response is graphql:ClientError) {
            // Since still it is abled to resolve the other fields adding the error message in to the context and proceed.
            appendUnableToResolveErrorDetail(errors, 'field);
        } else {
            result = response.data.astronauts;
        }
        Resolver resolver = new (queryPlan, result.toJson(), "Astronaut", propertiesNotResolved, ["astronauts"], errors);
        json finalResult = resolver.getResult();
        addErrorsToGraphqlContext(context, errors);
        return finalResult.cloneWithType();
    }

    isolated resource function get mission(graphql:Field 'field, graphql:Context context, int id) returns Mission|error {
        QueryFieldClassifier classifier = new ('field, queryPlan, MISSIONS);
        string fieldString = classifier.getFieldString();
        UnResolvableField[] propertiesNotResolved = classifier.getUnresolvableFields();
        string queryString = wrapwithQuery("mission", fieldString, {"id": getParamAsString(id)});
        missionResponse|graphql:ClientError response = MISSIONS_CLIENT->execute(queryString);

        // Form the result by the arguments provided.
        Mission result = {
            id: id
        };
        graphql:ErrorDetail[] errors = [];
        if (response is graphql:ClientError) {
            // Since still it is abled to resolve the other fields adding the error message in to the context and proceed.
            appendUnableToResolveErrorDetail(errors, 'field);
        } else {
            result = response.data.mission;
        }
        Resolver resolver = new (queryPlan, result.toJson(), "Mission", propertiesNotResolved, ["mission"], errors);
        json finalResult = resolver.getResult();
        addErrorsToGraphqlContext(context, errors);
        return finalResult.cloneWithType();
    }
    isolated resource function get missions(graphql:Field 'field, graphql:Context context) returns Mission[]|error {
        QueryFieldClassifier classifier = new ('field, queryPlan, MISSIONS);
        string fieldString = classifier.getFieldString();
        UnResolvableField[] propertiesNotResolved = classifier.getUnresolvableFields();
        string queryString = wrapwithQuery("missions", fieldString);
        missionsResponse|graphql:ClientError response = MISSIONS_CLIENT->execute(queryString);
        graphql:ErrorDetail[] errors = [];
        Mission[] result = [];
        if (response is graphql:ClientError) {
            // Since still it is abled to resolve the other fields adding the error message in to the context and proceed.
            appendUnableToResolveErrorDetail(errors, 'field);
        } else {
            result = response.data.missions;
        }
        Resolver resolver = new (queryPlan, result.toJson(), "Mission", propertiesNotResolved, ["missions"], errors);
        json finalResult = resolver.getResult();
        addErrorsToGraphqlContext(context, errors);
        return finalResult.cloneWithType();
    }
    isolated remote function addMission(graphql:Field 'field, graphql:Context context, MissionInput missionInput) returns Mission|error {
        QueryFieldClassifier classifier = new ('field, queryPlan, MISSIONS);
        string fieldString = classifier.getFieldString();
        UnResolvableField[] propertiesNotResolved = classifier.getUnresolvableFields();
        string queryString = wrapwithMutation("addMission", fieldString, {"missionInput": getParamAsString(missionInput)});
        addMissionResponse|graphql:ClientError response = MISSIONS_CLIENT->execute(queryString);
        if (response is graphql:ClientError) {
            // Since still it is abled to resolve the other fields adding the error message in to the context and proceed.
            return error("Unable to perform the operation");
        }
        Mission result = response.data.addMission;
        graphql:ErrorDetail[] errors = [];
        Resolver resolver = new (queryPlan, result.toJson(), "Mission", propertiesNotResolved, ["addMission"], errors);
        json finalResult = resolver.getResult();
        addErrorsToGraphqlContext(context, errors);
        return finalResult.cloneWithType();
    }
}
