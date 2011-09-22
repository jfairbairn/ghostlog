require 'bundler'
Bundler.setup
require 'sinatra'
require 'mustache/sinatra'
require 'ghostlog'

require 'fiber'
require 'thin'
require 'ghostlog/web/thin_fiber'

module Ghostlog
  
  module Views
  end
  
  class App < Sinatra::Base
    @@config = Config.new(File.expand_path('../config.yml', File.dirname(__FILE__)))
    @@index = Ghostlog::SearchIndex.new(@@config)
    
    @@avatars = Ghostlog::AvatarCache.new
    
    ROOT = File.dirname(__FILE__)
    register Mustache::Sinatra
    set :mustache, {
      templates: ROOT + '/templates',
      views: ROOT + '/views',
      namespace: Ghostlog
    }
  
    get '/' do
      @tags = @@config[:sources].values.map{|s|s[:tags]}.flatten.uniq.sort
      @title = 'Ghostlog FTW'
      mustache :index
    end  
    
    get '/projects/:project' do
      content_type 'text/html'
      @avatars = @@avatars
      @results = @@index.search({
        fields: '*',
        query: {
          filtered: {
            query: {match_all:{}},
            filter: {
              term: {tags: params[:project]},
              limit: 100
            },
            from: 0,
            size: 50,
            sort: [
              {date: {order: 'desc'}},'_score'
            ]
          }
        }
      })
      @title = params[:project].capitalize
      mustache :search_results
    end
    
    get '/projects/:project/debug' do
      content_type 'text/plain'
      @@index.search(term: {tags: params[:project]}).to_json
    end
    
    get '/r/:hash' do
      filepath = File.expand_path(params[:hash], File.join(File.dirname(__FILE__), '..', @@config[:filestore][:directory], params[:hash][0..1], params[:hash][2..3]))
      content_type JSON.parse(File.read(filepath + '.meta'))['type']
      send_file(filepath, :disposition => 'inline')
    end
  end
end

