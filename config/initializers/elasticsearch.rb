Elasticsearch::Model.client = Elasticsearch::Client.new(
  log: true,
  host: ENV["es_host"].to_s.gsub(" ", "").split(",")
)
