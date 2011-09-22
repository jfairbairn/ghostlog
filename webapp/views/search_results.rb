require File.dirname(__FILE__) + '/search_result'

class SearchResults < Layout
  def results
    @results['hits']['hits'].map{|i|s=SearchResult.new.tap{|s|s.doc=i}}
  end
end