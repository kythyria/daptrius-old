require 'erb'

module Templates
  class Skeleton
    
    def Skeleton.load_template(filename)
      ERB.new(File.read(Daptrius.templatedir.join(filename)))
    end
    
    def Skeleton.hook(*hooknames)
      hooknames.each do |i|
        define_method(i) do
          return ""
        end
      end
    end
    
    def Skeleton.hook_add(hookname, &block)
      define_method(("hook_on_"+hookname.to_s).to_sym, &block)
      class_eval("def #{hookname}
        result = super()
        super() << hook_on_#{hookname.to_s}
      end")
    end
    
    def Skeleton.hook_partial(hookname, filename)
      partial = load_template(filename)
      hook_add hookname do
        partial.result(binding)
      end
    end
    
    def stylelink(sheetname)
      %Q{<link rel="stylesheet" href="#{Daptrius.static_url.join("css").join(sheetname)}"/>}
    end
    
    def link_for_page(pg, anchor=nil)
      url = Daptrius.url(pg.canonical_path)
      text = anchor ? anchor : page.title
      %Q{<a href="#{url}">#{text}</a>}
    end
    
    def result
      @@template.result(binding)
    end
    
    @@template = load_template("skeleton.erb")
    
    attr_accessor :sitetitle, :pagetitle, :showheader, :showfooter, :showsidebar
    hook :toolbox, :head, :header, :content, :sidebar, :pagefooter, :scripts
    
    def initialize(pagetitle)
      self.showheader = true
      self.showfooter = true
      self.showsidebar = true
      self.sitetitle = Daptrius.site_name
      self.pagetitle = pagetitle
    end
  end
  
  class Page < Skeleton
    hook_partial :head, "pageview_head.erb"
    hook_partial :toolbox, "pageview_toolbox.erb"
    # Disabled until we have the infrastructure to talk about authors
    #hook_partial :header, "pageview_header.erb" 
    hook_partial :sidebar, "pageview_sidebar.erb"
    hook_add :content do
      self.page.formatted_content
    end
    
    attr_accessor :page
    
    def initialize(pg)
      super(pg.title)
      self.page = pg
    end
  end
  
  class NotFound < Skeleton
    hook_partial :content, "notfound_content.erb"
    
    def initialize()
      super("404 Not Found")
      self.showsidebar = false
    end
    
    def NotFound.result
      new.result
    end
  end
end