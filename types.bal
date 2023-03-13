// Need to generate by code modifier plugin

type Mission record {|
    string id?;
    Astronaut[] crew?;
    string designation?;
    string? startDate?;
    string? endDate?;
|};

type Astronaut record {|
    string id?;
    string name?;
    Mission[] missions?;
|};

type Union Astronaut|Mission;

// The response types are generated by inspecting subgraphs and nesting the above defined corresponding types
// inside "data" and the respecive query name.

type AstronautResponse record {
    record {|Astronaut astronaut;|} data;
};

type AstronautsResponse record {
    record {|Astronaut[] astronauts;|} data;
};

type MissionResponse record {
    record {|Mission mission;|} data;
};

type MissionsResponse record {
    record {|Mission[] missions;|} data;
};

type EntityResponse record {
    record {|json[] _entities;|} data;
};
