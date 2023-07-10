class Trial < ApplicationRecord

  require 'csv'

  self.table_name = 'study_finder_trials'

  before_save :update_healthy_volunteers

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  
  validates :system_id, presence: true
  validates :system_id, uniqueness: true
  validates :system_id, format: { with: /\A[a-zA-Z0-9]+\z/, message: "only allows alphanumeric characters" }
  
  index_name "study_finder-trials-#{Rails.env}"

  belongs_to :parser, optional: true
  has_many :trial_interventions
  has_many :trial_keywords

  has_many :trial_conditions
  has_many :conditions, through: :trial_conditions
  has_many :condition_groups, through: :trial_conditions

  has_many :trial_sites
  has_many :sites, through: :trial_sites

  has_many :ds_trials
  has_many :disease_sites, through: :ds_trials

  has_many :trial_locations
  has_many :locations, -> { order 'study_finder_locations.location' }, through: :trial_locations

  has_many :trial_mesh_terms

  has_one_attached :photo

  has_one :approval

  scope :recent_as, ->(duration){ where('updated_at > ?', Time.zone.today - duration ).order('updated_at DESC') }

  def self.import_from_file(file)
    CSV.foreach(file.path, headers: true) do |row|
      Trial.create! row.to_hash
    end
  end

  def self.find_range(start_date, end_date, attribute = "updated_at")
    where("#{Trial.connection.quote_column_name(attribute)} between ? and ?", start_date, end_date ).order("#{Trial.connection.quote_column_name(attribute)} DESC")
  end

  def simple_description
    self[:simple_description] || simple_description_override
  end

  def simple_description_from_source
    self[:simple_description]
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

  def interventions
    trial_interventions.join('; ')
  end

  def keywords
    trial_keywords.map { |t| "#{t.keyword}" }.join('; ') if trial_keywords.any?
  end

  def conditions_map
    conditions.map { |t| "#{t.condition}" }.join('; ') if conditions.any?
  end

  def category_ids
    condition_groups.map { |e| e.group_id }
  end

  def keyword_suggest
    {
      input: trial_keywords.where.not(keyword: nil).map { |k| k.keyword.try(:downcase) }
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

  def keyword_values
    trial_keywords.map(&:keyword).sort
  end

  def condition_values
    conditions.map(&:condition).sort
  end

  def update_keywords!(keywords)
    return if keywords.nil?

    existing_keywords = trial_keywords.map(&:keyword)
    keywords_to_add = keywords - existing_keywords
    keywords_to_delete = existing_keywords - keywords

    transaction(requires_new: true) do
      trial_keywords.where(keyword: keywords_to_delete).delete_all
      keywords_to_add.each do |keyword|
        trial_keywords.create(keyword: keyword)
      end
    end

    __elasticsearch__.update_document
  end

  def update_conditions!(conditions)
    return if conditions.nil?

    existing_conditions = condition_values
    conditions_to_add = conditions - existing_conditions
    conditions_to_delete = existing_conditions - conditions

    transaction(requires_new: true) do
      trial_conditions.includes(:condition).where(Condition.table_name => { condition: conditions_to_delete }).delete_all

      conditions_to_add.each do |condition|
        trial_conditions.create(condition: Condition.find_or_initialize_by(condition: condition))
      end
    end

    __elasticsearch__.update_document
  end

  def update_locations!(location_data)
    return if location_data.nil?

    existing_locations = locations.as_json
    locations_to_add = location_data - existing_locations
    locations_to_delete = existing_locations - location_data

    transaction(requires_new: true) do
      locations_to_delete.each do |location_to_delete|
        locations.where(location: location_to_delete[:name], zip: location_to_delete[:zip]).delete_all
      end

      locations_to_add.each do |location_to_add|
        location = locations.find_or_initialize_by(location: location_to_add[:name], zip: location_to_add[:zip])
        location.city = location_to_add[:city]
        location.state = location_to_add[:state]
        location.zip = location_to_add[:zip]
        location.country = location_to_add[:country]
      end
    end

    save!
  end

  def update_interventions!(intervention_data)
    return if intervention_data.nil?
    existing_interventions = trial_interventions.as_json

    interventions_to_add = intervention_data - existing_interventions
    interventions_to_delete = existing_interventions - intervention_data

    transaction(requires_new: true) do
      interventions_to_delete.each do |intervention_to_delete|
        trial_interventions.where(intervention_to_delete).delete_all
      end

      interventions_to_add.each do |intervention_to_add|
        trial_interventions.find_or_initialize_by(
          trial_id: self.id,
          intervention_type: intervention_to_add[:intervention_type],
          intervention: intervention_to_add[:intervention]
        )
      end
    end

    save!
  end

  # ===============================================
  # Elasticsearch Configuration & Methods
  # ===============================================
  if Rails.application.config.respond_to?(:synonyms_path)
    synonym_list = { synonyms_path: Rails.application.config.synonyms_path }
  else
    synonym_list = { synonyms: Modules::TrialSynonyms.as_array }
  end

  settings analysis: {
    analyzer: {
      search_synonyms: {
        tokenizer: 'standard',
        filter: [ 'graph_synonyms', 'asciifolding', 'lowercase' ]
      },
      en: {
        tokenizer: 'standard',
        filter: ['asciifolding', 'lowercase', 'custom_stems', 'english_filter']
      },
      typeahead: {
        tokenizer: 'standard',
        filter: ['asciifolding', 'lowercase']
      }
    },
    filter: {
      graph_synonyms: {
        type: 'synonym_graph',
        **synonym_list,
        updateable: true
      },
      custom_stems: {
          type: 'stemmer_override',
          rules:  [
            'sarcoidosis => sarcoidosis',
            'racism => racism',
            'african => african',
            'american => american'
          ]
      },
      english_filter: {
        type: 'kstem'
      }
    }
  } do

    mappings dynamic: 'false' do
      indexes :display_title, type: 'text', analyzer: 'en', search_analyzer: 'search_synonyms'
      indexes :simple_description, type: 'text', analyzer: 'en', search_analyzer: 'search_synonyms'
      # indexes :eligibility_criteria, type: 'text', analyzer: 'snowball'
      indexes :system_id
      indexes :gender
      indexes :phase, type: 'text'
      indexes :cancer_yn, type: 'text'
      indexes :recruiting, type: 'boolean'
      indexes :visible, type: 'boolean'
      indexes :display_simple_description, type: 'boolean'
      indexes :healthy_volunteers
      indexes :contact_override
      indexes :contact_override_first_name
      indexes :contact_override_last_name
      indexes :approved, type: 'boolean'
      indexes :protocol_type

      indexes :pi_name, type: 'text', analyzer: 'en'
      indexes :pi_id
      indexes :age
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

      indexes :interventions, analyzer: 'en', search_analyzer: 'search_synonyms'
      indexes :conditions_map, analyzer: 'en', search_analyzer: 'search_synonyms'
      indexes :keywords, analyzer: 'en', search_analyzer: 'search_synonyms'
      indexes :featured, type: 'integer'
      indexes :irb_number, type: 'text'
      indexes :nct_id, type: 'text'
      indexes :added_on, type: 'date'
      indexes :created_at, type: 'date'
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
        :recruiting,
        :visible,
        :display_simple_description,
        :contact_url,
        :contact_url_override,
        :contact_override,
        :contact_override_first_name,
        :contact_override_last_name,
        :contact_first_name,
        :contact_last_name,
        :contact_email,
        :contact_backup_first_name,
        :contact_backup_last_name,
        :contact_backup_email,
        :pi_name,
        :pi_id,
        :recruitment_url,
        :irb_number,
        :nct_id,
        :phase,
        :cancer_yn,
        :featured,
        :added_on,
        :approved,
        :protocol_type,
        :created_at,
        :age
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
      methods: [:display_title,  :age,  :interventions, :conditions_map, :category_ids, :keywords, :keyword_suggest]
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
          bool: {
            must: [
              { bool: { filter: filters(search) } },
              { bool: { should: range_filters(search) } }
            ]
          }
        }
    )
  end

  def self.match_all_search(search)
    search(
        query: {
          bool: {
            must: [
              {
                multi_match: {
                  query: search[:q].try(:downcase),
                  fields: ["display_title", "interventions", "conditions_map", "simple_description", "eligibility_criteria", "system_id", "keywords", "pi_name", "pi_id", "irb_number"]
                }
              },
              { bool: { filter: filters(search) } },
              { bool: { should: range_filters(search) } }
            ]
          }
        }
    )
  end

  def self.match_all_admin(search)
    search(
      query: {
        bool: {
          must: [
           { multi_match: {
              query: search[:q].try(:downcase),
              operator: "and",
              fields: ["display_title", "interventions", "conditions_map", "simple_description", "eligibility_criteria", "system_id", "keywords", "pi_name", "protocol_type"]
            }
          },
            {bool: {filter: filters_admin_all } }
          ]
        }   
      } 
    )
  end

  def self.match_all_under_review_admin(search)
    search(
      query: {
        bool: {
          must: [
            {multi_match: {
              query: search[:q].downcase,
              operator: "and",
              fields: ["display_title", "interventions", "conditions_map", "simple_description", "eligibility_criteria", "system_id", "keywords", "pi_name", "irb_number", "protocol_type"],
              }
            }, 
            { bool: { filter: filters_admin_pending } 
            }       
          ]
        }
     }, 
      sort: {created_at: "desc"} 
    )
  end

  #  Keyword typeahead
  def self.typeahead(q)
    response_hash = search({
      suggest: {
        keyword_suggest: {
          text: q,
          completion: {
            field: "keyword_suggest"
          }
        }
      }
    }).raw_response

    suggestions_hash = Array(response_hash.dig("suggest", "keyword_suggest")).first || {}
    suggestions = Array((suggestions_hash).dig("options"))
    unique_suggestions = suggestions.map { |suggestion| suggestion["text"] }.uniq

    unique_suggestions
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

  def has_nct_number?
    self.class.is_nct_number?(system_id)
  end

  # This only exists as a class method so we can use this logic in the search
  # results page without instantiating a Trial object for every result. Actual
  # Trial instances should use `trial.has_nct_number?`
  def self.is_nct_number?(value)
    value.to_s.upcase.starts_with?("NCT")
  end

  private

  def self.filters(search)
    ret = []
    ret << { term: { visible: true } }
    ret << { term: { approved: true } }
    if (search.has_key?('healthy_volunteers') and search[:healthy_volunteers] == "1") or search.has_key?('category') or search.has_key?('gender')
      if search.has_key?('healthy_volunteers') and search[:healthy_volunteers] == "1"
        ret << { term: { healthy_volunteers: true } }
      end

      if search.has_key?('category')
        ret << { term: { category_ids: search[:category] } }
      end

      if (search.has_key?('gender')) and (search[:gender] == 'Male' or search[:gender] == 'Female')
        ret << { terms: { gender: ['all', search[:gender].try(:downcase)] }}
      end
    end

    ret
  end

  def self.filters_admin_pending
      ret = []
      ret << { term: { visible: true } }
      ret << { term: { approved: false } }
      ret
  end

  def self.filters_admin_all
    ret = []
    ret << { term: { visible: true } }
    if SystemInfo.trial_approval
      ret << { term: { approved: true } }
    end
    ret
  end

  def self.range_filters(search)
    ret = []

    if search.has_key?('children')
      ret << { match_phrase: { age:  "Under 18" }}
    end

    if search.has_key?('adults')
      ret << { match_phrase: { age:  "18 or older"} }
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

  def update_healthy_volunteers
    self.healthy_volunteers = if !healthy_volunteers_override.nil?
                                healthy_volunteers_override
                              else
                                healthy_volunteers_imported
                              end
  end

end
