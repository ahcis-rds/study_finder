class AddAltTextToShowcaseItem < ActiveRecord::Migration[7.0]
  def change
    add_column :showcase_items, :alt_text, :string, default: ""
  end
end