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
  researcher_description: "<h2>What researchers need to know about StudyFinder</h2>
    <p>StudyFinder displays data about actively enrolling University of Minnesota studies in a way that’s intuitive and user-friendly. This information is extracted from <a href=\"http://clinicaltrials.gov\">ClinicalTrials.gov</a> and augmented with data from the OnCore clinical trials management system, when available.</p>
    <p>To help potential participants better navigate and connect with University research opportunities, we encourage you to periodically review your studies and update the description and contact information, as appropriate.</p><p>Please also be aware that people may email you via StudyFinder to inquire about a study. We urge you to work directly with these potential participants, and to contact the StudyFinder team with any questions.</p><h3>How to update your study</h3><p>You can update select study information on this website or directly in the source data (<a href=\"http://clinicaltrials.gov\">ClinicalTrials.gov</a> and/or OnCore).</p><p>To update your study on StudyFinder: </p>
    <ul>
      <li>Click on the maroon  \"Look up/Edit Study Information\" button toward the bottom of this page.</li>
      <li>Log in using your x500.</li>
      <li>Look up your study information by entering the System ID, which is either Study NCT ID from <a href=\"http://clinicaltrials.gov\">ClinicalTrials.gov</a>, or Protocol ID from OnCore.</li>
      <li>Ensure the primary contact is a suitable person for potential participants to reach out to via email.</li>
      <li>Save your changes by entering the secret key, and clicking the \"Update Trial\" button at the bottom of the page.</li>
    </ul>
    <p>If you have questions or comments, or need assistance updating your study information, please contact us at <a href=\"mailto:sfinder@umn.edu\">sfinder@umn.edu</a>.</p>",
  search_term: 'University of Minnesota',
  default_url: 'http://studyfinder.umn.edu',
  default_email: 'sfinder@umn.edu',
  display_all_locations: false,
  secret_key: 'test',
  contact_email_suffix: '@umn.edu'
}

system_info = SystemInfo.find_or_initialize_by(initials: system[:initials])
system_info.school_name = system[:school_name]
system_info.system_name = system[:system_name]
system_info.system_header = system[:system_header]
system_info.system_description = system[:system_description]
system_info.researcher_description = system[:researcher_description]
system_info.search_term = system[:search_term]
system_info.default_url = system[:default_url]
system_info.default_email = system[:default_email]
system_info.display_all_locations = system[:display_all_locations]
system_info.secret_key = system[:secret_key]
system_info.contact_email_suffix = system[:contact_email_suffix]

system_info.save!

# ============================================
# Parsers
# ============================================

[
  {
    name: 'clinicaltrials.gov',
    klass: 'Parsers::Ctgov'
  }
].each do |p|
  parser = Parser.find_or_initialize_by(name: p[:name])
  parser.klass = p[:klass]
  parser.save!
end

# ============================================
# Users
# ============================================

[
  {
    internet_id: ENV['USER'],
    first_name: 'Admin',
    last_name: 'User',
    email: "fake@example.edu"
  }
].each do |u|
  user = User.find_or_initialize_by(internet_id: u[:internet_id])
  user.first_name = u[:first_name]
  user.last_name = u[:last_name]
  user.email = u[:email]
  user.save!
end

# ============================================
# Groups and conditions
# ============================================

CSV.foreach(Rails.root.join("db/seeds/condition_groups.csv")) do |group_name, condition_name|
  group = Group.find_or_create_by(group_name: group_name)
  condition = Condition.find_or_create_by(condition: condition_name)
  ConditionGroup.find_or_create_by(group: group, condition: condition)
end

# ============================================
# Trials
# ============================================

Rake::Task['studyfinder:ctgov:load'].invoke
