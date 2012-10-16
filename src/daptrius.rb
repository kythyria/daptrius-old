require 'json'
require 'pathname'
require 'ostruct'
require 'uri'
require 'etherpad-lite'
require 'data_mapper'

require 'src/util'

module Daptrius
  def Daptrius.templatedir
    @@rootdir.join("templates")
  end
  
  def Daptrius.static_url(path="")
    @@config.static_url.join(path)
  end
  
  def Daptrius.url(path="", queryvars={})
    turl = @@config.base_url.join(path)
    turl.query = queryvars.map{ |k,v| URI.escape(k.to_s + "=" + v) }.join("&") unless queryvars.empty?
    turl
  end
  
  def Daptrius.site_name
    @@config.site_name
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
    @@rootdir = Pathname.new(__FILE__).join("../..")
    
    @@config = OpenStruct.from_json(File.read(@@rootdir.join("config.json").to_s))

    @@config.database ||= "sqlite://" + URI.escape(@@rootdir.join("var/data.sqlite").to_s)
    
    @@config.base_url ||= "http://localhost:8080/"
    @@config.base_url = URI.parse(@@config.base_url)
    @@config.site_name ||= "Daptrius"
    
    @@etherpad = EtherpadLite.connect(@@config.etherpad.url, @@config.etherpad.key, 1.1)
    
    @@config.static_url ||= @@config.base_url
    
    DataMapper.setup(:default, @@config.database)
    DataMapper.auto_migrate!
  end
end

Daptrius.init!

require 'src/models'
require 'src/servlet'
require 'src/views'

