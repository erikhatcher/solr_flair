class FlairController < ApplicationController 
  def solr(core, handler, params)
    solr_url = "http://localhost:8888/solr/#{core}"
    # TODO: / handling for handler
    Solr.get(solr_url, "/#{handler}", params.merge(:wt=>:ruby, :'json.nl' => 'arrarr', :role => 'DEFAULT'))
  end
  
  def velaro(template, locals={}, layout=nil)
    Velaro.render(template,
                      # Template context objects
                      :locals => locals,
                      :layout => layout,
                      # Velocity engine parameters
                      :velocity => {
                        :'file.resource.loader.path' => "./app/views/flair",
                        :'resource.loader' => 'file'
                      })    
  end
  
  
  # this is what's wrong with Rails controllers for elegance... I just want [get '/prism'], not [def index] - use Sinatra instead (or Rack/Metal probably)
  # need to figure out how to map in Sinatra properly to Rails routing, then "bye def index"
  # params used here:
  # 
  #   core -
  #   handler -
  #   template -   
  def index
    http_response = solr(params[:core], params[:handler], params)
    solr_response = eval(http_response.body)
    
    # Hitting http://jira.codehaus.org/browse/JRUBY-6164 on JRuby 1.6.5.  Now switching to JRuby 1.6.3
    # another Rails annoyance...  but really need to wire Velaro in as a template renderer.  IIRC from past attempts, Rails3 made this much harder, but
    # it's trivial in Sinatra to add a renderer
    
    # TODO:   set content type, use render :html => ??, perhaps let template override with a #set?
    render :text => velaro(
      params[:template] || params[:handler] || :flair, # TODO: somehow params[:handler] consideration for template should be more dynamic
      {
        :solr => {
          # TODO: string keys required for now, but symbols should be made to work
          'response' => solr_response['response'], 
          'header' => solr_response['responseHeader'], 
          'raw_response' => http_response.body, 
        },
        :params => params
      },
      :layout)
  end
  
  def timeline_data
    http_response = solr(params[:core], params[:handler], params)
    solr_response = eval(http_response.body)
    xml = Builder::XmlMarkup.new
    xml.data do |b|
      solr_response['response']['docs'].each {|doc| 
        b.event("<a href=\"#{doc['id']}\">#{doc['title'] || doc['id']}</a>", :start => doc['lastModified'], :durationEvent => false)
      }
    end
    render :xml => xml.target!
  end
  
  def compare
    render :text => velaro(:compare, {}, :layout)
  end
  
  def venn
    # +a+'&facet.query={!key=b}'+b+'&facet.query={!key=c}'+c+'&facet.query={!key=intersect_ab}'+ab+'&facet.query={!key=intersect_ac}'+ac+'&facet.query={!key=intersect_bc}'+bc+'&facet.query={!key=intersect_abc}'+abc+'&q_a='+a+'&q_b='+b+'&q_c='+c+'&q_ab='+ab+'&q_ac='+ac+'&q_bc='+bc+'&q_abc='+abc

    # var ab='('+a+')+AND+('+b+')';
    # var ac='('+a+')+AND+('+c+')';
    # var bc='('+b+')+AND+('+c+')';
    # var abc='('+a+')+AND+('+b+')+AND+('+c+')';
    
    ab = "(#{params[:a]}) AND (#{params[:b]})"
    ac = "(#{params[:a]}) AND (#{params[:c]})"
    bc = "(#{params[:b]}) AND (#{params[:c]})"
    abc = "(#{params[:a]}) AND (#{params[:b]}) AND (#{params[:c]})"
    
    http_response = solr(params[:core], params[:handler],
      :q=>'*:*', :rows => 0,
      :'facet.query'=>
        ["{!key=a}#{params[:a]}", "{!key=b}#{params[:b]}","{!key=c}#{params[:c]}", 
        "{!key=ab}#{ab}", 
        "{!key=ac}#{ac}",
        "{!key=bc}#{bc}",
        "{!key=abc}#{abc}"]
    )
    solr_response = eval(http_response.body)

    render :text => velaro(:venn,
      'count'=>solr_response['facet_counts']['facet_queries'],
      'q' => {'a' => params[:a], 'b'=>params[:b], 'c'=>params[:c], 'ab'=>ab, 'ac'=>ac, 'bc'=>bc, 'abc'=>abc}
      )
  end
end