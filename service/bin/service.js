#!/usr/bin/env node

'use strict';

const fs = require('fs');
const express = require('express');
const debug = require('debug')('service:server');

const port = normalizePort(process.env.PORT || 8080);

const rawData = fs.readFileSync('public/data.json');
const data = JSON.parse(rawData);

const app = express();

app.get('/data', (req, res, next) => {
    debug(`Request headers:\n${JSON.stringify(req.headers, null, 2)}`);
    debug(`Request query:\n${JSON.stringify(req.query, null, 2)}`);

    if (Object.keys(req.query).length !== 2 || !Object.hasOwn(req.query, 'lat') || !Object.hasOwn(req.query, 'lon')) {
        returnBadRequest(req, res, next);

        return;
    }

    res.json(data);
});

function returnBadRequest(req, res, next) {
    debug(`Invalid request: ${req.url}`);

    next(Object.assign(new Error(), { status: 400 }));
}

app.get('/', (req, res) => {
    res.redirect('https://github.com/mikeller/garmin-divesite-weather-widget');
});

app.use((req, res, next) => {
    debug(`Invalid URL: ${req.url}`);

    next(Object.assign(new Error(), { status: 404 }));
});

app.listen(port, () => {
    debug(`Listening on port ${port}.`);
});

function normalizePort(val) {
  var port = parseInt(val, 10);

  if (isNaN(port)) {
    // named pipe
    return val;
  }

  if (port >= 0) {
    // port number
    return port;
  }

  return false;
}
