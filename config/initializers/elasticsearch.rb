if Rails.env == 'local'
  Elasticsearch::Model.client = Elasticsearch::Client.new log: true
else
  Elasticsearch::Model.client = Elasticsearch::Client.new(log: true, host: ENV['es_host'])
end