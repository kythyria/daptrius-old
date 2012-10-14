require 'json'
require 'pathname'
require 'ostruct'
require 'uri'

module Daptrius
  def Daptrius.templatedir
    @@root.join("templates")
  end
  
  def Daptrius.static_url(path="")
    url("static").join(path)
  end
  
  def Daptrius.url(path="", queryvars={})
    turl = @config.baseurl.join(path)
    turl.query = queryvars.map{ |k,v| URI.escape(k.to_s + "=" + v) }.join("&")
    turl
  end
  
  def Daptrius.sitename
    @@config.sitename
  end
  
  def Daptrius.init!
    @@rootdir = Pathname.new(__FILE__).join("..")
    
    @@rawconfig = JSON.parse(@@rootdir.join("config.json"))
    @@config = OpenStruct.new(@@rawconfig)

    if @@rawconfig["database"]
      @@config.database = @@rawconfig["database"] ? @@rawconfig["database"]
    else
      @@config.database = "sqlite://" + URI.escape(@@rootdir.join("var/data.sqlite"))
    end
    
    @@config.baseurl = URI.parse(@@rawconfig["base_url"] ? @@rawconfig["base_url"] : "http://localhost:8080/")
    @@config.sitename = @@rawconfig["site_name"] ? @@rawconfig["site_name"] : "Daptrius"
    
    @@etherpad = EtherpadLite.connect(@@config["etherpad"]["url"], @@config["etherpad"]["key"], 1.1)
    
    DataMapper.connect(:default, @@config.database)
    DataMapper.auto_migrate!
  end
end