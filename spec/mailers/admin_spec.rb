require 'rails_helper'

RSpec.describe AdminMailer, type: :mailer do
  describe "#contact_team" do
    let(:system_id) { "abc123 " }
    let(:errors) { ["only allows alphanumeric characters"] }
    let(:system_info) {
       SystemInfo.create({
      initials: 'UMN',
      school_name: 'University of Minnesota',
      system_name: 'Study Finder',
      system_header: 'Make A Difference. Get Involved.',
      system_description: "<p>Participating in research is one of the most powerful things you can do to be part of tomorrow's health care breakthroughs. The U of M is always looking for people who are willing to participate in studies, so that our researchers can better understand how to diagnose, treat, and prevent diseases and conditions.</p><p>Use this StudyFinder website to quickly and easily identify U of M studies that need volunteers. Every study is different - some need healthy volunteers, while others are looking for people with a specific condition - so we've created search filters to help you find the study that's right for you. You can also filter by age, and search by keyword to find studies focused on specific conditions and diseases.</p><p>By getting involved with research, you can help transform the lives of millions.</p>",
      search_term: 'University of Minnesota',
      default_url: 'http://studyfinder.umn.edu',
      default_email: 'sfinder@umn.edu',
      display_all_locations: false,
      secret_key: 'test',
      contact_email_suffix: '@umn.edu'
    })}
       

    it "sends an email with the correct information" do
      email = AdminMailer.system_id_error(system_id, errors)
      expect { email.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(email.to).to eq(['sfinder@umn.edu'])
      expect(email.from).to eq(['sfinder@umn.edu'])
      expect(email.reply_to).to eq(['sfinder@umn.edu'])
      expect(email.subject).to eq("#{system_id} is invalid, requires update.")
      expect(email.body.to_s.strip).to include(errors.first)
      expect(email.body.to_s.strip).to include(system_id)
    end
  end
end
