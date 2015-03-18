# Panatrans API

API for the public bus tranportation system of Ciudad de Panamá (Panamá).

## About
Panatrans is a collaborative project to allow the users of the panamenian public transport to create a dataset with the information of the stops and routes available in the City of Panama (which is currently inexistent).

This project is based in the premise that open software and open data are the key of innovation.

Related Projects that may interest you:

1. __[panatrans-dataset](https://github.com/merlos/panatrans-dataset)__: dataset to be used with this API.
2. __[panatrans-web](https://github.com/merlos/panatrans-web)__: A javascript web client and editor that makes usage of this API.


# API Specification V1.0 beta
Specification for developers that plan to make a service or a mobile application based on this API.

## Conceptual model 

This API relies in a schema that is an extreme simplification of the [General Transit Feed Specification (GTFS)](https://developers.google.com/transit/gtfs/) defined by Google. 

![Conceptual model of a route](http://www.merlos.org/panatrans-api/conceptual_route.png "Conceptual model of a route")

There are 4 types of resources to represent a route (models, data types, objects or whatever you):

* __Stop__: Represents a bus stop. Includes a name and the (latitude, longitude) tuple.

* __Route__: Represents a bus route, for example: the route from Albrook to Miraflores.

* __Trip__: A route generally has one or two trips. For example, the route Albrook - Miraflores has two trips: (1) the trip from Albrook to Miraflores, and (2) the trip from Miraflores to Albrook. Each trip has a set of stops that may be the same or not. There may be some routes that only have a single trip (ie: circular routes or those that start and end at the same location). 

* __Stop_Sequence__: Links a trip with a stop to create an ordered list of stops. In the example, the trip Albrook to Miraflores has 4 stops, and therefore it has 4 `stop_sequences`, each one will link one of the stops with that trip. The first stop is Albrook (sequence = 0), then Diablo (sequence = 1), Ciudad del Saber (sequence = 2) and the last one Miraflores (sequence = 3).

In any call to the API you'll be requesting any of these resources. 

## Common stuff in API Responses

In every API response there is a "status". Possible values are:

1. `success`. Response data will be set in `data`. HTTP response is always 200 (success). Example:

	<!-- curl -X http://test-panatrans.herokuapp.com/v1/routes/ -->

	```json
	{
	"status":"success",
	"data":[
		{"id":1048002442,"name":"Albrook-Marañón"},
		{"id":219448156,"name":"Vía Brasil-Federico Boyd"}]
	}
	```

2. `fail`, there was a problem performing the operation (ie: incorrect value while creating or updating a resource). The list of problems is passed throught the `errors` object. Example:

	<!-- curl -X POST --data "stops[name]=2" http://test-panatrans.herokuapp.com/v1/stops/-->
	```json
	{
	  "status":"fail",
	  "errors": {
		"lat":["can't be blank","is not a number"],
		"lon":["can't be blank","is not a number"]
		}
	}
	```


3. `<number>`, where number is an HTTP error (ie: 404 not found. The error string is passed through `error`. HTTP response status is != 200. 

	```json
	{
		"status":"404",
		"error":"Not Found"
	}
	```

## ROUTES

### GET /routes/
Gets all the routes ordered by name (alphabetical order)

```
{
  "status" : "success",
  "data" : [{ 
    "id" : INT,       # 1
    "name" : STRING,  # "Albrook - Exclusas de Miraflores"
    },
    ...
    ]
  }
}
``` 
Example:
http://test-panatrans.herokuapp.com/v1/routes/?prettify=true

---
__HINT!__ In any request to the api, if you add to the query string the param `?prettify=true`, the output will be a human readable JSON with indentantion and that kind of stuff. Example: `http://panantransserver.org/v1/routes/?prettify=true` 

---

### GET /routes/with_trips
Gets all the routes ordered alphabetically by name and includes the trips linked to each route.

```
{
	"status" : "success"
	"data" : [{
		"id" : INT,             #route id
		"name" : STRING,        # "Route name"
		"trips" : [{
			"id": INT,            # trip id
			"headsign": STRING,   # "hacia Albrook"
			"direction": INT,     # 0=ida, 1= retorno
		   }, ...
		]}, ...
	 ]	
   }
}			
```
Example: 

[https://test-panatrans.herokuapp.com/v1/routes/?prettify=true](https://test-panatrans.herokuapp.com/v1/routes/?prettify=true)

### GET /routes/:id
Returns the detail of the route identified by `:id`.

```
{
  "status" : "success"
  "data" :  {
  "id" : INT                  # route id
  "name" : STRING             # "Albrook - Exclusas de Miraflores" 
  "trips" : [
    {
      "id" : INT              # 2, trip id
      "headsign" : STRING,    # "Hacia Miraflores"
      "direction" : INT,      # 0 =  ida, 1 = retorno
      "stop_sequences" : [{
        "id" : INT,           # stop_sequence id
        "sequence" : INT      # first is 0
        "stop" : {
        	"id" : INT,         # stop id
        	"name" : STRING,    # "Albrook"
        	"lat" : LATITUDE,   # "8.9740946"
        	"lon" : LONGITUDE   # "-79.5508536"
        	}
        },
        ...
      ]
    },
    ...
  ]
}
``` 
* `LATITUDE` is a float within the interval (-90, 90).
* `LONGITUDE` is a float within the interval (-180, 180).

Note: in the response latitude and longitude are enclosed in `""`.

Example: 

[http://test-panatrans.herokuapp.com/v1/routes/1048002442?prettify=true](http://test-panatrans.herokuapp.com/v1/routes/1048002442?prettify=true)


### POST /routes/
Creates a new route

Post data structure:

```
{
 "route": {
 	"name":  STRING;
}
```

If the request is successful, it returns the route detail of the new created resource (ie: same as GET /routes/:id).

### DELETE /routes/:id
Deletes the route with the id `:id`.

The response is an HTTP code 200 (success) and an empty response body if the resource was sucessfully deleted. 

### PUT /routes/:id
Updates a route.

PUT data structure:
```
"route" {
	"name": STRING
}
```

If the request is successful, it returns the route detail of the updated resource (ie: same as GET /routes/:id).

## STOPS

#### GET /stops/
Gets all stops

```
{
  "status": "success",
  "data": [
    {
      "id": INT,        # 1
      "name": STRING    # "Albrook",
      "lat": LATITUDE   #"8.974095",
      "lon": LONGITUDE  #"-79.550854"
    },...
  ]
 }


```
Example:

[http://test-panatrans.herokuapp.com/v1/stops/?prettify=true](http://test-panatrans.herokuapp.com/v1/stops/?prettify=true)


### GET /stops/:id
Returns the detail of a stop with id `:id`.

```
{
  "status": "success",
  "data": {
    "id": INT,
    "name": STRING             # "Albrook",
    "lat": LATITUDE            # "8.974095",
    "lon": LONGITUDE           # "-79.550854",
    "routes": [
      {
        "id": INT,
        "name": STRING         # "Albrook-Marañón",
        "trips": [
          {
            "id": INT,
            "headsign": STRING # "hacia Marañón",
            "direction": INT   # 0=> ida/circular, 1=> vuelta,
            "route_id": INT    # 1048002442
          },
          ...
         ] 
      },
      ...
    ] 
  } 
}
```
Example:

[http://test-panatrans.herokuapp.com/v1/stops/382818451?prettify=true](http://test-panatrans.herokuapp.com/v1/stops/382818451?prettify=true)

### GET /v1/stops/nearby/?lat=LATITUDE&lon=LONGITUDE&radius=METERS
Gets the stops in the surroundings of the center `(lat, lon)` within the `radius` (in meters). 

```
{
  "status": "success",
  "data": [
    {
      "id": INT,       # stop_id
      "name": STRING   # stop name "Policía Nacional",
      "lat": LONGITUDE # "8.965629",
      "lon": LATITUDE  # "-79.549224",
      "distance": INT  # meters from requested point.
    },
   ]
 }
```
The response returns the stops ordered by ascendent distance.

Example: Get stops close to the point (8.9656294,-79.5492239) and within a radius of 1000m (1km):

http://test-panatrans.herokuapp.com/v1/stops/nearby?lat=8.9656294&lon=-79.5492239&radius=1000&prettify=true


### POST /stops/
Creates a new stop

Request data structure: 
```
{
 "stop" {
 	 "name": STRING,
 	 "lat": LATITUDE,
 	 "lon": LONGITUDE
 }
}
```

If the request is successful, it returns the stop detail of the new created stop (GET /stop/:id).


### PUT /stops/:id
Updates the stop with the `:id` setting up the values of the request data.

Request data structure: 

```
{
 "stop" {
 	 "name": STRING,
 	 "lat": LATITUDE,
 	 "lon": LONGITUDE
 }
}
```

If the request is successful, it returns the stop detail of the updated resource (ie: same response as `GET /stops/:id`).



### DELETE /stops/:id
Deletes the stop with the id `:id`.

If the resource was sucessfully deleted, the response is an HTTP code 200 (success) and an empty response body . 


## TRIPS

#### GET /trips/
Gets all trips.

```
{
 "status": "success",
  "data": [
    {
      "id": INT,          # trip id
      "headsign": STRING  # "hacia Albrook",
      "direction": 1,     # 
      "route": {          # route this trip belongs to.
        "id": INT,        # route id
        "name":           # route name: "Albrook-Panamá Viejo"
      }
    },
	...
  ]
}
```

Example:

[http://test-panatrans.herokuapp.com/v1/trips?prettify=true](http://test-panatrans.herokuapp.com/v1/trips?prettify=true)


### GET /trips/:id
Gets the detail of the trip with id `:id`. The sequence of stops is returned ordered by sequence number. 

A __stop without sequence__ number means that the stop belongs to that trip but the order within the same is unknown. 

```
{
  "status": "success",
  "data": {
    "id": INT,           # trip id
    "headsign": STRING   # trip headsign "hacia Marañón",
    "direction": 0,      # trip direction, 0=>go 1=> return
    "route": {
      "id": INT,      # route id
      "name": STRING, # route name "Albrook-Marañón"
    },
    "stop_sequences": [
      {
        "id": INT,        # Stops sequence id
        "sequence": 0,    # sequence Number
        "stop": {         
          "id": INT,        # stop id
          "name": STRING    # "Albrook",
          "lat": LATITUDE   # "8.9740946",
          "lon": LONGITUDE  #"-79.5508536"
        }
      },
      ...
      }
    ]
  }
}
```

Example:
[http://test-panatrans.herokuapp.com/v1/trips/1048002442?prettify=true](http://test-panatrans.herokuapp.com/v1/trips/1048002442?prettify=true)

#### POST /trips/
Creates a new trip.

Post data structure:
```
{
  "trip": {
  	headsign: STRING,  # "hacia Albrook", "Circular", ...
  	direction: INT, 
  	route_id: INT, # id of the route the trip belongs to
}
```

If the request is successful, it returns the trip detail of the new created resource (`GET /trips/:id`).


#### PUT /trip/:id
Updates an existing trip

Post data structure:

```
{
  "trip": {
  	"headsign": STRING,
  	"direction": INT 
  }
}
```

If the request is successful, it returns the trip detail of the updated resource (ie: same response as `GET /trips/:id`).


#### DELETE /trips/:id
Deletes the trip with the id `:id`.

The response is an HTTP code 200 (success) and an empty response body if the resource was sucessfully deleted. 



## STOP_SEQUENCES
Stops sequences link stops to trips. 

#### GET /stop_sequences/
Gets all stops_sequences

```
{
  "status": "success",
  "data": [
    {
      "id": 13110989,
      "sequence": 3,
      "stop_id": 382818451,
      "trip_id": 665778822
    },...
  ]
}
```
Example:

http://test-panatrans.herokuapp.com/v1/stop_sequences?prettify=true


#### GET /stop_sequences/:id
Gets the details of a stop_sequence

The first stop in a trip has `sequence = 0`.

`stop_sequence.sequence = nil`, means that the order of this stop within the trip is unknown. It may happen that the stop was added to the trip, but it wasn't known the position.

```
{
  "status": "success",
  "data": {
    "id": INT,        # stop_sequence id
    "sequence": INT,  # position in the trip
    "stop": {
      "id": INT,         # stop id
      "name": STRING,    # "Albrook",
      "lat": LATITUDE,   # "8.974095",
      "lon": LONGITUDE   # "-79.550854"
    },
    "trip": {
      "id": INT,         # trip_id
      "headsign": STRING # "hacia Miraflores",
      "direction": INT,  # 
      "route": {         
        "id": INT,       # route id
        "name":          # "Albrook-Miraflores"
      }
    }
  }
}
```

Example:

http://test-panatrans.herokuapp.com/v1/stop_sequences/396371388?prettify=true

### POST /stops_sequences/
Creates a new stop sequence.

POST structure:

```
stop_sequence: {
	sequence: INT,
  unkown_sequence: BOOL, # true = ignores `sequence` and sets it to nil
  trip_id: INT,          # id of the stop to link to the trip
  stop_id: INT           # id of the trip to link the stop.
}
```
If the request is successful, it returns the stop sequence detail of the new created resource (i.e: `GET /stop_sequence/:id`).


#### PUT /stops_sequences/:id
Updates a stops sequence.

PUT structure, all the values are optional

```
stop_sequence: {
	sequence: INT,
  unkown_sequence: BOOL, # true = ignores `sequence` and sets it to nil
  trip_id: INT,          # id of the stop to link to the trip
  stop_id: INT           # id of the trip to link the stop.
}
```

If the request is successful, it returns the stop sequence detail of the updated resource (ie: same response as `GET /stop_sequences/:id`).


#### DELETE /stops_sequences/:id
Removes a stop sequence.

The response is an HTTP code 200 (success) and an empty response body if the resource was sucessfully deleted. 


#### DELETE /stop_sequences/trip/:trip_id/stop/:stop_id
Deletes the stop_sequence that links the trip identified by `trip_id` and the stop identified by `stop_id`.

The response is an HTTP code 200 (success) and an empty response body if the resource was sucessfully deleted. 


## Export Calls

There is a set of calls to get the resources that have been created or changed since a particular date.

These calls are useful either to get a full database dump or to keep track of the hanges changes in the server database (incremental upates, monitoring).

The format is the following: 

```
GET /v1/:resource/since/:seconds_since_epoc(.csv)
```

Where 

* `:resource` can be `stops`,`routes`, `trips` or `stop_sequences`

* `:seconds_since_epoc` is the number of seconds since 1970-01-01 00:00:00 UTC. You can run the command `date +%s`to get the current number of seconds.

* `.csv`: optional parameter to get the dump in CSV format.

Example: 

```
# make a dump of the database in CSV
GET /v1/stops/since/0.csv
GET /v1/routes/since/0.csv
GET /v1/trips/since/0.csv
GET /v1/stop_sequences/since/0.csv
```


# Setting up your panatrans API server

The API has been developed in Ruby on Rails. It has been tested using Ruby 2.1.2 and Rails 4.1.6.


## Setup: short version
To create a local version of the server API run these commands: 

```
 $ git clone https://github.com/merlos/panatrans-api.git
 $ cd panatrans-api
 $ bundle install
 $ rake db:migrate
 $ rake dataset:update
 $ rails server
```
 
Now you can open your browse at `http://localhost:3000/v1/`, and you'll see the list of API calls available.

You may also want to check the [panatrans-web project](https://github.com/merlos/panatrans-web), that is a web client/editor that makes usage of this API.

## Setup: step by step

#### 1. Download

To get the source code: 

```
$ git clone https://github.com/merlos/panatrans-api.git
```

Then, install dependencies

```
$ bundle install
```

#### Database creation and initialization

To create the database run the migrations:

```
  $ rake db:migrate
``` 

Then, you can: 

1. Load latest version of the panatrans-dataset:

	```
	$ rake dataset:update
	```

2. Initialize the database with test data:

	```
	$ rake dataset:fixtures
	```
	
	The loaded data is stored in `tests/fixtures/` in Yaml format.

3. Import your own data. First, leave a copy of the csv files in the directory `./tmp/dataset/`. (see [panatrans-dataset](https://github.com/merlos/panatrans-dataset) project, for more info). Then import it:

	```
	$ rake dataset:import
	```

	Please note, that these files are overwritten if you perform a `rake dataset:update` or `rake dataset:download`. 

### Launch the server

```
$ rails server
```
This will launch a server in localhost:3000. All the API calls are at the /v1/ path, so you can open your browser on:

```
http://localhost:3000/v1/
```

And you`ll get a list of available API calls.

## Rake tasks

This is the list of custom rake tasks developed for the project:

```
rake dataset:download                   # downloads dataset from git (TODO options: DATASET_GIT_URL=github.com/merlos/panatrans-dataset, DATASET_DIR=./tmp/dataset, DATASET_GIT_BRANCH=master]
rake dataset:fixtures                   # Loads development fixtures in current environment database (clears database)
rake dataset:import                     # imports dataset csv files into database (db not cleared) (TODO options: DATASET_DIR=./tmp/dataset/)
rake dataset:reset                      # clears the database and then imports last downloaded csv files
rake dataset:update                     # updates dataset
```

To get a complete list of rake tasks run `rake -T`


#### How to run the test suite

The project includes a set of tests which use the default testing suite that comes with rails (minitest). 
To run the tests:

```
  $ rake test
```
More about [test a rails app](http://guides.rubyonrails.org/testing.html).

#### Fixtures

Fixtures are stored in `tests/fixtures`.

To load the sample data in your development environment run:

```
rake dataset:fixtures
```
[More info about fixtures](http://guides.rubyonrails.org/testing.html#the-low-down-on-fixtures).


## Changelog
1. V1.0 beta. March 2015. First version.


# License

Distributed under the MIT License (MIT)

Copyright (c) 2015 Juan M. Merlos

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.