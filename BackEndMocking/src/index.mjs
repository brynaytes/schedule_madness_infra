import {  DynamoDBClient,GetItemCommand } from "@aws-sdk/client-dynamodb";
import { PutCommand, DynamoDBDocumentClient,QueryCommand } from "@aws-sdk/lib-dynamodb";
import { CognitoIdentityProviderClient, GetUserCommand } from "@aws-sdk/client-cognito-identity-provider";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

export const handler = async (event) => {
  let eventBody = JSON.parse(event.body);
  let authToken = event.headers.Authorization;
  let body;
  let userID;

  if(authToken){
    userID = await doAuth(authToken);
    if(!userID){
      const response = {
        statusCode: 401,
        body: ("Auth Token was invalid or missing."),
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*' // replace with hostname of frontend (CloudFront)
        },
      };
      return response;
    }
  }


  switch(eventBody.action){
    case "createMeeting" : 
      body = await  createMeeting(eventBody.data,userID);
      break;
    case "getMeeting" : 
      body = await  getMeetings( event.data.meetingID);
      break;
    case "addTimes" : 
      body = await  addTimes(eventBody.data,userID);
      break;
    case "getMeetingList" : 
      body = await  getMeetingList(userID);
      break;
    case "getMeetingAvailabilityList":
      body = await  getMeetingAvailabilityList(eventBody.data.meetingID);
      break;
    default:
      body = "unknown action sent";
      break;
    }

    const response = {
      statusCode: 200,
      body: (JSON.stringify(body)),
      headers: { 
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*' // replace with hostname of frontend (CloudFront)
      },
    };
  return response;
};

async function createMeeting(data,userID){

  if(!userID || userID == ""){
    return "Authentication is required for this request";
  }
  let meetingID = Date.now() + Math.floor(Math.random() *100)+"" ;//needs to become true random
  const command = new PutCommand({
    TableName: "MeetingInfo",
    Item: {
      MeetingID: meetingID,
      UserID : userID,
      data : data
    },
  });

  await docClient.send(command);
  return {meetingID : meetingID};
}

async function getMeetings(meetingID){
  var command = new QueryCommand({
    ExpressionAttributeValues: {
     ":mid": meetingID
    }, 
    ExpressionAttributeNames: {
        "#MeetingID": "MeetingID"
    },
    KeyConditionExpression: "#MeetingID = :mid", 
    TableName: "MeetingInfo"
  });

  let temp = await docClient.send(command);
    return temp.Items[0];
}

async function addTimes(data,userID){
  //Auth optional
  let meetingID =  data.MeetingID;
  let DateTimeID =  Date.now() + Math.floor(Math.random() *100)+"" ;//needs to become true random

  const command = new PutCommand({
    TableName: "MeetingAvailability",
    Item: {
      MeetingID: meetingID,
      UserID : userID,
      DateTimeID : DateTimeID,
      data : data
    },
  });

  await docClient.send(command);
  return {meetingID : meetingID};
}

async function getMeetingList(userID){
  if(!userID || userID == ""){
    return "Authentication is required for this request";
  }

  var command = new QueryCommand({
    ExpressionAttributeValues: {
     ":uid": userID
    }, 
    ExpressionAttributeNames: {
        "#UserID": "UserID"
    },
    KeyConditionExpression: "#UserID = :uid", 
    TableName: "MeetingInfo",
    IndexName : "UserID-MeetingID-index"
  });
  
  let meetingsList = await docClient.send(command);
  
  let list = meetingsList.Items.map((meeting) => {
    return {
      meetingID : meeting.MeetingID,
      title : meeting.data.title,
      description : meeting.data.description
    }
  })
  
  return list;
}

async function getMeetingAvailabilityList(MeetingID){
  var command = new QueryCommand({
    ExpressionAttributeValues: {
     ":mid": MeetingID
    }, 
    ExpressionAttributeNames: {
        "#MeetingID": "MeetingID"
    },
    KeyConditionExpression: "#MeetingID = :mid", 
    TableName: "MeetingAvailability"
  });
  
  let meetingsList = await docClient.send(command);
  let meetingInfo = await  getMeetings(MeetingID);
  let list;
  if(meetingsList.Items.length != 0){
    list = meetingsList.Items[0].data.dateTimes;
    
    for(let i=0; i < meetingsList.Items.length; i++){
      for(let o=0; o < meetingsList.Items[i].data.dateTimes.length; o++){
        for(let p=0; p < meetingsList.Items[i].data.dateTimes[o].times.length; p++){
          if(meetingsList.Items[i].data.dateTimes[o].times[p].isAvailable){
            //adds available users object if needed
            if(!Object.hasOwn(list[o].times[p], 'availableUsers')){
              list[o].times[p].availableUsers = [];
            }
            list[o].times[p].availableUsers.push(meetingsList.Items[i].data.name);
          }
        }
      }
    }
  }else{
    list = meetingInfo.data.dateTimes;
  }
  
  let obj = {
    title : meetingInfo.data.title,
    description : meetingInfo.data.description,
    dateTimes : list
  }
  
  return obj;
}

async function doAuth(authToken){
    const client = new CognitoIdentityProviderClient({});
    const input = { // GetUserRequest
      AccessToken: authToken, // required
    };
    let response;
    const command = new GetUserCommand(input);
    try{
      response = await client.send(command);
    }catch(e){
        return false;
    }
    let temp = response.UserAttributes.find(obj => {return obj.Name === 'sub'}).Value;
    return temp
  }



