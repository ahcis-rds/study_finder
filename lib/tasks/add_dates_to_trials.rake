namespace :studyfinder do

  #  ===============================================
  #  Note: This only needs to be run if StudyFinder was implemented before 9/28/2015.
  #  The lastchanged_date and firstrecieved_date fields were added after that time and
  #  need to be back populated.
  #  ===============================================

  task add_dates_to_trials: :environment do |t, args|
    
    parser_id = Parser.find_by({ klass: 'Parsers::Ctgov'}).id
    trials = Trial.all
    
    trials.each_with_index do |trial, index|
      p = Parsers::Ctgov.new(trial.system_id, parser_id)
      p.load

      puts "Now serving: #{index} of #{trials.count}"
      
      update_hash = {}
      if p.contents.has_key?('lastchanged_date')
        update_hash['lastchanged_date'] = p.contents['lastchanged_date']
      end
      if p.contents.has_key?('firstreceived_date')
        update_hash['firstreceived_date'] = p.contents['firstreceived_date']
      end

      if update_hash.length > 0
        trial.update(update_hash)
      end
    end
  end
end