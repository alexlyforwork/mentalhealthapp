
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, ScanCommand } from '@aws-sdk/lib-dynamodb';
const client = new DynamoDBClient({});
const ddbDocClient = DynamoDBDocumentClient.from(client);

// Get the DynamoDB table name from environment variables
const tableName = process.env.SAMPLE_TABLE;

export const userSignUpHandler = async (event) => {
    if (event.httpMethod !== 'POST') {
        throw new Error(`userSignUp only accept POST method, you tried: ${event.httpMethod}`);
    }
    // All log statements are written to CloudWatch
    console.info('received:', event);

    const body = JSON.parse(event.body);
    const email = body.email;
    const name = body.name;
    const dob = body.dob;
    const contacts = body.contacts;

    var params = {
        TableName : tableName,
        Item: { email : email, name: name, dob: dob, contacts: contacts }
    };

    try {
        const data = await ddbDocClient.send(new PutCommand(params));
        console.log("Success - item added or updated", data);
    } catch (err) {
        console.log("Error", err);
    }

    const response = {
        statusCode: 200,
        body: "You have successfully signed up."
    };

    // All log statements are written to CloudWatch
    console.info(`response from: ${event.path} statusCode: ${response.statusCode} body: ${response.body}`);
    return response;
}
