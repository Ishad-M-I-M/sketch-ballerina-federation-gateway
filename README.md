# Proof of Concept for Graphql Federation Gateway in Ballerina

This is proof of concept implementation for writing a graphql federation gateway in Ballerina.

## ballerina-gateway
Hard coded code in Ballerina to act as a gateway for the given subgraph services.
To start the gateway 
```bash
cd ballerina-gateway
bal run
```

## ballerina-subgraphs
Include 2 subgraph serivces written in Ballerina. 
* astronaut-service
* missions-service

To start subgraph services run following command in respective directories.
```bash 
bal run
```

## javascript-subgraphs
Subgraph services written in javascript.
To start the services execute
```bash
cd javascript-subgraphs
npm run services
```