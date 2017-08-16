class StudyFinder::Trial < ActiveRecord::Base

  require 'csv'

  self.table_name = 'study_finder_trials'

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name "study_finder-trials-#{Rails.env}"

  belongs_to :parser
  has_many :trial_interventions
  has_many :trial_keywords

  has_many :trial_conditions
  has_many :conditions, through: :trial_conditions

  has_many :trial_sites
  has_many :sites, through: :trial_sites

  has_many :ds_trials
  has_many :disease_sites, through: :ds_trials

  has_many :trial_locations
  has_many :locations, -> { order 'study_finder_locations.location' }, through: :trial_locations

  has_many :trial_mesh_terms

  scope :recent_as, ->(duration){ where('updated_at > ?', Time.zone.today - duration ).order('updated_at DESC') }

  def self.import_from_file(file)
    CSV.foreach(file.path, headers: true) do |row|
      StudyFinder::Trial.create! row.to_hash
    end
  end

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

  def conditional_mesh_terms
    trial_mesh_terms.map { |t| "#{t.mesh_term}" if t.mesh_term_type == 'Conditional'}.join("; ") if trial_mesh_terms.any?
  end

  def intervention_mesh_terms
    trial_mesh_terms.map { |t| "#{t.mesh_term}" if t.mesh_term_type == 'Intervention'}.join("; ") if trial_mesh_terms.any?
  end

  def mesh_terms
    trial_mesh_terms.map { |t| "#{t.mesh_term_type}: #{t.mesh_term}"}.join('; ') if trial_mesh_terms.any?
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
        synonyms_path: 'trials_synonym.txt'.to_s
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

      indexes :category_ids
      indexes :keyword_suggest, type: 'completion', analyzer: 'typeahead', search_analyzer: 'typeahead', payloads: false

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

      indexes :sites do
        indexes :site_name, type: 'string'
        indexes :address, type: 'string'
        indexes :city, type: 'string'
        indexes :state, type: 'string'
        indexes :zip, type: 'string'
      end

      indexes :disease_sites do
        indexes :disease_site_name, type: 'string'
        indexes :group_id, type: 'integer'
      end

      indexes :categories
      indexes :interventions, analyzer: 'en'
      indexes :conditions_map, analyzer: 'en'
      indexes :keywords, analyzer: 'en'
      indexes :min_age_unit, type: 'string'
      indexes :max_age_unit, type: 'string'
      indexes :featured, type: 'integer'
      indexes :irb_number, type: 'string'
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
        :contact_first_name,
        :contact_last_name,
        :contact_email,
        :contact_backup_first_name,
        :contact_backup_last_name,
        :contact_backup_email,
        :recruitment_url,
        :irb_number,
        :phase,
        :min_age_unit,
        :max_age_unit,
        :featured
      ],
      include: {
        trial_locations: {
          only: [
            :first_name,
            :last_name,
            :email,
            :backup_first_name,
            :backup_last_name,
            :backup_email,
            :investigator_last_name,
            :investigator_role
          ],
          methods: [:location_name, :city, :state, :zip, :country]
        },
        sites: {
          only: [
            :site_name,
            :address,
            :city,
            :state,
            :zip
          ]
        },

        disease_sites: {
          only: [
            :disease_site_name,
            :group_id
          ]
        }
      },
      methods: [:display_title, :min_age, :max_age, :interventions, :conditions_map, :categories, :category_ids, :keywords, :keyword_suggest]
    )
  end

  def self.match_all(search)
    search(
      query: {
        function_score: {
          query: {
            filtered: {
              query: {
                match_all: {}
              },
              filter: create_filters(search)
            }
          },
          boost_mode: "sum",
          script_score: {
            script: "_score + (doc['featured'].value * 15)"
          }
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
        function_score: {
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
          boost_mode: "sum",
          script_score: {
            script: "_score + (doc['featured'].value * 15)"
          }
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
      range = { or: [] }
      filters = nil

      if (search.has_key?('children'))
        range[:or] << { range: { min_age: { lt: 18 } } }
      end

      if (search.has_key?('adults'))
        range[:or] << { range: { min_age: { lt: 66 }, max_age: { gte: 18 } } }
      end

      if (search.has_key?('seniors'))
        range[:or] << { range: { max_age: { gte: 66 } } }
      end

      if (search.has_key?('healthy_volunteers') and search[:healthy_volunteers] == "1") or search.has_key?('category') or search.has_key?('gender')
        term_array = [terms]

        if search.has_key?('healthy_volunteers') and search[:healthy_volunteers] == "1"
          term_array << { term: { healthy_volunteers: true } }
        end

        if search.has_key?('category')
          term_array << { term: { category_ids: search[:category] } }
        end

        if (search.has_key?('gender')) and (search[:gender] == 'Male' or search[:gender] == 'Female')
          term_array << { terms: { gender: ['all', search[:gender].downcase] }}
        end

        terms = {
          and: term_array
        }
      end

      if search.has_key?('children') or search.has_key?('adults') or search.has_key?('seniors')
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
