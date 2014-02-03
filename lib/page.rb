require 'redcarpet'

class Page
	attr_accessor :name, :permalink
	
	def initialize(content, permalink, wiki)
		@content = content # the raw page content
		@permalink = permalink
		@name = permalink.gsub('_', ' ').capitalize
		@wiki = wiki
	end
	
	# return html for markdown formatted page content
	def content
		return Redcarpet.new(parse_links(@content)).to_html
	end
	
	# return raw page content
	def raw
		return @content
	end
	
	# looks for links in a page's content and changes them into anchor tags
	def parse_links(content)
		return content.gsub(/\[\[(.+?)\]\]/m) do
			name = $1
			permalink = name.downcase.gsub(' ', '_')
			display_name = name.split('/').last
      
			if @wiki.page(permalink)
				"<a class=\"internal\" href=\"/#{permalink}\">" + display_name + '</a>'
			else 
				"<a class=\"internal new\" href=\"/#{permalink}\">" + display_name + '</a>'
			end
		end.to_s
	end	
end
