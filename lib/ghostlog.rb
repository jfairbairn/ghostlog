%w(
  config
  document
  search_index
  importer
  filestore
).each do |f|
  require File.dirname(__FILE__) + '/ghostlog/' + f
end