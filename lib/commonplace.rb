#encoding: UTF-8

require 'rubygems'
require 'markdown'
require 'find'

require_relative 'page'
require_relative 'page_pdf'
require_relative 'folder'
require_relative 'file_system_local'

class Commonplace
	attr_accessor :dir
  attr_accessor :dir_path
  attr_accessor :file_system
	
	# initialize our wiki class
	def initialize(dir)
    @file_system = FileSystemLocal.new(dir)
	end
	
	# checks if our directory exists
	def valid?
		self.file_system != nil
	end
	
	# returns a raw list of files in our wiki directory, sans . and ..
	def files
		files_paths = get_directory_files('')
		
		files_paths
	end
	
	def get_directory_files(base_permalink)
		entries = self.file_system.get_directory_files(base_permalink)
		entries.delete_if { |e| e.start_with?('.') || e.start_with?('..')}
		
		
		dirs = entries.select { |e| file_system.is_directory? "#{base_permalink}/#{e}" }
		files = entries.select { |e| file_system.is_file? "#{base_permalink}/#{e}" }
		files.reject! {|e| !(e.end_with?('.md') || e.end_with?('.pdf'))}
		files.map! do |e| 
			File.join(base_permalink, e)
		end
    
    files_paths = [base_permalink] | files
		
		
		if dirs
			dirs.each do |sub_dir|
        files_paths << get_directory_files(File.join(base_permalink, sub_dir))
      end
		end
		
    files_paths
	end
	
	# returns an array of known pages
	def list_pages(files_paths=nil)
    files_paths ||= self.files    
    
    directory = files_paths.shift

    directory_entry = entry_for_directory(directory)
    directory_entry[:files] = files_paths.map! do |entry|
      if entry.class == String
			  if self.file_system.is_file? entry
          link = entry.chomp(".md")
          link[0] = '' if link[0] == '/'
          link = entry.chomp(".pdf")
          link[0] = '' if link[0] == '/'
          #FIXME
				  {:dir => false, :title => file_to_pagename(entry), :link => link}
			  end
      elsif entry.class == Array
         list_pages(entry)       
      end
    end
    
    directory_entry
	end
	
	def entry_for_directory(directory)    
		splits = directory.split('/')
		if directory == "."
			title = "Root"
		else
			title = splits.join(" » ")
		end
    splits.shift if splits.first && splits.first.empty?
		{:dir => true, :title => title, :link => splits.join('/')}
	end
	
	# converts a pagename into the permalink form
	def get_permalink(pagename)
		pagename.gsub(" ", "_").downcase
	end
	
	# converts a permalink to the full page name
	def get_pagename(permalink)
		permalink.gsub('_', ' ').capitalize
	end
	
	# converts a pagename into the full filename
	def get_filename(pagename)
		get_permalink(pagename) + ".md"
	end
	
	# converts a filename into a page title
	def file_to_pagename(filename)
		File.basename(filename, '.*').gsub('_', ' ').capitalize
	end
		
	# returns a page instance for a given filename
	def page(permalink)
		# check if this is a directory path
		if self.file_system.is_directory?(permalink)
			return Folder.new(permalink, self)
		elsif self.file_system.is_markdown? permalink
			# check if we can read content, return nil if not
			content = self.file_system.get_file_content(permalink+'.md')
			return nil if content.nil?
			# return a new Page instance
			return Page.new(content, permalink, self)
    elsif self.file_system.is_pdf?(permalink)
      return PagePdf.new(permalink, self)
		end
		nil
	end

	# create a new page and return it when done
	def save(permalink, content)
		# FIXME - if the file exists, this should bail out

		# always strip leading / from filename
		permalink.slice!(0) if permalink.start_with?( '/' )


    # create file path recursively
		path = Pathname.new( permalink ).dirname
		self.file_system.mkdir(path)

		# write the contents into the file
		self.file_system.new_file(permalink+'.md', content)
		
		# return the new file
		return page(permalink)
	end
end
