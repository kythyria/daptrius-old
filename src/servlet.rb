require 'sinatra/base'
require 'rack/session/cookie'

module Daptrius
  class Servlet < Sinatra::Base
    #use Rack::Session::Cookie
    
    # Commented out until implemented
    
    #get '/daptrius'
    #get '/daptrius/login'
    #post '/daptrius/login'
    #get '/daptrius/logout'
    #post '/daptrius/logout'
    #get '/daptrius/pages'
    #get '/daptrius/page/:id'
    #post '/daptrius/page/:id'
    
    set :root, Daptrius.rootdir
    set :static, Daptrius.static_url == Daptrius.url
    
    get '/' do
      redirect to('/p/') # Not got a fancy homepage yet.
    end
    
    get '/p/' do
      raise "Index not implemented yet"
    end
    
    get '/p/*' do |path|
      components = path.split("/")
      curr = Page.first(:parent => nil, :slug => components.first ? components.shift : "")
      raise Sinatra::NotFound unless curr
      
      while components.first
        curr = Page.first(:parent => curr, :slug => components.shift)
        raise Sinatra::NotFound unless curr
      end
      
      view =  Templates::Page.new(curr)
      
      [200, {"Content-type" => "application/xhtml+xml"}, [view.result]]
    end
    
    not_found do
      [404, {"Content-type" => "application/xhtml+xml"}, [Templates::NotFound.result]]
    end
  end
end