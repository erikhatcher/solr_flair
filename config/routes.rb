SolrFlair::Application.routes.draw do
  Blacklight.add_routes(self)

  root :to => "catalog#index"

  root :to => "catalog#index" # route to main Blacklight front-end as /browse
  constraints :id => /.+/ do #  added to handle LucidWorks web/file crawl ids which are the URLs (http://projectblacklight.org/..)
    Blacklight.add_routes(self)
  end



# Solr pass-through
  # get '/solr/?:core?/?:handler?' do
  #   solr_core = params[:core] ? ('/' + params[:core]) : ''
  #   solr_url = "http://localhost:8983/solr#{solr_core}"
  #   http_response = solr(solr_url, params[:handler] ? "/#{params[:handler]}" : nil, params)
  # 
  #   [http_response.code.to_i, http_response.to_hash, http_response.body]
  # end

  get '/flair/hello' => 'flair#index', :core => 'apachecon', :handler => 'lucid', :template => 'hello', :world => 'ApacheCon'
  
  get '/flair/timeline' => 'flair#index', :core => 'apachecon', :handler => 'lucid', :template => 'timeline'
  get '/flair/timeline_data' => 'flair#timeline_data', :core => 'apachecon', :handler => 'lucid'
  
  get '/flair/compare' => 'flair#compare'
  get '/flair/venn' => 'flair#venn', :core => 'apachecon', :handler => 'lucid'
  
  # get '/flair' => 'flair#index', :core => 'apachecon', :handler => 'lucid'
      
# example of a not-atypical need of getting some data from search results in an easy-to-digest format, showing that no template technology is needed,
# but a little bit of code is all it takes to get what you want
# get '/ids/:core/:handler', :to => proc {|env| 
#   solr(:core, :handler, params).docs.collect {|doc| doc[:id]}.join(',')
#}










  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
