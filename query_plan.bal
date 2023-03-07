
string[] typenames = ["Astronaut", "Mission"];
string[] scalarTypes = ["ID", "STRING", "INT", "FLOAT", "BOOLEAN"];

public type fieldRecord record {|
    readonly string name;
    string 'type;
    string 'client;
|};

public type queryPlanEntry record {|
    readonly string typename;
    string key;
    readonly & table<fieldRecord> key(name) fields;
|};

public final readonly & table<queryPlanEntry> key(typename) queryPlan = table [
    {
        typename: "Astronaut",
        key: "id",
        fields: table [
            {name: "name", 'type: "STRING", 'client: "astronauts"},
            {name: "missions", 'type: "Mission", 'client: "missions"}
        ]
    },
    {
        typename: "Mission",
        key: "id",
        fields: table [
            {name: "designation", 'type: "STRING", 'client: "missions"},
            {name: "crew", 'type: "Astronaut", 'client: "missions"},
            {name: "startDate", 'type: "STRING", 'client: "missions"},
            {name: "endDate", 'type: "STRING", 'client: "missions"}
        ]
    }
];
