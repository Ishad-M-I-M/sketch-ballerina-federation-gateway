import ballerina/graphql;

class QueryPropertyClassifier {

    // client for which the field peroperties are classified.
    private string clientName;

    // field name which the subfields get classified.
    private string fieldName;

    // resolvable fields are pushed to this.
    private graphql:Field[] resolvableFields;

    // unresolvable fields are pushed to the map along with the parentType name.
    // parent type name is needed to decide which type the subfield belongs for.
    private unResolvableField[] unresolvableFields;

    isolated function init(graphql:Field 'field, string clientName) {
        // initialize the class properties.
        self.clientName = clientName;
        self.resolvableFields = [];
        self.unresolvableFields = [];

        graphql:Field[]? subfields = 'field.getSubfields();

        string? fieldName = 'field.getUnwrappedType().name;

        // Panic if field object has no subfields or the unwrapped type has no name.
        if subfields is () || fieldName is () {
            panic error("Error: Invalid field object");
        }

        self.fieldName = fieldName;

        // iterate through all the 
        foreach var subfield in subfields {
            if self.isResolvable(subfield, fieldName, clientName) {
                self.resolvableFields.push(subfield);
            }
            else {
                self.unresolvableFields.push({
                    'field: subfield,
                    parent: fieldName
                });
            }

        }
    }

    public isolated function getPropertyString() returns string {
        // Return property string that can be fetched from the client given.
        // If no property is availble to fetch with given client return nil.

        string[] properties = [];
        foreach var 'field in self.resolvableFields {
            // if scalar push name to properties array.
            if 'field.getUnwrappedType().kind == "SCALAR" {
                properties.push('field.getName());
            }
            else {
                // Create a new classifier for the field.
                // classify and expand the unResolvableFields with the inner level.
                QueryPropertyClassifier classifier = new ('field, self.clientName);
                unResolvableField[] fields = classifier.getUnresolvableFields();
                self.unresolvableFields.push(...fields);

                // Get the inner property string and push it to the properties array.
                properties.push(string `${'field.getName()} { ${classifier.getPropertyString()} }`);
            }
        }

        // Push the key property even it is not requested.
        string key = queryPlan.get(self.fieldName).key;
        if properties.indexOf(key) is () {
            properties.push(key);
        }

        return string:'join(" ", ...properties);
    }

    public isolated function getResolvableFields() returns graphql:Field[] {
        return self.resolvableFields;
    }

    public isolated function getUnresolvableFields() returns unResolvableField[] {
        return self.unresolvableFields;
    }

    private isolated function isResolvable(graphql:Field 'field, string parentType, string clientName) returns boolean {
        // check wether the field is the key. Because key SHOULD be resolvable from any client.
        // OR the client name for resolving the field is equal to the given clientName.
        if 'field.getUnwrappedType().name == queryPlan.get(parentType).key ||
            queryPlan.get(parentType).fields.get('field.getName()).'client == clientName {
            return true;
        }
        else {
            return false;
        }
    }

}
