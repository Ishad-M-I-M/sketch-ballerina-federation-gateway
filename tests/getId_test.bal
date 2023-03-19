// import ballerina/test;

// isolated function getIdsInPathTest(json pointer, string[] path, string parentType) returns string[]|error {
//     Resolver resolver = new ({}, null, "", [], []);
//     return resolver.getIdsInPath(pointer, path, parentType);
// }

// @test:Config {
//     groups: ["getIdsInPath"]
// }
// function testGetIdsInPath1() {
//     json pointer = {
//         "id": "10",
//         "name": "John"
//     };
//     string[] path = [];
//     string parentType = "Astronaut";
//     string[] expected = ["10"];
//     string[]|error actual = getIdsInPathTest(pointer, path, parentType);

//     if actual is error {
//         test:assertFail(msg = actual.message());
//     } else {
//         test:assertEquals(actual, expected);
//     }
// }

// @test:Config {
//     groups: ["getIdsInPath"]
// }
// function testGetIdsInPath2() {
//     json pointer = [
//         {
//             "id": "1",
//             "name": "John"
//         },
//         {
//             "id": "2",
//             "name": "Doe"
//         },
//         {
//             "id": "5",
//             "name": "Jane"
//         }
//     ];
//     string[] path = [];
//     string parentType = "Astronaut";
//     string[] expected = ["1", "2", "5"];
//     string[]|error actual = getIdsInPathTest(pointer, path, parentType);

//     if actual is error {
//         test:assertFail(msg = actual.message());
//     } else {
//         test:assertEquals(actual, expected);
//     }
// }

// @test:Config {
//     groups: ["getIdsInPath"]
// }
// function testGetIdsInPath3() {
//     json pointer = {
//         id: "1",
//         designation: "Apollo 11",
//         crew: [
//             {
//                 "id": "1",
//                 "name": "John"
//             },
//             {
//                 "id": "2",
//                 "name": "Doe"
//             },
//             {
//                 "id": "5",
//                 "name": "Jane"
//             }
//         ]
//     };
//     string[] path = ["crew"];
//     string parentType = "Mission";
//     string[] expected = ["1", "2", "5"];
//     string[]|error actual = getIdsInPathTest(pointer, path, parentType);

//     if actual is error {
//         test:assertFail(msg = actual.message());
//     } else {
//         test:assertEquals(actual, expected);
//     }
// }

