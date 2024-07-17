module Connectors
  class Ctgov
    require 'parsers/ctgov'
    require 'zip'

    def initialize
      @system_info = SystemInfo.current

      if @system_info.nil?
        raise "There is no system info associated. Please run the seeds file, or add the info in the system administration section."
      end

      @parser_id = Parser.find_by({ klass: 'Parsers::Ctgov'}).id
      @location = @system_info.search_term
      @page_token = nil
      @payload = nil
      @start_date = 'MIN'
      @end_date = 'MAX'
      @start_load_time = nil
      @total_count = nil
      @count = 0
    end

    def study_filters
      q = {
          'query.locn' => "AREA[LocationFacility]#{@location} AND AREA[LocationStatus]RECRUITING",
          'query.term' => "AREA[LastUpdatePostDate]RANGE[#{@start_date},#{@end_date}]",
          countTotal: true,
          pageSize: 100,
          format: "json"
        }
      # API only wants a pageToken arg at all if we are actually asking for one.
      if !@page_token.blank?
        q[:pageToken] = @page_token
      end

      return q
    end

    def studies_page
      response = HTTParty.get(
        "https://clinicaltrials.gov/api/v2/studies",
        query: self.study_filters
      )
      @payload = JSON.parse(response.body || "{}")
      @total_count ||= @payload.dig('totalCount')
      puts "Retrieved page (#{@page_token})"
    end

    def load(start_date="MIN", end_date="MAX")
      puts "Adding/Updating trials in the database.  If it is a full reload it's going to be awhile...  Maybe get some coffee? :)"
      @start_date = start_date
      @end_date = end_date
      @start_load_time ||= Time.now

      self.studies_page

      # Process the studies we just received, and ...
      self.process
      # ... recurse if there's another page. 

      if @payload.dig("nextPageToken")
        @page_token = @payload.dig("nextPageToken")
      else
        @page_token = nil
      end

      if @page_token.blank? 
        puts "clinicaltrials.gov load COMPLETE."
      else
        puts "Now we'll load page #{@payload.dig("nextPageToken")}}"
        @payload = nil
        self.load(@start_date,@end_date)
      end
    end

    def process
      page_start_load_time = Time.now
      page_count = 0
      puts "Processing page (#{@page_token})"

      @payload.dig('studies').each do |study|
        @id = study.dig('protocolSection', 'identificationModule', 'nctId')
        p = Parsers::Ctgov.new(@id, @parser_id, study)
        puts "Processing: #{@id} (#{@count + 1} of #{@total_count})"
        p.process
        page_count = page_count + 1
        @count = @count + 1
      end
      page_end_load_time = Time.now

      puts "Logging update to updaters table."
      Updater.create({
        parser_id: @parser_id,
        num_updated: page_count
      })

      puts "Page time elapsed: #{(page_end_load_time - page_start_load_time)} seconds for #{page_count} records."
      puts "Total process elapsed: #{(page_end_load_time - @start_load_time)} seconds for #{@count} records."
      return true
    end

    def clear
      puts "Clearing out all the old trial tables."

      TrialIntervention.delete_all
      TrialLocation.delete_all
      TrialKeyword.delete_all
      Location.delete_all
      TrialSubgroup.delete_all
      TrialCondition.delete_all
      Trial.delete_all
    end

    def site_nct_ids
      nct_ids_for_location(SystemInfo.search_term)
    end

    def stray_trials
      Trial.where(parser_id: @parser_id).where.not(nct_id: self.site_nct_ids)
    end

    def cleanup_stray_trials
      stray_trials.update_all(visible: false)
    end

    def nct_ids_for_location(location, page_token = nil)
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
