require 'connectors/ctgov'

namespace :studyfinder do
  namespace :ctgov do

    # ==============================================================================================
    # studyfinder:ctgov:load
    # Note: This is the nightly load task that needs to be cron'ed to pull trials from
    # clinicaltrials.gov.  The days_previous variable will determine how many days back we should
    # pull from.
    # ==============================================================================================

    task :load, [:days_previous] => [:environment] do |t, args|
      # Retrieve x amount of trials days previous from today.
      args.with_defaults(days_previous: 4)

      puts "Processing ClinicalTrials.gov data"
      connector = Connectors::Ctgov.new
      connector.load((Date.today - args[:days_previous].to_i).strftime('%m/%d/%Y') , Date.today.strftime('%m/%d/%Y') )
      connector.process(true)

      puts "Reindexing all trials into elasticsearch"
      Trial.import force: true
    end

    task refresh_all: :environment do |t, args|
      puts "Refreshing all ClinicalTrials.gov data"

      connector = Connectors::Ctgov.new
      connector.load
      connector.process(true)

      puts "Reindexing all trials into elasticsearch"
      Trial.import force: true
    end

    # ==============================================================================================
    # studyfinder:ctgov:reload_all
    # Note: Dangerous business here!!  This will delete and reload data from every
    # StudyFinder table.  Essentially starting from scratch. Use at your own risk!
    # ==============================================================================================

    task reload_all: :environment do |t, args|
      puts "Reloading all ClinicalTrials.gov data"

      connector = Connectors::Ctgov.new
      connector.clear
      connector.load
      connector.process(true)

      puts "Reindexing all trials into elasticsearch"
      Trial.import force: true
    end

  end
end
