namespace :studyfinder do
  namespace :trials do
    task reindex: :environment do |t, args|
      StudyFinder::Trial.import force: true
    end
  end
end