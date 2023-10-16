namespace :studyfinder do
  task update_irb_numbers: :environment do |t, args|

    Trial.update_irb_numbers
    # Re-Index with the new fields.
    Trial.import force: true

  end
end