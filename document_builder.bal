import ballerina/graphql;

public function buildQueryString(map<graphql:fieldDocument> fields) returns string {
    string[] queryStrings = [];

    foreach var [key, value] in fields.entries() {
        if (value is map<json>) {
            queryStrings.push(key + " {\n" + buildQueryString(value) + "\n}\n");
        } else {
            queryStrings.push(key);
        }
    }
    return string:'join(" \n ", ...queryStrings);
}

class DocumentBuilder {
    private string root;
    private map<graphql:fieldDocument> fields;
    private map<int|string>? args;

    public function init(string rootNode, map<graphql:fieldDocument> fields, map<int|string>? args = ()) {
        self.root = rootNode;
        self.fields = fields;
        self.args = args;
    }

    # Returns a query document as a string.
    # Ex:
    # root: "mission"
    # fields: { "designation": (), "crew": { "name": () } }
    # args: { "id": 1 }
    #
    # returns:
    # query {
    # mission(id: 1) {
    # designation}
    # crew {
    # name
    # }
    # }
    #
    # + return - The query document as a string
    public function getQueryString() returns string {
        string query = string `query {
            ${self.root}${self.getArgs()} {
                ${buildQueryString(self.fields)}
            }
        }`;
        return query;
    }

    private function getArgs() returns string {
        if !(self.args is ()) {
            string[] argStrings = [];
            foreach var [key, value] in (<map<int|string>>self.args).entries() {
                if (value is int) {
                    argStrings.push(key + ": " + value.toString());
                } else {
                    argStrings.push(key + ": \"" + value + "\"");
                }
            }
            return string `(${string:'join(", ", ...argStrings)})`;

        }
        else {
            return "";
        }

    }

}

