require 'sinatra/base'
require 'rack/session/cookie'

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
  
  get '/*' do |path|
    components = path.split("/")
    curr = Page.find(:parent => nil, :slug => components.shift)
    raise Sinatra::NotFound unless curr
    
    while components.first
      curr = Page.find(:parent => curr, :slug => components.shift)
      raise Sinatra::NotFound unless curr
    end
    
    view =  PageView.new(curr)
    
    [200, {"Content-type" => "application/xhtml+xml"}, [view.result]]
  end
  
  not_found do
    [404, {"Content-type" => "application/xhtml+xml"}, [Templates::NotFound.result]]
  end
end