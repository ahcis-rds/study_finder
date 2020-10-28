class Trial < ApplicationRecord

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
      Trial.create! row.to_hash
    end
  end

  def self.find_range(start_date, end_date)
    where('updated_at between ? and ?', start_date, end_date ).order('updated_at DESC')
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
    VwStudyFinderTrialGroups.where({ trial_id: id }).map(&:group_id)
  end

  def keyword_suggest
    {
      input: trial_keywords.where.not(keyword: nil).map { |k| k.keyword.downcase }
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
        synonyms_path: 'analysis/synonyms.txt'
      },
      english_filter: {
        type: 'kstem'
      }
    }
  } do

    mappings dynamic: 'false' do
      indexes :display_title, type: 'text', analyzer: 'en'
      indexes :simple_description, type: 'text', analyzer: 'en'
      # indexes :eligibility_criteria, type: 'text', analyzer: 'snowball'
      indexes :system_id
      indexes :min_age, type: 'float'
      indexes :max_age, type: 'float'
      indexes :gender
      indexes :phase, type: 'text'
      indexes :cancer_yn, type: 'text'
      indexes :visible, type: 'boolean'
      indexes :healthy_volunteers

      indexes :contact_override
      indexes :contact_override_first_name
      indexes :contact_override_last_name

      indexes :pi_name, type: 'text', analyzer: 'en'
      indexes :pi_id

      indexes :category_ids
      indexes :keyword_suggest, type: 'completion', analyzer: 'typeahead', search_analyzer: 'typeahead'


      indexes :trial_locations do
        indexes :last_name, type: 'text'
        indexes :email, type: 'text'
        indexes :backup_email, type: 'text'
        indexes :backup_last_name, type: 'text'
        indexes :location_name, type: 'text', index: false #'not_analyzed', store: 'yes'
        indexes :city, type: 'text'
        indexes :state, type: 'text'
        indexes :zip, type: 'text'
      end

      indexes :sites do
        indexes :site_name, type: 'text'
        indexes :address, type: 'text'
        indexes :city, type: 'text'
        indexes :state, type: 'text'
        indexes :zip, type: 'text'
      end

      indexes :disease_sites do
        indexes :disease_site_name, type: 'text'
        indexes :group_id, type: 'integer'
      end

      indexes :interventions, analyzer: 'en'
      indexes :conditions_map, analyzer: 'en'
      indexes :keywords, analyzer: 'en'
      indexes :min_age_unit, type: 'text'
      indexes :max_age_unit, type: 'text'
      indexes :featured, type: 'integer'
      indexes :irb_number, type: 'text'
    end

  end

  def as_indexed_json(options={})
    self.as_json(
      only: [
        :simple_description,
        :overall_status,
        :eligibility_criteria,
        :system_id,
        :gender,
        :healthy_volunteers,
        :visible,
        :contact_url,
        :contact_url_override,
        :contact_override,
        :contact_override_first_name,
        :contact_override_last_name,
        :contact_last_name,
        :contact_email,
        :contact_backup_last_name,
        :contact_backup_email,
        :pi_name,
        :pi_id,
        :recruitment_url,
        :irb_number,
        :phase,
        :cancer_yn,
        :min_age_unit,
        :max_age_unit,
        :featured
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
      methods: [:display_title, :min_age, :max_age, :interventions, :conditions_map, :category_ids, :keywords, :keyword_suggest]
    )
  end

  def self.execute_search(search_hash = {})
    if search_hash[:q].blank?
      match_all(search_hash)
    else
      match_all_search(search_hash)
    end
  end

  def self.match_all(search)
    search(
      query: {
        function_score: {
          query: {
            bool: {
              must: [
                { bool: { filter: filters(search) } },
                { bool: { should: range_filters(search) } }
              ]
            }
          },
          field_value_factor: {
            field: "featured",
            factor: 15
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
            bool: {
              must: [
                {
                  query_string: {
                    query: search[:q],
                    default_operator: "AND",
                    fields: ["display_title", "interventions", "conditions_map", "simple_description", "eligibility_criteria", "system_id", "keywords", "pi_name"]
                  }
                },
                { bool: { filter: filters(search) } },
                { bool: { should: range_filters(search) } }
              ]
            }
          },
          field_value_factor: {
            field: "featured",
            factor: 15
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
        multi_match: {
          query: search[:q],
          operator: "and",
          fields: ["display_title", "interventions", "conditions_map", "simple_description", "eligibility_criteria", "system_id", "keywords", "pi_name"]
        }
      }
    )
  end

  #  Keyword typeahead
  def self.typeahead(q)
    search({
      suggest: {
        keyword_suggest: {
          text: q,
          completion: {
            field: "keyword_suggest"
          }
        }
      }
    }).raw_response
  end

  # Did you mean?
  def self.suggestions(q)
    search({
      suggest: {
        suggestions: {
          text: q,
          term: {
            field: "display_title"
          }
        }
      }
    }).raw_response
  end

  private

  def self.filters(search)
    ret = []
    ret << { term: { visible: true } }

    if (search.has_key?('healthy_volunteers') and search[:healthy_volunteers] == "1") or search.has_key?('category') or search.has_key?('gender')
      if search.has_key?('healthy_volunteers') and search[:healthy_volunteers] == "1"
        ret << { term: { healthy_volunteers: true } }
      end

      if search.has_key?('category')
        ret << { term: { category_ids: search[:category] } }
      end

      if (search.has_key?('gender')) and (search[:gender] == 'Male' or search[:gender] == 'Female')
        ret << { terms: { gender: ['all', search[:gender].downcase] }}
      end
    end

    ret
  end

  def self.range_filters(search)
    ret = []

    if search.has_key?('children')
      ret << { range: { min_age: { lt: 18 } } }
    end

    if search.has_key?('adults')
      ret << { range: { max_age: { gte: 18 } } }
    end

    if search.has_key?('seniors')
      ret << { range: { max_age: { gte: 66 } } }
    end

    ret
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
