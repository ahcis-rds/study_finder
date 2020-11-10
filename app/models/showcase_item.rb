class ShowcaseItem < ApplicationRecord
	has_one_attached :showcase_image

	validates :showcase_image, content_type: [:png, :jpg, :jpeg]
end