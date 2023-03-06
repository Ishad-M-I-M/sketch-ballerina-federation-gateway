import ballerina/graphql;


isolated function getResolvableSubfields(graphql:Field 'field, string clientName, Resolver resolver) returns graphql:Field[]?{
    //returns the resolvable subfields and push the unresolvable fields to the resolver.
    graphql:Field[]? subfields = 'field.getSubfields();
    if (subfields is ()){
        return ();
    }

    
} 

public isolated function buildQueryString(graphql:Field[] fields, string clientName, Resolver resolver) returns string {
    string[] queryStrings = [];

    foreach var 'field in fields {
        graphql:Field[]? subFields = 'field.getSubfields();
        if ( subFields is ()) {
            queryStrings.push('field.getName());
        } else {
            queryStrings.push('field.getName() + " {\n" + buildQueryString(subFields, clientName, resolver) + "\n}\n");
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

public isolated function wrapWithEntityRepresentation(string typename, string[] ids, string propertyQuery) returns string {
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

public isolated function wrapwithQuery(string root, string propertyQuery, map<string>? args = ()) returns string {
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
