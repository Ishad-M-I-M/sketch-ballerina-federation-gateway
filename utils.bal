import ballerina/jballerina.java;

// Prepare query string to resolve by reference.
isolated function wrapWithEntityRepresentation(string typename, string key, string[] ids, string fieldQuery) returns string {
    string[] representations = [];
    foreach var id in ids {
        representations.push(string `{ __typename: "${typename}" ${key}: "${id}"}`);
    }
    return string `query{
        _entities(
            representations: [${string:'join(", ", ...representations)}]
        ) {
            ... on ${typename} {
                ${key}
                ${fieldQuery}
            }
        }
    }`;
}

// Prepare query string to resolve by query.
isolated function wrapwithQuery(string root, string fieldQuery, map<string>? args = ()) returns string {
    if args is () {
        return string `query
            {   
                ${root}{
                ${fieldQuery}
            }
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
                ${fieldQuery}
            }
        }`;
    }
}

isolated function convertPathToStringArray((string|int)[] path) returns string[] {
    return path.'map(isolated function(string|int element) returns string {
        return element is int ? "@" : element;
    });
}

isolated function compose(map<json> initialResult, map<json> resultToCompose, string element) = @java:Method {
    'class: "io.ballerina.stdlib.NativeImpl"
} external;
