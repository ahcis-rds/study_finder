require "rails_helper"

describe SystemInfo do
  context "given a system info row exists" do
    it "returns a valid settings object" do
      system_info = create(:system_info, initials: 'TSTU')
      expect(SystemInfo.current).to respond_to :initials
      expect(SystemInfo.current.initials).to be == 'TSTU'
    end

    it "returns appropriate value for approval boolean" do
      system_info = create(:system_info, trial_approval: true)
      expect(SystemInfo.trial_approval).to be_truthy
      system_info.update(trial_approval: false)
      expect(SystemInfo.trial_approval).to be_falsey
    end

    it "returns appropriate value for alert_on_empty_system_id boolean" do
      system_info = create(:system_info, alert_on_empty_system_id: true)
      expect(SystemInfo.alert_on_empty_system_id).to be_truthy
      system_info.update(alert_on_empty_system_id: false)
      expect(SystemInfo.alert_on_empty_system_id).to be_falsey
    end
  end  

end