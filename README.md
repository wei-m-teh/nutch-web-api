# nutch-web-api 
![travis ci build status](https://travis-ci.org/wei-m-teh/nutch-web-api.svg?branch=master)

## What is it
**nutch-web-api** is a RESTFul API implementation for apache Nutch crawling application. 
This project is completely written in node.js and coffeescript with the goal of simplifying usage and for improved flexibility. The REST API is not a replacement for apache nutch application, it simply provides the web interface for the nutch commands.

## Installation
### Prerequisites
#### Apache Nutch Application
nutch-web-api requires that apache nutch application be installed and running on the same server. For more information about downloading and getting started for apache nutch, please refer to http://nutch.apache.org. 

#### Node.js
node.js is required to get the web application up and running. For more information about installing node.js for your platform, please visit http://nodejs.org/download/.

###Downloading Source And Install Dependencies
- git clone https://github.com/wei-m-teh/nutch-web-api
- npm install

## Initial Project Setup
#### Environment Variables
By default, the project expects the following environment variables available in the environment:
 
- **NUTCH_HOME**
- **JAVA_HOME** 

These environment variables can be overwritten in conf/env-<environment>.json file. (An example is provided for the test, dev environments). 
Additionally, **NUTCH_OPT** environment variable will be picked up as additional options required to run nutch application. This variable can also be overwritten by specifying it in conf/env.json. Other variables used by nutch-web-application is as followed:

- **NUTCH-REST-API-SERVER_HOST**
- **NUTCH-REST-API-SERVER_PORT**
- **NUTCH-REST-API-SOLR_URL **

## Starting And Stopping The Server
### Start nutch-web-api
Execute the npm command to start the web application:

```npm start```

### Stop nutch-web-api
```npm stop```

## Supported HTTP Operations
nutch-web-api supports the crawler job that performs all the nutch jobs in one call, and individual nutch job for clients who wants to invoke nutch job individually.

### Invoke Nutch Crawler Job
This API executes all the individual nutch jobs in the following order:
- inject, generate, fetch, parse, updatedb, solr index, solr delete duplicates
Any failure encountered during the processing of these jobs will result in the job failure.

- HTTP Method: **POST** 
- Rest Endpoint: http://localhost:4000/nutch/crawl
- Sample Request Payload:
```
{
  "identifier" : "sampleCrawl", 
  "limit" : 5,
  "seeds" : [ "http://mysite1.com", "http://mysite2.com ]
}
```

### Invoke Nutch Injector Job
- HTTP Method: **POST** 
- Rest Endpoint: http://localhost:4000/nutch/inject
- Sample Request Payload:
```
{
  "identifier" : "sampleCrawl"
}
```

### Invoke Nutch Generator
- HTTP Method: **POST** 
- Rest Endpoint: http://localhost:4000/nutch/generate
- Sample Request Payload:
```
{
  "identifier" : "sampleCrawl",
  "batchId: "12134343"
}
```

### Invoke Nutch Fetcher
- HTTP Method: **POST** 
- Rest Endpoint: http://localhost:4000/nutch/fetch
- Sample Request Payload:
```
{
  "identifier" : "sampleCrawl",
  "batchId: "12134343"
}
```

### Invoke Nutch Parser
- HTTP Method: **POST** 
- Rest Endpoint: http://localhost:4000/nutch/parse
- Sample Request Payload:
```
{
  "identifier" : "sampleCrawl",
  "batchId: "12134343"
}
```

### Invoke Nutch UpdateDb
- HTTP Method: **POST** 
- Rest Endpoint: http://localhost:4000/nutch/updatedb
- Sample Request Payload:
```
{
  "identifier" : "sampleCrawl"
}
```

### Invoke Nutch SolrIndex
- HTTP Method: **POST** 
- Rest Endpoint: http://localhost:4000/nutch/solrIndex
- Sample Request Payload:
```
{
  "identifier" : "sampleCrawl"
}
```

### Invoke Nutch Solr Delete Duplicates
- HTTP Method: **POST** 
- Rest Endpoint: http://localhost:4000/nutch/solr-delete-duplicates

### Checking Nutch Job Status
By default, upon summiting a nutch job request, a HTTP status code of **202** is returned  indicating the server has received the particular request. A typical response from the request would look like the following:

```
{
    "message": "injector job submitted successfully",
    "status": 202,
    "identifier": "testInjector"
}
``` 

The nutch job is executed asynchronously while the server continues to serve other requests. To check the status of a particular job, do one of the following:

- Use the API to request for the current job status. The URL to get the up to date status of the current job is:
**http://localhost:4000/nutch/status?identifier=<the identifier for the job>&jobName=<the job name>**
A sample response from the request would look like the following:

```
{
        "identifier": "testInjector",
        "jobName": "INJECTOR",
        "status": SUCCESS,
        "date": 1415761722588
 }
```

#### Job Name and Status Reference ####
The following table describes the list of valid nutch job names.

| Job Name  | Job Description |
| ------------- | ------------- |
| INJECTOR | Nutch Injector |
| GENERATOR  | Nutch Generator |
| FETCHER | Nutch Fetcher |
| PARSER | Nutch Parser |
| DBUPDATE | Nutch DB Updater |
| SOLRINDEX | Nutch Solr Index |
| SOLRDELETEDUPS | Nutch Solr Delete Duplicates |
