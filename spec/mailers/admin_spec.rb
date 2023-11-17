require 'rails_helper'

RSpec.describe AdminMailer, type: :mailer do
  describe "#contact_team" do
    it "sends an email with the correct information" do
      create(:system_info, default_email: "sfinder@umn.edu")
      system_id = "abc123 "
      errors = ["only allows alphanumeric characters"]

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
