import ballerina/graphql;

isolated function getResolvableSubfields(graphql:Field 'field, string parentType, string clientName, Resolver resolver) returns graphql:Field[]? {
    //returns the resolvable subfields and push the unresolvable fields to the resolver.

    graphql:Field[]? subfields = 'field.getSubfields();
    if (subfields is ()) {
        return ();
    }

    string? fieldTypeName = 'field.getUnwrappedType().name;
    if (fieldTypeName is ()) {
        panic error("Invalid graphql document");
    }

    string|error parentTypeClient = trap queryPlan.get(parentType).fields.get('field.getName()).'client;

    if (parentTypeClient is string) {
        if parentTypeClient != clientName {
            resolver.pushToResolve('field, parentType);
            return ();
        }
    }

    graphql:Field[] fields = [];

    foreach var item in subfields {
        // check whether item is the key
        if item.getName() == queryPlan.get(fieldTypeName).key {
            fields.push(item);
        }
        else {
            if clientName == queryPlan.get(fieldTypeName).fields.get(item.getName()).'client {
                fields.push(item);
            }
            else {
                resolver.pushToResolve(item, parentType);
            }
        }
    }
    return fields;
}

public isolated function buildQueryString(graphql:Field[] fields, string parentType, string clientName, Resolver resolver) returns string {
    string[] queryStrings = [];

    foreach var 'field in fields {
        graphql:Field[]? subFields = getResolvableSubfields('field, parentType, clientName, resolver);
        if (subFields is ()) {
            if 'field.getUnwrappedType().kind == "OBJECT" || 'field.getUnwrappedType().kind == "INTERFACE" {
                continue;
            }
            queryStrings.push('field.getName());
        } else {
            string innerQuery = buildQueryString(subFields, parentType, clientName, resolver);
            if innerQuery != "" {
                queryStrings.push('field.getName() + " {\n" + innerQuery + "\n}\n");
            }
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

# Compose the initial result and the results obtained by the resolving by referance
#
# + initialResult - The result obtained by to level query
# + results - The results obtained by the resolving by referance
# + return - Composed result
public isolated function composeResults(Union|Union[] initialResult, ResolvedRecord[] results) returns Union|Union[]|error {
    Union|Union[] finalResult = initialResult.clone();

    while results.length() > 0 {
        ResolvedRecord 'record = results.pop();

        if initialResult is Union {
            json initialResultJson = finalResult.toJson();
            _ = check updateJson(initialResultJson, 'record.path.slice(1), check 'record.result);
        }
        else {

        }
    }

    return finalResult;
}

public isolated function updateJson(json initial, string[] path, json newValue) returns error? {
    string[] copyPath = path.clone();
    var pointer = initial;
    while copyPath.length() > 1 {
        if pointer is map<json> {
            pointer = pointer[path.remove(0)];
        } else {
            return error("invalid path");
        }
    }
    if pointer is map<json> {
        pointer[path[0]] = newValue;
    } else {
        return error("invalid path");
    }
}
