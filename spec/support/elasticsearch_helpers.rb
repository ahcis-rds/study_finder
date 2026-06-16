# Helpers for managing the Elasticsearch test index.
#
# The test index is created once when rails_helper.rb loads
# (Trial.__elasticsearch__.create_index!).  After that, each test that touches
# search must:
#   1. index the records it needs
#   2. call es_refresh so the index is queryable (ES writes are async by default)
#   3. clean up after itself
#
# Usage in a spec:
#
#   before do
#     @trial = create(:trial, brief_title: "Diabetes Study")
#     es_index(@trial)
#   end
#
#   after { es_clear }

module ElasticsearchHelpers
  # Index one or more ActiveRecord objects and refresh the index immediately.
  def es_index(*records)
    records.flatten.each do |record|
      record.__elasticsearch__.index_document
    end
    Trial.__elasticsearch__.refresh_index!
  end

  # Delete all documents from the test index and refresh.
  def es_clear
    Trial.__elasticsearch__.client.delete_by_query(
      index: Trial.__elasticsearch__.index_name,
      body: { query: { match_all: {} } },
      refresh: true
    )
  rescue Elasticsearch::Transport::Transport::Errors::NotFound
    # index may not exist yet — safe to ignore
  end
end

RSpec.configure do |config|
  config.include ElasticsearchHelpers, :elasticsearch
  config.include ElasticsearchHelpers, type: :system

  # Wipe the ES index after every system or :elasticsearch spec so documents
  # from one example don't leak into the next.
  config.after(:each, :elasticsearch) { es_clear }
  config.after(:each, type: :system)  { es_clear }
end
