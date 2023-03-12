// Prepare query string to resolve by reference.
isolated function wrapWithEntityRepresentation(string typename, string[] ids, string propertyQuery) returns string {
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

// Prepare query string to resolve by query.
isolated function wrapwithQuery(string root, string propertyQuery, map<string>? args = ()) returns string {
    if args is () {
        return string `query
            {   
                ${root}{
                ${propertyQuery}
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
                ${propertyQuery}
            }
        }`;
    }
}
