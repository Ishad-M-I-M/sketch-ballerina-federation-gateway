type MissionSubgraph record {|
    string id;
    MissionSubgraphAstronaut[] crew;
    string designation;
    string? startDate;
    string? endDate;
|};

type AstronautSubgraph record {|
    string id;
    string name;
|};

type MissionSubgraphAstronaut record {|
    string id;
    // MissionSubgraph[]? missions;
|};

type AstronautSubgraphResponse record {
    record {|AstronautSubgraph astronaut;|} data;
};

type AstronautsSubgraphResponse record {
    record {|AstronautSubgraph[] astronauts;|} data;
};

type MissionSubgraphResponse record {
    record {|MissionSubgraph mission;|} data;
};

type MissionsSubgraphResponse record {
    record {|MissionSubgraph[] missions;|} data;
};
