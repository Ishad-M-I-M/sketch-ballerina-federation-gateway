public type Astronaut record {|
    Mission[] missions?;
    string name?;
    int id?;
|};

public type Mission record {|
    string? endDate?;
    int id?;
    string designation?;
    string? startDate?;
    Astronaut[]? crew?;
|};

public type MissionInput record {|
    int[] crewIds;
    string? endDate;
    string designation;
    string? startDate;
|};

public type astronautsResponse record {
    record {|Astronaut[] astronauts;|} data;
};

public type astronautResponse record {
    record {|Astronaut? astronaut;|} data;
};

public type astronautServiceDescriptionResponse record {
    record {|string astronautServiceDescription;|} data;
};

public type missionsResponse record {
    record {|Mission[] missions;|} data;
};

public type missionResponse record {
    record {|Mission mission;|} data;
};

public type missionServiceDescriptionResponse record {
    record {|string missionServiceDescription;|} data;
};

public type setAstronautServiceDescriptionResponse record {
    record {|string setAstronautServiceDescription;|} data;
};

public type addMissionResponse record {
    record {|Mission addMission;|} data;
};

public type setMissionServiceDescriptionResponse record {
    record {|string setMissionServiceDescription;|} data;
};
