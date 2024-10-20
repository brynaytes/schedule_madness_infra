import { handler } from './src/index.mjs' 
import express from 'express';

//const express = require('express')
const app = express()
const port = 3000

app.use(express.json());

app.get('/', (req, res) => {
  res.send('Hello World!')
})

 app.post('/meetings', (req, res) => {
    //The 'then' portion here waits for the async response to resolve
    handler(req.body).then((temp) => res.send(temp ))
  })

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
