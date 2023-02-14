const { ApolloServer} = require("@apollo/server");
const{ startStandaloneServer } = require('@apollo/server/standalone');
const {gql} = require("graphql-tag");
const { buildSubgraphSchema } = require("@apollo/subgraph");
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

const port = 4002;
const apiUrl = "http://localhost:3000";

const typeDefs = gql`
  type Mission {
    id: ID!
    crew: [ID]
    designation: String!
    startDate: String
    endDate: String
  }

  extend type Query {
    mission(id: ID!): Mission
    missions: [Mission]
  }
`;

const resolvers = {
  Mission: {
    __resolveReference(ref) {
      return fetch(`${apiUrl}/missions/${ref.id}`).then(res => res.json());
    }
  },
  Query: {
    mission(_, { id }) {
      return fetch(`${apiUrl}/missions/${id}`).then(res => res.json());
    },
    missions() {
      return fetch(`${apiUrl}/missions`).then(res => res.json());
    }
  }
};

const server = new ApolloServer({
  schema: buildSubgraphSchema([{ typeDefs, resolvers }])
});

startStandaloneServer(server,{
    listen : {port: port}
}).then(({url})=>{
    console.log(`🚀  Server ready at ${url}`);
});