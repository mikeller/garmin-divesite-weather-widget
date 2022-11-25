#!/usr/bin/env node

'use strict';

const fs = require('fs');
const http = require('http');
const debug = require('debug')('service:server');

const host = '0.0.0.0';
const port = normalizePort(process.env.PORT || 8080);

const rawData = fs.readFileSync('data.json');
const data = JSON.parse(rawData);

const requestListener = function (req, res) {
    res.setHeader('Content-Type', 'application/json');
    res.writeHead(200);
    res.end(JSON.stringify(data));

    debug(`Request headers\n${JSON.stringify(req.headers, null, 2)}`);
};

const server = http.createServer(requestListener);
server.on('error', onError);
server.on('listening', onListening);
server.listen(port);

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

function onError(error) {
  if (error.syscall !== 'listen') {
    throw error;
  }

  var bind = typeof port === 'string'
    ? 'Pipe ' + port
    : 'Port ' + port;

  // handle specific listen errors with friendly messages
  switch (error.code) {
    case 'EACCES':
      debug(bind + ' requires elevated privileges');
      process.exit(1);
      break;
    case 'EADDRINUSE':
      debug(bind + ' is already in use');
      process.exit(1);
      break;
    default:
      throw error;
  }
}

function onListening() {
  var addr = server.address();
  var bind = typeof addr === 'string'
    ? 'pipe ' + addr
    : 'port ' + addr.port;
  debug('Listening on ' + bind);
}
