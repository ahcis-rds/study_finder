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
      connector.load((Date.today - args[:days_previous].to_i).strftime('%Y-%m-%d') , Date.today.strftime('%Y-%m-%d') )

      puts "Reindexing all trials into elasticsearch"
      Trial.import force: true
    end

    task refresh_all: :environment do |t, args|
      puts "Refreshing all ClinicalTrials.gov data"

      connector = Connectors::Ctgov.new
      connector.load

      puts "Reindexing all trials into elasticsearch"
      Trial.import force: true
    end

    task cleanup_strays: :environment do |t, args|
      puts "Cleaning up stray trials"
      connector = Connectors::Ctgov.new
      trials = connector.cleanup_stray_trials
      puts "Have un-published (system_ids): "
      puts trials.map{ |e| " #{e.system_id}\n" }
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

      puts "Reindexing all trials into elasticsearch"
      Trial.import force: true
    end

  end
end
