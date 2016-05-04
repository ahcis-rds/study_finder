namespace :studyfinder do
  task fix_ages: :environment do |t, args|
  
    trials = StudyFinder::Trial.all

    # Minimum Age
    trials.each do |trial|
      if trial.min_age_unit.blank?
        if trial.minimum_age.nil?
          trial.min_age_unit = 'N/A'
        elsif trial.minimum_age.include?('.')
          # Case: Convert decimal years back to months for display
          plural = (trial.minimum_age != '1') ? 's' : ''
          trial.min_age_unit = "#{(trial.minimum_age.to_f * 12).round} Month#{plural}"
        elsif trial.minimum_age.include?('Week')
          # Case: Weeks. If the age criteria is in weeks process and convert.
          trial.min_age_unit = trial.minimum_age
          trial.minimum_age = (trial.minimum_age.gsub(' Weeks', '').gsub(' Week', '').to_f * 0.0191781).round(2)
        elsif trial.minimum_age.include?('Day')
          # Case: Days. If the age criteria is in days process and convert.
          trial.min_age_unit = trial.minimum_age
          trial.minimum_age = (trial.minimum_age.gsub(' Days', '').gsub(' Day', '').to_f * 0.002739728571424657).round(2)
        else
          # Case: Add display logic to units for year
          plural = (trial.minimum_age != '1') ? 's' : ''
          trial.min_age_unit = "#{trial.minimum_age} Year#{plural}"
        end
      end

      # Maximum Age
      if trial.max_age_unit.blank?
        if trial.maximum_age.nil?
          trial.max_age_unit = 'N/A'
        elsif trial.maximum_age.include?('.')
          # Case: Convert decimal years back to months for display
          plural = (trial.maximum_age != '1') ? 's' : ''
          trial.max_age_unit = "#{(trial.maximum_age.to_f * 12).round} Month#{plural}"
        elsif trial.maximum_age.include?('Week')
          # Case: Weeks. If the age criteria is in weeks process and convert.
          trial.max_age_unit = trial.maximum_age
          trial.maximum_age = (trial.maximum_age.gsub(' Weeks', '').gsub(' Week', '').to_f * 0.0191781).round(2)
        elsif trial.maximum_age.include?('Day')
          # Case: Days. If the age criteria is in days process and convert.
          trial.max_age_unit = trial.maximum_age
          trial.maximum_age = (trial.maximum_age.gsub(' Days', '').gsub(' Day', '').to_f * 0.002739728571424657).round(2)
        else
          # Case: Add display logic to units for year
          plural = (trial.maximum_age != '1') ? 's' : ''
          trial.max_age_unit = "#{trial.maximum_age} Year#{plural}"
        end
      end

      trial.save
    end

    # Re-Index with the new fields.
    StudyFinder::Trial.import force: true

  end
end