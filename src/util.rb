class OpenStruct
  def OpenStruct.from_json(str)
    json = JSON.parse(str)
    
    from_deep_hash(json)
  end
  
  def OpenStruct.from_deep_hash(obj)
    case obj
      when Array then obj.map {|i| from_deep_hash(i) }
      when Hash then OpenStruct.new(obj.map {|k,v| {k => from_deep_hash(v)}}.reduce({}){|m,v| m.merge! v})
      else obj
    end
  end
end

module URI
  class Generic
    # In-place version of URI#join
    def join!(str)
      pathary = self.path.split("/").select{|i| i != ""}
      
      m = %r{^(?:/?)([^#?]*?)(?:\?([^#]*?))?(?:\#(.*))?$}.match(str)
      joinpath = m[1].to_s.split("/")
      joinquery = m[2]
      
      joinpath.each do |i|
        case i
          when ".." then pathary.pop
          when "." then nil
          else pathary << i
        end
      end
      
      self.path = "/" + pathary.join("/")
      if joinquery
        self.query ||= ""
        self.query += joinquery
      end
      self.fragment = m[3] if m[3]
      
      self
    end
    
    # URI.join doesn't work like Pathname#join and isn't an instance method. This one
    # appends paths the way Pathname#join does and merges querystrings.
    # The latter is such that joining "http://foo.com/bar?a=1&b=2" and "?c=3" results in
    # http://foo.com/bar?a=1&b=2&c=3
    # nb. This doesn't handle fragments correctly.
    def join(str)
      self.dup.join!(str)
    end
  end
end