import ballerina/graphql;

public type unResolvableField record {|
    string parent;
    graphql:Field 'field;
|};

public type requiresFieldRecord record {|
    string clientName;
    string fieldString;
|};

public type fieldRecord record {|
    readonly string name;
    string 'type;
    string 'client;
    // In query plan generation need to process the required field string and seperate the fields and the client
    // which will resolve it.
    requiresFieldRecord[] requires?;
|};

public type queryPlanEntry record {|
    readonly string typename;
    map<string> keys;
    readonly & table<fieldRecord> key(name) fields;
|};

type EntityResponse record {
    record {|json[] _entities;|} data;
};
