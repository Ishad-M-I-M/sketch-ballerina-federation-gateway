import ballerina/graphql;

public function buildQueryString(graphql:Field[] fields) returns string {
    string[] queryStrings = [];

    foreach var [key, value] in fields.entries() {
        if (value is ()) {
            queryStrings.push(key);
        } else {
            queryStrings.push(key + " {\n" + buildQueryString(value) + "\n}\n");
        }
    }
    return string:'join(" ", ...queryStrings);
}

public type queryResolveEntry record {
    string[] path;
    graphql:Field[] query;
    string[][] ids;
    string typename;
    string 'client;
};

public isolated function buildQueryPlan(graphql:Field[] 'field, string typename, string[] path) returns queryResolveEntry[]|error {
    queryResolveEntry[] queryPlan = [];

    foreach var [key, value] in 'field.entries() {

    }

    return error("Not implemented");

}

public function wrapWithEntityRepresentation(string typename, string[] ids, string propertyQuery) returns string {
    string[] representations = [];
    foreach var id in ids {
        representations.push(string `{ __typename: "${typename}" id: "${id}"}`);
    }
    return string `query{
        _entities(
            representations: [${string:'join(", ", ...representations)}]
        ) {
            ... on ${typename} {
                ${propertyQuery}
            }
        }
    }`;
}

public function wrapwithQuery(string root, string propertyQuery, map<string>? args = ()) returns string {
    if args is () {
        return string `${root}{
            ${propertyQuery}
        }`;
    }
    else {
        string[] argsList = [];
        foreach var [key, value] in args.entries() {
            argsList.push(string `${key}: ${value}`);
        }
        return string `query
            {
                ${root}(${string:'join(", ", ...argsList)}){
                ${propertyQuery}
            }
        }`;
    }
}
