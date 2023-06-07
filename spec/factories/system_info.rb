FactoryBot.define do
  factory :system_info do
    initials { 'FFU' }
    school_name { "Frostbite Falls U" }
    system_name  { "StudyFinder" }
    system_header { "Make a difference" }
    system_description { "Use StudyFinder to find research opportunities and make a difference." }
    search_term { 'Frostbite Falls'}
    default_url { 'http://studyfinder.frostbitefallsu.edu'}
    default_email { 'sfinder@frostbitefallsu.edu'}
    study_contact_bcc { 'sfinder+study-team-contact@frostbitefallsu.edu'}
    research_match_campaign { 'studyfinder' }
    secret_key { 'this_is_a_key' }
    google_analytics_id { 'GA-999999'}
    display_all_locations { false }
    contact_email_suffix { '@umn.edu' }
    researcher_description { 'This is what researchers need to know about StudyFinder.' }
    captcha { true }
    display_keywords { true }
    display_groups_page { true }
    display_study_show_page { true }
    enable_showcase { true }
    show_showcase_indicators { false }
    show_showcase_controls { false }
    trial_approval { true }
    alert_on_empty_system_id { true }
    faq_description { 'This is an FAQ.' }
  end
end