import ballerina/graphql;

public type Astronaut record {|
    Mission?[]? missions?;
    string? name?;
    int id?;
|};

public type Mission record {|
    string? endDate?;
    int id?;
    string designation?;
    string? startDate?;
    Astronaut?[]? crew?;
|};

public type MissionInput record {|
    string designation;
    string? startDate;
    string? endDate;
    int[] crewIds;
|};

public type astronautResponse record {
    record {|Astronaut astronaut;|} data;
    graphql:ErrorDetail[] errors?;
};

public type astronautsResponse record {
    record {|Astronaut[] astronauts;|} data;
    graphql:ErrorDetail[] errors?;
};

public type missionResponse record {
    record {|Mission mission;|} data;
    graphql:ErrorDetail[] errors?;
};

public type missionsResponse record {
    record {|Mission[] missions;|} data;
    graphql:ErrorDetail[] errors?;
};

public type addMissionResponse record {
    record {|Mission addMission;|} data;
    graphql:ErrorDetail[] errors?;
};
