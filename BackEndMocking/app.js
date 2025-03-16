import { handler } from './src/index.mjs'
import express from 'express';
import cors from 'cors'

//const express = require('express')
const app = express()
const port = 3000

app.use(express.json());


var corsOptions = {
  origin: '*',
  optionsSuccessStatus: 200 // some legacy browsers (IE11, various SmartTVs) choke on 204 
}
app.use(cors(corsOptions));


app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.post('/meetings', (req, res) => {
  let temp = {
    body: JSON.stringify(req.body),
    headers: {
      Authorization: req.get("Authorization")
    }
  }
  //The 'then' portion here waits for the async response to resolve
  handler(temp).then((temp) => {
    res.status(temp.statusCode)
    res.send((temp.body))
  }
  )
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
