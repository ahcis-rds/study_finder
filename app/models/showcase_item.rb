class ShowcaseItem < ApplicationRecord
	has_one_attached :showcase_image

	validates :showcase_image, content_type: [:png, :jpg, :jpeg]

	def alt_text_value 
		if !alt_text.nil?
			alt_text
		else
			""
		end
	end

end