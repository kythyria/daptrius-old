require 'data_mapper'

class Page
  include DataMapper::Resource
  property :name,  String, :key => true
  property :title, String, :required => true 
  property :slug,  String, :required => true 
  
  has n, :children, self, :child_key => [:parent_id]
  belongs_to :parent, self
  
  validates_with_block :parent do
    curr = self
    while true
      curr = self.parent
      return true unless curr
      return [false,"Cycle detected in page hierarchy."] if curr == self
    end
  end
  
  # Return an array of all the items up to the root. Which we need anyway.
  def ancestors
    list = [self]
    curr = self
    while(curr = curr.parent)
      list << curr
    end
    list.reverse
  end
  
  # Return an array of all the siblings of this page.
  def siblings
    parent.children
  end
  
  # Return the path of this page that would be used in URLs
  def canonical_path
    "/" + ancestors.map{|i| URI.escape(i.slug)}.join("/")
  end
  
  def pad
    @pad = Daptrius.etherpad.pad(self.name) unless @pad
    @pad
  end
  
  def formatted_content
    @formatted_content = @pad.html unless @formatted_content
    @formatted_content
  end
end

class User
  include DataMapper::Resource
  
  property :id,       Serial
  property :name,     String, :required => true
  property :password, String, :required => true
end

DataMapper.finalize