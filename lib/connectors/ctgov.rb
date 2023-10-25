module Connectors
  class Ctgov
    require 'parsers/ctgov'
    require 'zip'

    def initialize
      @system_info = SystemInfo.current
      @parser_id = Parser.find_by({ klass: 'Parsers::Ctgov'}).id

      if @system_info.nil?
        raise "There is no system info associated. Please run the seeds file, or add the info in the system administration section."
      end
    end

    def load(start_date=nil, end_date=nil)
      start_load_time = Time.now

      url = "https://clinicaltrials.gov/ct2/results/download_studies?locn=#{URI::encode(@system_info.search_term)}"

      if !start_date.nil? and !end_date.nil?
        puts "Loading clinicaltrials.gov results for #{@system_info.search_term} ... from #{start_date} to #{end_date}"
        url = url + "&lup_s=#{URI::encode(start_date)}&lup_e=#{URI::encode(end_date)}"
      else
        puts "Loading all clinicaltrials.gov results for #{@system_info.search_term} ..."
      end

      puts "Search URL: #{url}"
      # @zipfile = Tempfile.new('file')
      # @zipfile.binmode

      dirname = "#{Rails.root}/tmp/"
      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end

      FileUtils.rm_rf("#{dirname}search_result.zip")
      File.open("#{dirname}search_result.zip", "w+") do |f|
        f.write(HTTParty.get(url).body)
      end
      # @zipfile.write(HTTParty.get(url).body)
      # @zipfile.close

      puts "Extracting trials from zip file"
      extract()
      end_load_time = Time.now

      puts "Time elapsed #{(end_load_time - start_load_time)} seconds"
    end

    def extract
      start_load_time = Time.now
      extract_zip()
      end_load_time = Time.now

      puts "Zip time elapsed: #{(end_load_time - start_load_time)}"
      return true
    end

    def process
      start_load_time = Time.now
      count = 0
      puts "Adding/Updating trials in the database.  If it is a full reload it's going to be awhile...  Maybe get some coffee? :)"

      Dir.glob("#{Rails.root}/tmp/trials/*.xml") do |file|
        p = Parsers::Ctgov.new( file.gsub("#{Rails.root}/tmp/trials/", "").gsub(".xml", ""), @parser_id)
        p.load(file)
        p.process
        count = count + 1
      end
      end_load_time = Time.now

      puts "Logging update to updaters table. Processed #{count} records."
      Updater.create({
        parser_id: @parser_id,
        num_updated: count
      })

      puts "Process time elapsed: #{(end_load_time - start_load_time)} seconds"
      return true
    end

    def clear
      puts "Clearing out all the old trial tables."

      TrialIntervention.delete_all
      TrialLocation.delete_all
      TrialKeyword.delete_all
      Location.delete_all
      Trial.delete_all
      TrialCondition.delete_all
    end

    def stray_trials
      Trial.where.not(system_id: nct_ids_for_location(@system_info.search_term))
    end

    def cleanup_stray_trials
      stray_trials.destroy_all
    end

    private

      def extract_zip
        dirname = "#{Rails.root}/tmp/"
        unless File.directory?(dirname)
          FileUtils.mkdir_p(dirname)
        end

        unless File.directory?("#{dirname}trials/")
          FileUtils.mkdir_p("#{dirname}trials/")
        end

        FileUtils.rm_rf(Dir.glob("#{dirname}trials/*"))
        Zip::File.open("#{dirname}search_result.zip") do |file|
          file.each do |entry|
            file.extract(entry, "#{dirname}trials/#{entry.name}")
          end
        end
      end

    def nct_ids_for_location(location, start = 1, endd = 1000, ids = [])
      response = HTTParty.get(
        "https://classic.clinicaltrials.gov/api/query/study_fields",
        query: {
          expr: "SEARCH[Location](AREA[LocationFacility]#{location})",
          fields: "NCTId",
          min_rnk: start,
          max_rnk: endd,
          fmt: "json"
        }
      )

      response_ids = Array(JSON.parse(response.body || "{}").dig("StudyFieldsResponse").dig("StudyFields")).map do |result|
        Array(result.dig("NCTId")).first
      end

      if response_ids.empty?
        ids
      else
        nct_ids_for_location(location, endd + 1, endd + 1000, ids + response_ids)
      end
    end
  end
end
