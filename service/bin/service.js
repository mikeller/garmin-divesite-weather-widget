#!/usr/bin/env node

'use strict';

const fs = require('fs');
const path = require('path');
const express = require('express');
const cookieParser = require('cookie-parser');
const fetch = require('make-fetch-happen').defaults({ cachePath: './cache' });
const tzlookup = require("@photostructure/tz-lookup");
const moment = require('moment-timezone');
const debug = require('debug')('service:server');

const locationForecastUrl = 'https://api.met.no/weatherapi/locationforecast/2.0/compact.json';
const projectUrl = 'https://github.com/mikeller/garmin-divesite-weather-widget';

const userAgentString = `${process.env.npm_package_name}/${process.env.npm_package_version} ${projectUrl}`;

const port = normalizePort(process.env.PORT || 8080);
const locationApiKey = process.env.LOCATION_API_KEY;
if (!locationApiKey) {
  debug('WARNING: LOCATION_API_KEY is not set. /locations will be unreachable (401). Set env to enable.');
}

const app = express();

// Middleware
app.use(cookieParser());
app.use(express.static(path.join(__dirname, '../public')));

/**
 * Express middleware that requires a valid API key stored in the `locationApiKey` cookie.
 *
 * If the cookie is missing or does not match the configured `locationApiKey`, responds with HTTP 401
 * and a JSON error body. Otherwise calls `next()` to continue request handling.
 */
function requireLocationApiKey(req, res, next) {
    const providedKey = req.cookies.locationApiKey;
    
    if (!locationApiKey || !providedKey || providedKey !== locationApiKey) {
        debug(`Unauthorized access attempt to ${req.path}. Provided key: ${providedKey ? 'present but invalid' : 'missing'}`);
        return res.status(401).json({ error: 'Unauthorized. Valid API key required in cookie.' });
    }
    
    next();
}

var totalRequests = 0;
var locations = new Map();
var totalApplicationErrors = 0;
var totalNotFoundErrors = 0;

app.get('/data', getData);

app.get('/locations', requireLocationApiKey, (req, res) => {
    debug('Locations endpoint accessed');
    
    res.set('Cache-Control', 'no-store');

    const locationsList = [];
    
    for (const [locationKey, data] of locations.entries()) {
        const [lat, lon] = locationKey.split('/');
        locationsList.push({
            latitude: parseFloat(lat),
            longitude: parseFloat(lon),
            request_count: data.count,
            last_requested: data.lastRequested.toISOString()
        });
    }
    
    // Sort by request count (descending) then by last requested (most recent first)
    locationsList.sort((a, b) => {
        if (b.request_count !== a.request_count) {
            return b.request_count - a.request_count;
        }
        return new Date(b.last_requested) - new Date(a.last_requested);
    });
    
    res.json({
        total_unique_locations: locations.size,
        total_requests_all_locations: locationsList.reduce((sum, loc) => sum + loc.request_count, 0),
        locations: locationsList
    });
});

app.get('/status', (req, res) => {
    res.json({
        status: 'ok',
        uptime: process.uptime(),
        requests: totalRequests,
        locations: locations.size,
        application_errors: totalApplicationErrors,
        not_found_errors: totalNotFoundErrors,
    });
});

app.get('/', (req, res) => {
    res.redirect(projectUrl);
});

app.use((req, res, next) => {
    debug(`Invalid path: ${req.url}`);

    totalNotFoundErrors++;

    res.status(404).json({ error: 'Not found' });
});

app.listen(port, () => {
    debug(`Listening on port ${port}.`);
});

/**
 * Handle GET /data requests: validate lat/lon query, update request statistics, fetch and return transformed data.
 *
 * Validates that the request query contains exactly `lat` and `lon`, checks their numeric format and geographic ranges,
 * and responds with HTTP 400 via `returnBadRequest` on invalid input. On valid input, increments `totalRequests`,
 * updates the `locations` map (per-location `{ count, lastRequested }`), calls `fetchData(latitude, longitude)`,
 * sets the response `Expires` header from `result.properties.meta.expires`, and returns the JSON payload.
 * Any errors from `fetchData` are forwarded to Express via `next(error)`.
 *
 * Note: This function sends HTTP responses and mutates module-level state (`totalRequests`, `locations`).
 *
 * @returns {Promise<void>} Resolves after a response is sent or an error is forwarded to `next`.
 */
async function getData(req, res, next) {
    //debug(`Request headers:${JSON.stringify(req.headers, null, 2)}`);
    debug(`Request query:${JSON.stringify(req.query, null, 2)}`);

    totalRequests++;

    if (Object.keys(req.query).length !== 2 || !Object.hasOwn(req.query, 'lat') || !Object.hasOwn(req.query, 'lon')) {
        debug(`Invalid URL parameters: ${req.url}`);

        returnBadRequest(req, res, next);

        return;
    }

    let latitude = req.query.lat;
    let longitude = req.query.lon;

    const latitudeRegExp = /^[+-]?\d{1,2}(\.\d{1,3})?$/;
    const longitudeRegExp = /^[+-]?1?\d{1,2}(\.\d{1,3})?$/;
    if (isNaN(parseFloat(latitude)) || !latitudeRegExp.test(latitude) || isNaN(parseFloat(longitude)) || !longitudeRegExp.test(longitude)) {
        debug(`Invalid lat (${latitude}) or lon (${longitude}) parameter format.`);

        returnBadRequest(req, res, next);

        return;
    }

    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
        debug(`Lat (${latitude}) or lon (${longitude}) out of range.`);

        returnBadRequest(req, res, next);

        return;
    }

    const latKey = parseFloat(latitude).toFixed(3);
    const lonKey = parseFloat(longitude).toFixed(3);
    const locationKey = `${latKey}/${lonKey}`;
    const existingLocation = locations.get(locationKey);
    if (existingLocation) {
        existingLocation.count++;
        existingLocation.lastRequested = new Date();
    } else {
        locations.set(locationKey, { count: 1, lastRequested: new Date() });
    }

    try {
        let result = await fetchData(latitude, longitude);

        res.set('expires', result.properties.meta.expires.toDate().toUTCString());
        res.json(result);
    } catch (error) {
        next(error);
    }
}

async function fetchData(latitude, longitude) {
    let expires;
    return fetch(`${locationForecastUrl}?${new URLSearchParams({ lat: latitude, lon: longitude })}`, {
        headers: {
            "User-Agent": userAgentString,
        },
    })
        .then(response => {
            debug(`Weather API response headers: ${JSON.stringify(Object.fromEntries(response.headers.entries()), null, 2)}`);

            if (response.headers.has('expires')) {
                expires = moment(response.headers.get('expires'));
            }

            return response.json();
        })
        .then(response => {
            return transformResponse(response, expires);
        })
        .catch(error => {
            throw error
        });
}

function transformResponse(response, expires) {
    let timezone = tzlookup(response.geometry.coordinates[1], response.geometry.coordinates[0]);
    debug(`Local timezone: ${timezone}`);

    let days = {};
    for (const entry of response.properties.timeseries) {
        let localTime = moment(entry.time).tz(timezone);
        let hour = localTime.hour();

        if (hour >= 6 && hour <= 18) {
            let day = getDay(localTime, days);

            day.max_air_temperature = Math.max(day.max_air_temperature || -Infinity, entry.data.instant.details.air_temperature);
            let windSpeed = entry.data.instant.details.wind_speed;
            if (windSpeed && (!day.max_wind_speed || windSpeed > day.max_wind_speed)) {
                day.max_wind_speed = windSpeed;
                day.max_wind_from_direction = entry.data.instant.details.wind_from_direction;
            }
        }

        if (hour >= 1 && hour < 12) {
            let overlap = 6 - Math.abs(hour - 6);
            if (Object.hasOwn(entry.data, 'next_6_hours')) {
                let day = getDay(localTime, days);
                if (overlap > ((day.morning ??= {}).overlap || 0)) {
                    day.morning.symbol_code = entry.data.next_6_hours.summary.symbol_code;
                    day.morning.overlap = overlap;
                }
            }
        }

        if (hour >= 7 && hour < 18) {
            let overlap = 6 - Math.abs(hour - 12);
            if (Object.hasOwn(entry.data, 'next_6_hours')) {
                let day = getDay(localTime, days);
                if (overlap > ((day.afternoon ??= {}).overlap || 0)) {
                    day.afternoon.symbol_code = entry.data.next_6_hours.summary.symbol_code;
                    day.afternoon.overlap = overlap;
                }
            }
        }
    }

    response.properties.timeseries = Object.entries(days)
        .sort(([timestamp1, data1], [timestamp2, data2]) => moment(timestamp1).isBefore(timestamp2))
        .map(([timestamp, day]) => {
            let entry = {};
            entry.time = timestamp;

            day.morning_symbol_code = day.morning?.symbol_code;
            delete day.morning;
            day.afternoon_symbol_code = day.afternoon?.symbol_code;
            delete day.afternoon;

            entry.data = day;

            return entry;
        });

    response.properties.meta.expires = expires;
    delete response.properties.meta.units;

    return response;
}

function getDay(localTime, days) {
    let midnight = localTime.startOf('day');

    return (days[midnight.format()] ??= {});
}

function returnBadRequest(req, res, next) {
    totalApplicationErrors++;

    res.status(400).json({ error: 'Bad request' });
}

function normalizePort(val) {
  let port = parseInt(val, 10);

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
