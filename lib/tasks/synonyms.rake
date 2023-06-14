namespace :studyfinder do
  namespace :synonyms do

    task :to_txt, [:file] => [:environment] do |t, args|
    	args.with_defaults(file: 'synonyms')
    	json_input_file = "#{args[:file]}.json"
    	txt_output_file = "#{args[:file]}.txt"

			file = File.read(Rails.root.join('config','analysis', json_input_file))
			data_hash = JSON.parse(file)

			File.open(Rails.root.join('config', 'analysis', txt_output_file) , "w") do |output|
				data_hash.each do | k,v |
					syns = v['syns']
					syns.map { |e| e.gsub!(/[,"']/, "") }
					output.puts(syns.join(', '))
				end
			end
		end

		task :to_module, [:file] => [:environment] do |t, args|
    	args.with_defaults(file: 'synonyms')
    	json_input_file = "#{args[:file]}.json"
    	module_output_file = "trial_synonyms.rb"

    	file = File.read(Rails.root.join('config','analysis', json_input_file))
			data_hash = JSON.parse(file)

			File.open(Rails.root.join('config', 'analysis', module_output_file) , "w") do |output|
				output.puts <<~PREFIX.strip
					module Modules
					  class TrialSynonyms

					    def self.as_array
					      [
				PREFIX
				data_hash.each do | k,v |
					syns = v['syns']
					syns.map { |e| e.gsub!(/[,"']/, "") }
					output.puts('"' + syns.join(', ') + '",' )
				end
				output.puts <<~POSTFIX.strip
								]
					    end

					  end
					end
				POSTFIX

			end

		end
	end
end

