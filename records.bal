import ballerina/graphql;

public type unResolvableField record {|
    string parent;
    graphql:Field 'field;
|};
