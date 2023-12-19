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

      url = "https://clinicaltrials.gov/ct2/results/download_studies?locn=#{ERB::Util.url_encode(@system_info.search_term)}"

      if !start_date.nil? and !end_date.nil?
        puts "Loading clinicaltrials.gov results for #{@system_info.search_term} ... from #{start_date} to #{end_date}"
        url = url + "&lup_s=#{ERB::Util.url_encode(start_date)}&lup_e=#{ERB::Util.url_encode(end_date)}"
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

    def site_nct_ids
      nct_ids_for_location(SystemInfo.search_term)
    end

    def stray_trials(nct_ids = nil)
      nct_ids ||= site_nct_ids
      Trial.where(parser_id: @parser_id).where.not(nct_id: nct_ids)
    end

    def cleanup_stray_trials(nct_ids = nil)
      nct_ids ||= site_nct_ids
      stray_trials(nct_ids).update(visible: false)
    end

    def nct_ids_for_location(location, page_token = nil)
      csc = 'M Health Fairview Clinics and Surgery Center'
      ids = []
      q = {
          'query.locn' => "SEARCH[Location](AREA[LocationFacility]#{location} AND AREA[LocationStatus]RECRUITING)",
          fields: "NCTId",
          countTotal: true,
          pageSize: 1000,
          format: "json"
        }
      
      # API only wants a pageToken arg at all if we are actually asking for one.
      if !page_token.blank?
        q[:pageToken] = page_token
      end

      response = HTTParty.get(
        "https://clinicaltrials.gov/api/v2/studies",
        query: q
      )
      payload = JSON.parse(response.body || "{}")

      response_ids = Array(payload.dig("studies")).map do |result|
       result.dig("protocolSection").dig("identificationModule").dig("nctId")
      end

      # Add the ids we just received, and ...
      ids.push(*response_ids)

      # ... recurse if there's another page. 
      if payload.dig("nextPageToken")
        ids.push(*(nct_ids_for_location(location, payload.dig("nextPageToken"))))
      end

      return ids
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
