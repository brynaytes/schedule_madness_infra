import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";

const secret_name = "scheduler-madness-dev-cognito-secret";

const client = new SecretsManagerClient({
  region: "us-east-1",
});

let response;

try {
  response = await client.send(
    new GetSecretValueCommand({
      SecretId: secret_name,
      VersionStage: "AWSCURRENT", // VersionStage defaults to AWSCURRENT if unspecified
    })
  );
} catch (error) {
  // For a list of exceptions thrown, see
  // https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
  throw error;
}

const secret =  JSON.parse(response.SecretString).local;

export const handler = async (event) => {
  
  console.log(event);
  console.log(secret);
  const origin = event.headers.origin + "/login"
  const code = event.pathParameters.code;
  var myHeaders = new Headers();
  myHeaders.append("Content-Type", "application/x-www-form-urlencoded");
  myHeaders.append("Authorization", "Basic "+secret);
  
  var urlencoded = new URLSearchParams();
  urlencoded.append("code", code);
  urlencoded.append("grant_type", "authorization_code");
  urlencoded.append("redirect_uri", origin);

  var requestOptions = {
    method: 'POST',
    headers: myHeaders,
    body: urlencoded,
    redirect: 'follow'
  };

 let test = await fetch("https://scheduler-madness-dev.auth.us-east-1.amazoncognito.com/oauth2/token/", requestOptions)
    .then(response => response.json())
    .then(result =>{ 
      console.log(result);
      return result;
    })
    .catch(error => console.log('error', error));
    
      
    return {
        "isBase64Encoded": false,
        "statusCode": 200,
        "headers": { 
          "Access-Control-Allow-Origin" : "*"
          },
        "body": JSON.stringify(test)
    }
};




