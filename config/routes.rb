Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  namespace :admin do
    get 'trials/import', to: 'trials#import_show'
    post 'trials/import', to: 'trials#import'
    resources :trials, only: ['index', 'new', 'edit', 'update', 'create']
    get 'trials/recent', controller: 'trials', action: 'recent_as', as: 'trial_recent_as'
    post 'trials/review/:id', controller: 'trials', action: 'review', as: 'review_trial'
    post 'trials/preview', controller: 'trials', action: 'preview', as: 'trial_preview'

    get 'groups/reindex', controller: 'groups', action: 'reindex', as: 'group_reindex'
    resources :groups
    resources :sites
    resources :disease_sites

    resources :system, only: ['index', 'edit', 'update'] # TODO: remove id from these routes, use system helper to get id
    resources :users
    resources :reports, only: ['index']
    get 'reports/recent_conditions', to: "conditions#recent_as"
  end

  resources :categories, only: ['index']
  resources :contact, only: ['index', 'create']
  resources :researchers, only: ['index', 'edit', 'update']
  get 'researchers/trials/search', controller: 'researchers', action: 'search', as: :search_trials_researchers
  post 'researchers/trials/search', controller: 'researchers', action: 'search_results', as: :search_trial_results_researchers
  resources :sessions, only: ['new', 'create']
  delete 'sessions/destroy', controller: 'sessions', action: 'destroy', as: 'session' # manually creating this route to exclude requiring an id in the destroy route
  resources :studies, only: ['index', 'show']
  get 'studies/typeahead', controller: 'studies', action: 'typeahead'
  post 'studies/contact_team', controller: 'studies', action: 'contact_team'
  post 'studies/email_me', controller: 'studies', action: 'email_me'

  get 'splash', controller: 'home', action: 'splash', as: :splash
  get 'spotlight', controller: 'home', action: 'spotlight', as: :welcome
  get 'embed', controller: 'search', action: 'embed', as: :embed

  root 'home#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  # mount RailsBuilder::Engine => "/rails_builder"
end
