%w(
  config
  document
  search_index
).each do |f|
  require File.dirname(__FILE__) + '/ghostlog/' + f
end