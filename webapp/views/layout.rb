class Layout < Mustache
  attr_accessor :title
  attr_reader :avatars
  
  def homelink
    true
  end
  
end