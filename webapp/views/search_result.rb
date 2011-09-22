require 'nokogiri'

class SearchResult < Layout
  attr_accessor :doc
  attr_writer :avatars
  
  def content
    html = Nokogiri.HTML(@doc['fields']['content'])
    style = html.css('style')
    style.each do |s|
      s['scoped'] = 'scoped'
    end
    body = html.css('body')
    body.each do |b|
      b.first_element_child.add_previous_sibling(style)
    end
    body.inner_html
  end
  
  def title
    @doc['fields']['title']
  end
  
  MM_EMAIL = /^([^@]+)@mediamolecule\.com$/
  
  def author
    a = @doc['fields']['author']
    a = $1 if a =~ MM_EMAIL
    a  
  end
  
  def to_json(*args)
    @doc['fields'].to_json(*args)
  end
  
  def date
    Time.parse(@doc['fields']['date'])
  end
  
  def avatar
    avatars ? avatars.get(author) : nil
  end
  
end