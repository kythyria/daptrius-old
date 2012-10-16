require 'json'
require 'pathname'
require 'ostruct'
require 'uri'

module Daptrius
  def Daptrius.templatedir
    @@root.join("templates")
  end
  
  def Daptrius.static_url(path="")
    @@config.static_url.join(path)
  end
  
  def Daptrius.url(path="", queryvars={})
    turl = @@config.baseurl.join(path)
    turl.query = queryvars.map{ |k,v| URI.escape(k.to_s + "=" + v) }.join("&")
    turl
  end
  
  def Daptrius.sitename
    @@config.sitename
  end
  
  def Daptrius.config
    @@config
  end
  
  def Daptrius.etherpad
    @@etherpad
  end
  
  def Daptrius.rootdir
    @@rootdir
  end
  
  def Daptrius.init!
    @@rootdir = Pathname.new(__FILE__).join("..")
    
    @@rawconfig = JSON.parse(@@rootdir.join("config.json"))
    @@config = OpenStruct.new(@@rawconfig)

    @@config.database ||= "sqlite://" + URI.escape(@@rootdir.join("var/data.sqlite"))
    
    @@config.base_url ||= "http://localhost:8080/"
    @@config.base_url = URI.parse(@@config.base_url)
    @@config.sitename ||= "Daptrius"
    
    @@etherpad = EtherpadLite.connect(@@config["etherpad"]["url"], @@config["etherpad"]["key"], 1.1)
    
    @@config.static_url ||= @@config.base_url
    
    DataMapper.connect(:default, @@config.database)
    DataMapper.auto_migrate!
  end
end