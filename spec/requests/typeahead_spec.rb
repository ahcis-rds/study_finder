require 'rails_helper'

RSpec.describe "Typeahead endpoint", type: :request do
  before { create(:system_info) }

  it "returns 200 and an empty array for a blank query" do
    get typeahead_studies_path, params: { q: '' }
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq([])
  end

  it "returns 200 and an array for a non-blank query" do
    get typeahead_studies_path, params: { q: 'diab' }
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to be_an(Array)
  end

  it "responds with JSON content type" do
    get typeahead_studies_path, params: { q: 'test' }
    expect(response.content_type).to match(%r{application/json})
  end
end
