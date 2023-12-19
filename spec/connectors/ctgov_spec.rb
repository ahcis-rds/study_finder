require 'rails_helper'
require 'connectors/ctgov'

describe Connectors::Ctgov do
  context "cleanup_stray_trials" do
    it "hides trials that are no longer actively recruiting at the given location(s)" do
      parser = create(:parser)
      system_info = create(:system_info, initials: 'TSTU')
      ctgov = Connectors::Ctgov.new
      will_hide = create(:trial, parser: parser)
      wont_hide = create_list(:trial, 5, parser: parser)
      remaining_ids = wont_hide.map { |e| e.nct_id }

      expect(will_hide.visible).to be_truthy
      expect(wont_hide.first.visible).to be_truthy

      strays = ctgov.stray_trials(remaining_ids)
      expect(strays.map { |e| e.nct_id }).to include(will_hide.nct_id)

      ctgov.cleanup_stray_trials(remaining_ids)
      will_hide.reload
      expect(will_hide.visible).to be_falsey
      expect(wont_hide.first.visible).to be_truthy
    end

    it "does not hide trials from a different parser" do
      parser = create(:parser)
      parser2 = create(:parser, name: 'foobar', klass: 'Parsers::Foobar')
      system_info = create(:system_info, initials: 'TSTU')
      ctgov = Connectors::Ctgov.new
      will_hide = create(:trial, parser: parser)
      wont_hide = create_list(:trial, 5, parser: parser)
      wont_hide_2 = create(:trial, parser: parser2)
      remaining_ids = wont_hide.map { |e| e.nct_id }

      expect(will_hide.visible).to be_truthy
      expect(wont_hide_2.visible).to be_truthy

      ctgov.cleanup_stray_trials(remaining_ids)
      will_hide.reload

      expect(will_hide.visible).to be_falsey
      expect(wont_hide_2.visible).to be_truthy
    end
  end
end
