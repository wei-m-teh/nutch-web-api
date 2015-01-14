module.exports = { 
    "Seed" : {
      "id" : "Seed",
      "required" : [ "identifier" ],
      "properties" : {
        "identifier" : {
          "type" : "string",
          "description" : "Unique identifier for the Seed"
        },
        "urls" : {
          "type" : "array",
          "description" : "List of unique URL for the given identifier",
          "items" : {
            "type" : "string"
          }
        }
      }
    },
    "Crawler" : {
      "id" : "Crawler",
      "required" : [ "identfier", "limit", "seeds" ],
      "properties" : {
        "identifier" : {
          "type" : "string",
          "description" : "Unique identifier for a crawler job"
        }, 
        "limit" : {
          "type": "integer",
          "format": "int64",
          "description" : "number of iterations for the Nutch crawling process"
        },
        "seeds" : {
          "$ref" : "Seed",
          "description" : "Seeds to perform crawler job with"
        }
      }
    },
    "Injector" : {
      "id" : "Injector",
      "required" : [ "identifier" ],
      "properties" : {
        "identifier" : {
          "type" : "string",
          "description" : "Unique identifier for an injector job"
        }
      }
    },
    "Generator" : {
      "id" : "Generator",
      "required" : [ "identifier" ],
      "properties" : {
        "identifier" : {
          "type" : "string",
          "description" : "Unique identifier for an generator job"
        },
        "batchId" : {
          "type" : "string",
          "description" : "Unique identifier that identifies the batch for the job"
        }
      }
    },
    "Fetcher" : {
      "id" : "Fetcher",
      "required" : [ "identifier" ],
      "properties" : {
        "identifier" : {
          "type" : "string",
          "description" : "Unique identifier for a fetcher job"
        },
        "batchId" : {
          "type" : "string",
          "description" : "Unique identifier that identifies the batch for the job"
        }
      }
    },
    "Parser" : {
      "id" : "Parser",
      "required" : [ "identifier" ],
      "properties" : {
        "identifier" : {
          "type" : "string",
          "description" : "Unique identifier for an parser job"
        },
        "batchId" : {
          "type" : "string",
          "description" : "Unique identifier that identifies the batch for the job"
        }
      }
    },
    "DbUpdater" : {
      "id" : "DbUpdater",
      "required" : [ "identifier" ],
      "properties" : {
        "identifier" : {
        "type" : "string",
        "description" : "Unique identifier for an dbUpdater job"
        }
      }
    },
    "SolrIndexer" : {
      "id" : "SolrIndexer",
      "required" : [ "identifier" ],
      "properties" : {
        "identifier" : {
        "type" : "string",
        "description" : "Unique identifier for an SolrIndexer job"
        }
      }
    },
    "SolrDeleteDuplicates" : {
      "id" : "SolrDeleteDuplicates"
    }
}