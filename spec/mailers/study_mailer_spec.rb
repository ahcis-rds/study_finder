require 'rails_helper'

describe StudyMailer do
  describe 'contact_team' do
    before { 
      @trial = create(:trial,  
        system_id: 'NCT00002668',
        brief_title: 'PATIENT SKILLS FOR CANCER PAIN CONTROL IN PATIENTS WITH METASTATIC BREAST OR PROSTATE CANCER',
        overall_status: 'Recruiting',
        healthy_volunteers: 'No'
      )

      @system_info = create(:system_info,
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
      )

      @to_address = Faker::Internet.email
      @phone_number = Faker::PhoneNumber.phone_number

      @mail = StudyMailer.contact_team(
        @to_address,
        Faker::Name.name,
        Faker::Internet.email,
        @phone_number,
        Faker::GreekPhilosophers.quote,
        @trial.system_id,
        @trial.brief_title,
        @system_info)
    }

    it 'renders the subject' do
      expect( @mail.subject ).to eq('Someone is interested in your study')
    end

    it 'renders the reciever email' do
      expect( @mail.to[0] ).to eq(@to_address)
    end

    it 'assigns @title in the mail body' do
      expect( @mail.body.encoded ).to match(@trial.brief_title)
    end

    it "includes phone number" do
      expect(@mail.body.raw_source).to match(@phone_number)
    end

    after {
      @trial.destroy
      @system_info.destroy
    }
  end
end