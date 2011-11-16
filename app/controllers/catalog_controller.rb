# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class CatalogController < ApplicationController  

  include Blacklight::Catalog # TODO: get this renamed... "include Blacklight" would look slicker :)

  configure_blacklight do |config|
    config.default_solr_params = { 
      :qt => '/lucid',
      :per_page => 10,
      :role => 'DEFAULT',
      :echoParams => 'all' 
    }

    # solr field configuration for search results/index views
    config.index.show_link = 'title_display'
    config.index.record_display_type = 'format'

    # solr field configuration for document/show views
    config.show.html_title = 'title'
    config.show.heading = 'title'
    config.show.display_type = 'mimeType'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.    
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or 
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.  
    config.add_facet_field 'author_display', :label => 'Author' 
    config.add_facet_field 'mimeType', :label => 'MIME Type' 

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.default_solr_params[:'facet.field'] = config.facet_fields.keys

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display 
    config.add_index_field 'title', :label => 'Title:' 
    config.add_index_field 'dateCreated', :label => 'Created:' 
    config.add_index_field 'author_display', :label => 'Author:' 
    config.add_index_field 'mimeType', :label => 'MIME Type:' 

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display 
    # TODO: currently doesn't work with LWE since the "document" request handler isn't registered
    config.add_show_field 'title', :label => 'Title:' 
    config.add_show_field 'dateCreated', :label => 'Created:' 
    config.add_show_field 'author', :label => 'Author:' 
    config.add_show_field 'author_display', :label => 'Author:' 
    config.add_show_field 'mimeType', :label => 'MIME Type:' 

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different. 

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise. 
    
    config.add_search_field 'all_fields', :label => 'All Fields'

    config.add_sort_field 'score desc', :label => 'relevance'

    # If there are more than this many search results, no spelling ("did you 
    # mean") suggestion is offered.
    config.spell_max = 5
  end



end 
