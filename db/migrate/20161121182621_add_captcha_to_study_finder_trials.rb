class AddCaptchaToStudyFinderTrials < ActiveRecord::Migration
  def up
	  if Rails.env == 'local' or Rails.env == 'test'
	    # We are using postgres locally, which supports a boolean type.
	    default = 'FALSE'
	    type = 'BOOLEAN'
	  else
	    # This is an oracle thing.  Oracle doesn't support boolean types. If you are not using oracle, please remove this sillyness and just use visible = true.
	    default = '0'
	    type = 'NUMBER(1,0)'
	  end

	  execute "ALTER TABLE study_finder_trials ADD captcha #{type} NOT NULL DEFAULT #{default};"
	end

	def down
	  execute "ALTER TABLE study_finder_trials DROP COLUMN captcha;"
	end
end
