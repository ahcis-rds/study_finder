module Connectors
  class Ctgov
    require 'parsers/ctgov'
    require 'zip'

    def initialize
      @system_info = StudyFinder::SystemInfo.current
      @parser_id = StudyFinder::Parser.find_by({ klass: 'Parsers::Ctgov'}).id

      if @system_info.nil?
        raise "There is no system info associated. Please run the seeds file, or add the info in the system administration section."
      end
    end

    def load(start_date=nil, end_date=nil)
      start_load_time = Time.now

      url = "https://clinicaltrials.gov/search?locn=#{URI::encode(@system_info.search_term)}&studyxml=true"

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

    def process(without_index=nil)
      start_load_time = Time.now
      count = 0
      puts "Adding/Updating trials in the database.  If it is a full reload it's going to be awhile...  Maybe get some coffee? :)"

      Dir.glob("#{Rails.root}/tmp/trials/*.xml") do |file|
        p = Parsers::Ctgov.new( file.gsub("#{Rails.root}/tmp/trials/", "").gsub(".xml", ""), @parser_id)
        p.load(file)
        p.process(without_index)
        count = count + 1
      end
      end_load_time = Time.now

      puts "Logging update to updaters table. Processed #{count} records."
      StudyFinder::Updater.create({
        parser_id: @parser_id,
        num_updated: count
      })

      puts "Process time elapsed: #{(end_load_time - start_load_time)} seconds"
      return true
    end

    def clear
      puts "Clearing out all the old trial tables."

      StudyFinder::TrialIntervention.delete_all
      StudyFinder::TrialLocation.delete_all
      StudyFinder::TrialKeyword.delete_all
      StudyFinder::Location.delete_all
      StudyFinder::Trial.delete_all
      StudyFinder::TrialCondition.delete_all
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
  end
end