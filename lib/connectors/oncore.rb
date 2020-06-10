module Connectors
  class Oncore
    def initialize
      @system_info = SystemInfo.current
      if @system_info.nil?
        raise "There is no system info associated. Please run the seeds file, or add the info in the system administration section."
      end
    end

    def load
      raise "TODO: Implementation"
    end

  end
end