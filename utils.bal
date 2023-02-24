import ballerina/graphql;

public function filterFields(string[] keys, map<graphql:fieldDocument> fields) returns map<graphql:fieldDocument> {
    map<graphql:fieldDocument> queryField = {};
    foreach var key in keys {
        queryField[key] = fields[key];
    }
    return queryField;
}

public function getFieldsToFetch(map<anydata> fetchedFields, map<graphql:fieldDocument> fields) returns string[] {
    string[] fieldsToFetch = [];
    foreach var [key, value] in fields.entries() {
        if (value is graphql:fieldDocument) {
            if !(fetchedFields.keys().indexOf(key) is ()) {
                fieldsToFetch.push(key);
            }
        }
    }
    return fieldsToFetch;
}
