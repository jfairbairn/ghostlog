require 'bundler'
Bundler.setup
require 'sinatra'
require 'mustache/sinatra'


module GhostLog
  module Views
  end
  
  class App < Sinatra::Base
    ROOT = File.dirname(__FILE__)
    register Mustache::Sinatra
    set :mustache, {
      templates: ROOT + '/templates',
      views: ROOT + '/views',
      namespace: GhostLog
    }
  
    get '/' do
      mustache :index
    end  
  end
end

