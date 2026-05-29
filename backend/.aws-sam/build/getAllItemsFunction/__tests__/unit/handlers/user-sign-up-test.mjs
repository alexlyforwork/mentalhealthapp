import { userSignUpHandler } from '../../../src/handlers/user-sign-up.mjs';
// Import dynamodb from aws-sdk 
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';
import { mockClient } from "aws-sdk-client-mock";
// This includes all tests for putItemHandler() 
describe('Test userSignUpHandler', function () { 
    const ddbMock = mockClient(DynamoDBDocumentClient);
 
    beforeEach(() => {
        ddbMock.reset();
      });
 
    // This test invokes putItemHandler() and compare the result  
    it('should add a new user to the table', async () => { 
        const returnedItem = { email: 'email1', name: 'name1', dob: 'dob1', contacts: 'contacts1' }; 
 
        // Return the specified value whenever the spied put function is called 
        ddbMock.on(PutCommand).resolves({
            returnedItem
        }); 
 
        const event = { 
            httpMethod: 'POST', 
            body: '{"email": "email1","name": "name1","dob": "dob1","contacts": "contacts1"}' 
        }; 
     
        // Invoke putItemHandler() 
        const result = await userSignUpHandler(event); 
        
        const expectedResult = { 
            statusCode: 200, 
            body: JSON.stringify(returnedItem) 
        }; 
 
        // Compare the result with the expected result 
        expect(result).toEqual(expectedResult); 
    }); 
}); 
 