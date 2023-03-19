import ballerina/graphql;

public type unResolvableField record {|
    string parent;
    graphql:Field 'field;
|};

public type fieldRecord record {|
    readonly string name;
    string 'type;
    string 'client;
    string[] requires?;
|};

public type queryPlanEntry record {|
    readonly string typename;
    map<string> keys;
    readonly & table<fieldRecord> key(name) fields;
|};

type EntityResponse record {
    record {|json[] _entities;|} data;
};
