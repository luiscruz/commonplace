require 'redcarpet'

class Folder
	attr_accessor :name, :content, :permalink, :file_system

	def initialize(permalink, wiki)
		@file_system = wiki.file_system
    @permalink = permalink
		splits = permalink.split('/')
		@name = splits.last

#     splits.slice(1, splits.length - 1).join('/')
	end

	def content
		list = []
		Dir.glob("#{@path}/*.md")
    #abort self.file_system.get_directory_files(self.permalink).inspect
    files = self.file_system.get_directory_files(self.permalink)
    files.reject! {|e| !e.end_with? '.md'}
    files.each do |file|
			filename = file.split('/').last.chomp('.md')
			list << "- <a class=\"internal\" href=\"/#{@permalink + '/' + filename}\">" + filename.gsub('_', ' ') + "</a>"
		end
		Redcarpet.new(list.join("\n")).to_html.to_s
	end
end
