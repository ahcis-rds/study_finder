require "rails_helper"

describe "search/embed" do
  before :each do
    SystemInfo.destroy_all
  end

  it "does not break the regular search form" do
    allow(view).to receive(:params).and_return({action: 'search'})

    render

    expect(rendered).not_to match /target=\"_blank\"/
  end

  it "displays a search form in an embed format" do
    allow(view).to receive(:params).and_return({action: 'embed'})

    render

    expect(rendered).to match /target=\"_blank\"/
  end

  it "changes not sure button to specific group/category if passed in as params[:group]" do
    create(:system_info, display_groups_page: true)
    assign(:category, create(:group, group_name: 'Heart Health' ))
    allow(view).to receive(:params).and_return({action: 'embed', group: 'Heart%20Health' })

    render
    
    expect(rendered).to match /search_category/
  end

  it "does not render the 'by category' logic if groups are suppressed" do
    create(:system_info, display_groups_page: false)
    allow(view).to receive(:params).and_return({action: 'embed'})

    render
    
    expect(rendered).not_to match /search_category/
    expect(rendered).not_to match /search%5Bcategory%5D=/
  end
end