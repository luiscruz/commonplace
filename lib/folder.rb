class Folder
	attr_accessor :name, :content, :permalink

	def initialize(permalink, wiki, path)
		@path = path
		splits = path.split('/')
		@name = splits.last
		@permalink = permalink
#     splits.slice(1, splits.length - 1).join('/')
	end

	def content
		list = []
		Dir.glob("#{@path}/*.md") do |file|
			filename = file.split('/').last.chomp('.md')
			list << "- <a class=\"internal\" href=\"/#{@permalink + '/' + filename}\">" + filename.gsub('_', ' ') + "</a>"
		end
		Redcarpet.new(list.join("\n")).to_html.to_s
	end
end
