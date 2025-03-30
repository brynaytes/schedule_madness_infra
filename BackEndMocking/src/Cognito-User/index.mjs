import { CognitoIdentityProviderClient, UpdateUserAttributesCommand   } from "@aws-sdk/client-cognito-identity-provider"; // ES Modules import

export const handler = async (event) => {
  if(event.action === 'profile_update'){
    const client = new CognitoIdentityProviderClient();
    
    
    /*
    const input = { // UpdateUserAttributesRequest
      UserAttributes: [ // AttributeListType // required
        { // AttributeType
          Name: "address", // required
          Value: "place st",
        },
      ],
      AccessToken: event.access_token, // required
    };*/
    
    const input = {
      UserAttributes : event.data.UserAttributes,
      AccessToken: event.data.AccessToken
    }

  console.log(input);
    const command = new UpdateUserAttributesCommand(input, function(err, data) {
      if (err) console.log(err, err.stack); // an error occurred
      else     console.log(data);           // successful response
    });
    const response = await client.send(command);
    return response;
  }
};