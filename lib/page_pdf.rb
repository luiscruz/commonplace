
class PagePdf
	attr_accessor :name, :permalink
	
	def initialize(permalink, wiki)
		@permalink = permalink
		@name = permalink.gsub('_', ' ').capitalize
		@wiki = wiki
	end
  
  def content
    "Hello World. This is a pdf file -- #{@name}"
  end
  
	
end