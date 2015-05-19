namespace :studyfinder do
  namespace :coorespondance do
    task generate_pis: :environment do |t, args|

      results = StudyFinder::Trial.find_by_sql("
        select x.system_id, x.email, max(x.name) as name
        from (
        select system_id, contact_email as email, contact_last_name as name
        from study_finder_trials
        where visible = true
        and contact_email is not null and contact_email like '%umn.edu'

        UNION ALL

        select t.system_id, tl.email, tl.last_name as name
        from study_finder_trials t
        left join study_finder_trial_locations tl on tl.trial_id = t.id
        where visible = true
        and tl.email is not null and tl.email like '%umn.edu'

        UNION ALL

        select t.system_id, tl.backup_email, tl.backup_last_name as name
        from study_finder_trials t
        left join study_finder_trial_locations tl on tl.trial_id = t.id
        where visible = true
        and tl.backup_email is not null and tl.backup_email like '%umn.edu') x
        group by x.system_id, x.email
        order by x.email
      ")

      FileUtils.rm_rf("#{Rails.root}/tmp/email_templates.html")

      pi_list = {}

      results.each do |row|
        if pi_list[row["email"]].nil?
          pi_list[row["email"]] = {
            name: row["name"],
            email: row["email"],
            ids: [row["system_id"]]
          }
        else
          pi_list[row["email"]][:ids] << row["system_id"]
        end
      end

      File.open("#{Rails.root}/tmp/email_templates.html", "w+") do |f|

        pi_list.each do |pi|

          email_template = "
          to: <a href=\"mailto:%email%\">%email%</a><br><br>
          Dear %name%,<br>
          <p>Next month, the Clinical and Translational Science Institute will formally launch the University of Minnesota's StudyFinder website (<a href=\"https://studyfinder.umn.edu\">StudyFinder.umn.edu</a>) and kiosk, which will make it easier than ever for the general public to find and connect with University health studies that need volunteers.</p>
          <p>Because StudyFinder will display your studies (%study_ids%), we would like to give you the opportunity to review how it will appear prior to the launch. <strong>We hope you can to take a moment to review your study on <a href=\"https://studyfinder.umn.edu\">StudyFinder.umn.edu</a> to ensure the primary contact is a suitable person for potential participants to reach out to via email.</strong></p>
          <p>This information is currently extracted from <a href\"http://clinicaltrials.gov\">ClinicalTrials.gov</a> and augmented with data from the OnCore clinical trials management system, when available. Researchers can make select changes though <a href=\"https://studyfinder.umn.edu\">StudyFinder.umn.edu</a>, and contact our StudyFinder team at <a href=\"mailto:sfinder@umn.edu\">sfinder@umn.edu</a> with questions or to request other modifications. Note that StudyFinder will prompt researchers for a secret key, which is: test</p>
          <p>We encourage you to periodically review your studies on StudyFinder to help potential participants easily find and connect with studies that are right for them.</p>
          <p>Please also be aware that people may email you via the StudyFinder website to inquire about a study. We urge you to work directly with these potential participants, and to contact the StudyFinder team with any questions.</p>
          <p>For your reference, the StudyFinder kiosk - which includes iPads displaying the StudyFinder website - will be housed in the lobby of the University of Minnesota Medical Center (East Bank) starting in early May and will eventually travel to other locations.</p>
          <p>As some of you know, we tested StudyFinder at the 2014 Minnesota State Fair and Delaware Clinical Research Unit, collecting feedback from both users and the University research community. We used this input to make several enhancements aimed at improving the user's experience and giving researchers increased flexibility over how their study appears. Thank you to those who provided feedback.</p>
          <p>If you have questions or comments, or need assistance updating your study information, please contact us at <a href=\"mailto:sfinder@umn.edu\">sfinder@umn.edu.</a></p>
          
          <hr>"
          f.write( 
            email_template.gsub('%email%', pi[1][:email]).gsub('%name%', pi[1][:name]).gsub('%study_ids%', pi[1][:ids].join(', ') )
          )
        end
      end


    end
  end
end