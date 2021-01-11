require 'rails_helper'

describe ApiKey do
  it "should generate a token when created" do
    expect(subject.token.length).to eq(32)
  end

  it "should require a name" do
    subject.save
    expect(subject.errors).to have_key(:name)
  end
end
