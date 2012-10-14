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
      define_method(hookname) do
        result = super
        super << block.call
      end
    end
    
    def Skeleton.hook_partial(hookname, filename)
      partial = load_template(filename)
      hook_add hookname do
        partial.result(binding)
      end
    end
    
    def stylelink(sheetname)
      %Q{<link rel="stylesheet" href="#{Daptrius.static_url(sheetname)}"/>}
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
    
    attr :sitetitle, :pagetitle, :showheader, :showfooter, :showsidebar
    hook :toolbox, :head, :header, :content, :sidebar, :pagefooter
    
    def initialize(pagetitle)
      showheader = true
      showfooter = true
      showsidebar = true
      sitetitle = Daptrius.sitename
    end
  end
  
  class PageView
    hook_partial :toolbox "pageview_toolbox.erb"
    hook_partial :header, "pageview_header.erb"
    hook_partial :sidebar, "pageview_sidebar.erb"
    hook_add :content do
      page.formatted_content
    end
    
    attr :page
    
    def initialize(pg)
      super(page.title)
      page = pg
    end
  end
end