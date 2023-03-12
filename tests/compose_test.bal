import ballerina/test;

function compose(json finalResult, json resultToCompose, string[] path) returns error? {
    string[] pathCopy = path.clone();
    json pointer = finalResult;
    string element = pathCopy.shift();

    while (pathCopy.length() > 0) {
        if element == "@" {
            if resultToCompose is json[] && pointer is json[] {
                foreach var i in 0 ... (resultToCompose.length() - 1) {
                    _ = check compose(pointer[i], resultToCompose[i], pathCopy);
                }
                return;
            }
        }
        else {
            pointer = (<map<json>>pointer)[element];
        }
        element = pathCopy.shift();
    }

    if pointer is map<json> && resultToCompose is map<json> {
        pointer[element] = resultToCompose[element];
    }
    else {
        return error("Error");
    }
}

@test:Config {
    groups: ["compose"]
}
function testCompose1() {
    Astronaut test1 = {
        id: "1",
        name: "John Doe"
    };

    Astronaut test1a = {
        id: "1",
        missions: [
            {
                id: "1",
                designation: "Apollo 11"
            }
        ]
    };

    Astronaut test1Result = {
        id: "1",
        name: "John Doe",
        missions: [
            {
                id: "1",
                designation: "Apollo 11"
            }
        ]
    };

    error? result = compose(test1, test1a, ["missions"]);
    if result is error {
        test:assertFail(msg = result.message());
    }
    else {
        test:assertEquals(test1, test1Result);
    }

}

@test:Config {
    groups: ["compose"]
}
function testCompose2() {
    Astronaut[] test2 = [
        {
            id: "1",
            name: "John Doe"
        },
        {
            id: "2",
            name: "Jane Doe"
        }
    ];

    Astronaut[] test2a = [
        {
            id: "1",
            missions: [
                {
                    id: "1",
                    designation: "Apollo 11"
                }
            ]
        },
        {
            id: "2",
            missions: [
                {
                    id: "2",
                    designation: "Apollo 12"
                }
            ]
        }
    ];

    Astronaut[] test2Result = [
        {
            "id": "1",
            "name": "John Doe",
            "missions": [
                {
                    "id": "1",
                    "designation": "Apollo 11"
                }
            ]
        },
        {
            "id": "2",
            "name": "Jane Doe",
            "missions": [
                {"id": "2", "designation": "Apollo 12"}
            ]
        }
    ];

    error? result = compose(test2, test2a, ["@", "missions"]);
    if result is error {
        test:assertFail(msg = result.message());
    }
    else {
        test:assertEquals(test2, test2Result);
    }

}

@test:Config {
    groups: ["compose"]
}
function testCompose3() {
    Astronaut test3 = {
        id: "1",
        name: "John Doe",
        missions: [
            {
                id: "1",
                designation: "Apollo 11",
                crew: [
                    {
                        id: "1"
                    },
                    {
                        id: "2"
                    }
                ]
            },
            {
                id: "2",
                designation: "Apollo 12",
                crew: [
                    {
                        id: "4"
                    },
                    {
                        id: "5"
                    }
                ]
            }
        ]
    };

    Astronaut[][] test3a = [
        [
            {
                id: "1",
                name: "John Doe1"
            },
            {
                id: "2",
                name: "Jane Doe2"
            }
        ],
        [
            {
                id: "4",
                name: "John Doe4"
            },
            {
                id: "5",
                name: "Jane Doe5"
            }
        ]
    ];

    Astronaut test3Result = {
        "id": "1",
        "name": "John Doe",
        "missions": [
            {
                "id": "1",
                "crew": [
                    {"id": "1", "name": "John Doe1"},
                    {"id": "2", "name": "Jane Doe2"}
                ],
                "designation": "Apollo 11"
            },
            {
                "id": "2",
                "crew": [
                    {"id": "4", "name": "John Doe4"},
                    {"id": "5", "name": "Jane Doe5"}
                ],
                "designation": "Apollo 12"
            }
        ]
    };

    error? result = compose(test3, test3a, ["missions", "@", "crew", "@", "name"]);
    if result is error {
        test:assertFail(msg = result.message());
    }
    else {
        test:assertEquals(test3, test3Result);
    }

}

@test:Config {
    groups: ["compose"]
}
function testCompose4() {

    Astronaut[] test4 = [
        {
            id: "1",
            missions: [
                {
                    id: "1",
                    designation: "Apollo 11",
                    crew: [
                        {
                            id: "1"
                        },
                        {
                            id: "2"
                        }
                    ]
                },
                {
                    id: "2",
                    designation: "Apollo 12",
                    crew: [
                        {
                            id: "4"
                        },
                        {
                            id: "5"
                        }
                    ]
                }
            ]
        },
        {
            id: "2",
            missions: [
                {
                    id: "3",
                    designation: "Apollo 13",
                    crew: [
                        {
                            id: "6"
                        },
                        {
                            id: "7"
                        }
                    ]
                },
                {
                    id: "4",
                    designation: "Apollo 14",
                    crew: [
                        {
                            id: "8"
                        },
                        {
                            id: "9"
                        }
                    ]
                }
            ]
        }
    ];

    Astronaut[][][] test4a = [
        [
            [
                {
                    id: "1",
                    name: "John Doe1"
                },
                {
                    id: "2",
                    name: "Jane Doe2"
                }
            ],
            [
                {
                    id: "4",
                    name: "John Doe4"
                },
                {
                    id: "5",
                    name: "Jane Doe5"
                }
            ]
        ],

        [
            [
                {
                    id: "4",
                    name: "John Doe4"
                },
                {
                    id: "5",
                    name: "Jane Doe5"
                }
            ],
            [
                {
                    id: "4",
                    name: "John Doe4"
                },
                {
                    id: "5",
                    name: "Jane Doe5"
                }
            ]
        ]

    ];

    Astronaut[] test4Result = [
        {
            "id": "1",
            "missions": [
                {
                    "id": "1",
                    "crew": [{"id": "1", "name": "John Doe1"}, {"id": "2", "name": "John Doe2"}],
                    "designation": "Apollo 11"
                },
                {
                    "id": "2",
                    "crew": [{"id": "4", "name": "John Doe4"}, {"id": "5"}],
                    "designation": "Apollo 12"
                }
            ]
        },
        {
            "id": "2",
            "name": "Jane Doe2",
            "missions": [
                {
                    "id": "3",
                    "crew": [{"id": "6"}, {"id": "7"}],
                    "designation": "Apollo 13"
                },
                {
                    "id": "4",
                    "crew": [{"id": "8"}, {"id": "9"}],
                    "designation": "Apollo 14"
                }
            ]
        }
    ];

    error? result = compose(test4, test4a, ["@", "missions", "@", "crew", "@", "name"]);
    if result is error {
        test:assertFail(msg = result.message());
    }
    else {
        test:assertEquals(test4, test4Result);
    }

}
