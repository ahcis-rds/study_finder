class StudyFinder::Trial < ActiveRecord::Base

  self.table_name = 'study_finder_trials'


  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name "study_finder-trials-#{Rails.env}"

  belongs_to :parser
  has_many :trial_interventions
  has_many :trial_keywords
  
  has_many :trial_conditions
  has_many :conditions, through: :trial_conditions
  
  has_many :trial_locations
  has_many :locations, -> { order 'study_finder_locations.location' }, through: :trial_locations

  def display_title
    display = brief_title
    unless acronym.nil?
      display += ' (' + acronym + ')'
    end
    display
  end

  def self.active_trials
    where({ visible: true })
  end

  def min_age
    if minimum_age.nil?
      age = 0
    else
      age = minimum_age.to_f
    end

    age
  end

  def max_age
    if maximum_age.nil?
      age = 1000
    else
      age = maximum_age.to_f
    end

    age
  end

  def interventions
    trial_interventions.map { |t| "#{t.intervention_type}: #{t.intervention}" }.join('; ') if trial_interventions.any?
  end

  def keywords
    trial_keywords.map { |t| "#{t.keyword}" }.join('; ') if trial_keywords.any?
  end

  def conditions_map
    conditions.map { |t| "#{t.condition}" }.join('; ') if conditions.any?
  end

  def category_ids
    StudyFinder::VwStudyFinderTrialGroups.where({ trial_id: id }).map(&:group_id)
  end

  def keyword_suggest
    {
      input: trial_keywords.map { |k| k.keyword.downcase }
    }
  end

  # ===============================================
  # Elasticsearch Configuration & Methods
  # ===============================================

  settings analysis: {
    analyzer: {
      en: {
        tokenizer: 'standard',
        filter: ['asciifolding', 'lowercase', 'english_filter', 'synonym']
      },
      typeahead: {
        tokenizer: 'standard',
        filter: ['asciifolding', 'lowercase']
      }
    },
    filter: {
      synonym: {
        type: 'synonym',
        synonyms_path: '/etc/elasticsearch/trials_synonym.txt'.to_s
      },
      english_filter: {
        type: 'kstem' 
      }
    }
  } do

    mappings dynamic: 'false' do
      indexes :display_title, type: 'string', analyzer: 'en'
      indexes :simple_description, type: 'string', analyzer: 'en'
      # indexes :eligibility_criteria, type: 'string', analyzer: 'snowball'
      indexes :system_id
      indexes :min_age, type: 'float'
      indexes :max_age, type: 'float'
      indexes :gender
      indexes :phase, type: 'string'
      indexes :visible, type: 'boolean'
      indexes :healthy_volunteers

      indexes :contact_override
      indexes :contact_override_first_name
      indexes :contact_override_last_name

      indexes :category_ids, as: 'category_ids'
      indexes :keyword_suggest, type: 'completion', index_analyzer: 'typeahead', search_analyzer: 'typeahead', payloads: false

      indexes :trial_locations do
        indexes :last_name, type: 'string'
        indexes :email, type: 'string'
        indexes :backup_email, type: 'string'
        indexes :backup_last_name, type: 'string'
        indexes :location_name, type: 'string', index: 'not_analyzed', store: 'yes'
        indexes :city, type: 'string'
        indexes :state, type: 'string'
        indexes :zip, type: 'string'
      end

      indexes :categories, as: 'categories'
      indexes :interventions, analyzer: 'en'
      indexes :conditions_map, analyzer: 'en'
      indexes :keywords, analyzer: 'en'
    end

  end

  def as_indexed_json(options={})
    self.as_json(
      only: [
        :simple_description,
        :eligibility_criteria,
        :system_id,
        :gender,
        :healthy_volunteers,
        :visible,
        :contact_override,
        :contact_override_first_name,
        :contact_override_last_name,
        :contact_last_name,
        :contact_email,
        :contact_backup_last_name,
        :contact_backup_email,
        :recruitment_url,
        :phase
      ],
      include: {
        trial_locations: {
          only: [
            :last_name,
            :email,
            :backup_last_name,
            :backup_email,
            :investigator_last_name,
            :investigator_role
          ],
          methods: [:location_name, :city, :state, :zip, :country]
        }
      },
      methods: [:display_title, :min_age, :max_age, :interventions, :conditions_map, :categories, :category_ids, :keywords, :keyword_suggest]
    )
  end

  def self.match_all(search)
    search(
      query: {
        filtered: {
          query: {
            match_all: {}
          },
          filter: create_filters(search)
        }
      },
      highlight: {
        fields: highlight_fields
      }
    )
  end

  def self.match_all_search(search)

    search(
      query: {
        filtered: {
          query: {
            query_string: {
              query: search[:q],
              default_operator: "AND",
              fields: ["display_title", "interventions", "conditions_map", "simple_description", "eligibility_criteria", "system_id", "keywords"]
            }
          },

          filter: create_filters(search)

        }
      },
      highlight: {
        fields: highlight_fields
      }
    )

  end

  def self.match_all_admin(search)
    
    search(
      query: {
        filtered: {
          query: {
            multi_match: {
              query: search[:q],
              operator: "and",
              fields: ["display_title", "interventions", "conditions_map", "simple_description", "eligibility_criteria", "system_id", "keywords"]
            }
          }
        }
      }
    )

  end

  #  Keyword typeahead
  def self.typeahead(q)
    self.__elasticsearch__.client.suggest(index: self.index_name, body: {
      keyword_suggest:{
        text: q,
        completion: {
          field: "keyword_suggest"
        }
      }
    })
  end

  # Did you mean?
  def self.suggestions(q)
    self.__elasticsearch__.client.suggest(index: self.index_name, body: {
      suggestions: {
        text: q,
        term: {
          field: "display_title"
        }
      }
    })
  end

  private
    def self.create_filters(search)
      terms = { term: { visible: true } }
      range = { range: {} }
      filters = nil

      range[:range]['min_age'] = { lt: 18 } if search.has_key?('children')
      range[:range]['max_age'] = { gte: 18 } if search.has_key?('adults')

      if (search.has_key?('healthy_volunteers') and search[:healthy_volunteers] == "1") or search.has_key?('category')
        term_array = [terms]

        if search.has_key?('healthy_volunteers') and search[:healthy_volunteers] == "1"
          term_array << { term: { healthy_volunteers: true } }
        end

        if search.has_key?('category')
          term_array << { term: { category_ids: search[:category] } }
        end

        terms = {
          and: term_array
        }
      end

      if search.has_key?('children') or search.has_key?('adults')
        filters = {}
        filters['and'] = []
        filters['and'] << terms
        filters['and'] << range
      else
        filters = terms
      end
      filters
    end

    def self.highlight_fields
      {
        _all: { pre_tags: ["<em>"], post_tags: ["</em>"] },
        display_title: { number_of_fragments: 0 },
        interventions: { number_of_fragments: 0 },
        keywords: { number_of_fragments: 0 },
        simple_description: { number_of_fragments: 0 },
        conditions_map: { number_of_fragments: 0 },
        eligibility_criteria: { number_of_fragments: 0 }
      }
    end
end