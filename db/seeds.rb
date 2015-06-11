# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

# ============================================
# System info
# ============================================

system = {
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
}

system_info = StudyFinder::SystemInfo.find_or_initialize_by(initials: system[:initials])
system_info.school_name = system[:school_name]
system_info.system_name = system[:system_name]
system_info.system_header = system[:system_header]
system_info.system_description = system[:system_description]
system_info.search_term = system[:search_term]
system_info.default_url = system[:default_url]
system_info.default_email = system[:default_email]
system_info.display_all_locations = system[:display_all_locations]
system_info.secret_key = system[:secret_key]
system_info.contact_email_suffix = system[:contact_email_suffix]

system_info.save!

# ============================================
# Groups
# ============================================

[
  {
    name: "Cancer"
  },
  {
    name: "Diabetes & Hormones"
  },
  {
    name: "Digestive Systems & Liver Disease"
  },
  {
    name: "Infectious Diseases & Immune System"
  },
  {
    name: "Prevention"
  },
  {
    name: "Muscle & Bone"
  },
  {
    name: "Vision & Eyes"
  },
  {
    name: "Blood Disorders"
  },
  {
    name: "Arthritis & Rheumatic Diseases"
  },
  {
    name: "Heart Health"
  },
  {
    name: "Lung Disease & Asthma"
  },
  {
    name: "Dentistry"
  },
  {
    name: "Mental Health"
  },
  {
    name: "Neurology"
  },
  {
    name: "Kidney & Urinary System"
  },
  {
    name: "Hearing/Ears"
  },
  {
    name: "Women's Health"
  },
  {
    name: "Children's Health"
  }
].each do |g|
  group = StudyFinder::Group.find_or_initialize_by(group_name: g[:name])
  group.save!
end

# ============================================
# Parsers
# ============================================

[
  {
    name: 'clinicaltrials.gov',
    klass: 'Parsers::Ctgov'
  }
].each do |p|
  parser = StudyFinder::Parser.find_or_initialize_by(name: p[:name])
  parser.klass = p[:klass]
  parser.save!
end

# ============================================
# Users
# ============================================

[{
  internet_id: 'kadrm002',
  first_name: 'Jason',
  last_name: 'Kadrmas',
  email: 'kadrm002@umn.edu'
}].each do |u|
  user = StudyFinder::User.find_or_initialize_by(internet_id: u[:internet_id])
  user.first_name = u[:first_name]
  user.last_name = u[:last_name]
  user.email = u[:email]
  user.save!
end