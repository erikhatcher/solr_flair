module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior
  
  def link_to_document(doc, opts={:label=>nil, :counter => nil, :results_view => true})
    link_to doc[:title], "http://localhost:8989/collections/apachecon/document?id=#{CGI::escape(doc[:id])}"
  end
end