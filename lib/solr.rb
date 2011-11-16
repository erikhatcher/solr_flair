require 'net/http'
require 'net/https'
require 'cgi'

# TODO: Use RSolr
# TODO: Make Solr connection for Prism, Blacklight, and in general, pluggable... through RSolr ultimately
class Solr # but really it's a NetHttpSolrServer
  
  def self.get(url, handler, params={})
    url = URI.parse(url)
    connection = Net::HTTP.new(url.host, url.port)
    connection.use_ssl = true if url.scheme == "https"

    connection.get(url.path + '/select?' + hash_to_query_string(params.merge(:qt => handler)))
  end

  # TODO: RSolr will take care of this
  def self.hash_to_query_string(hash)
    hash.delete_if{|k,v| v==nil}.collect {|key,value|
      if value.respond_to?(:each) && !value.is_a?(String)
        value.delete_if{|v| v==nil}.collect { |v| "#{key}=#{CGI.escape(v.to_s)}"}.join('&')    
      else
        "#{key}=#{CGI.escape(value.to_s)}"
      end
    }.join('&')   
  end
  
end