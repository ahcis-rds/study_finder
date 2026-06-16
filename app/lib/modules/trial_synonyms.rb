module Modules
  class TrialSynonyms

    # This is the default list of trial synonyms, making it easy to implement synonyms without 
    # configuring them in your Elasticsearch instance. If you prefer to manage synonyms
    # in Elasticsearch, you can uncomment `config.synonyms_path` in config/environments/*.rb.
    # This is ignored if that config option is set.
    def self.as_array
      ["baldness, alopecia, hair loss",
        "liver cancer, hepatocellular carcinoma, hcc"]
    end
  end
end
