#encoding: UTF-8

require 'rubygems'
require 'find'
require 'pathname'

require_relative 'page'
require_relative 'folder'
require_relative 'file_system_local'

class Commonplace
	attr_accessor :dir
  attr_accessor :dir_path
  attr_accessor :file_system
	
	# initialize our wiki class
	def initialize(dir)
		@dir = dir
    @dir_path = Pathname.new(dir)
    @file_system = FileSystemLocal.new(dir)
	end
	
	# checks if our directory exists
	def valid?
		self.file_system != nil
	end
	
	# returns a raw list of files in our wiki directory, sans . and ..
	def files
		# if the directory doesn't exist, we bail out with a nil
		return nil unless File.directory? dir
		
		files_paths = get_directory_files(dir)
		
		files_paths
	end
	
	def get_directory_files(directory)
		entries = Dir.entries(directory)
		entries.delete_if { |e| e.start_with?('.') || e.start_with?('..')}
		
		
		dirs = entries.select { |e| File.directory? File.join(directory, e) }
		files = entries.select { |e| File.file? File.join(directory, e) }
		files.reject! {|e| !e.end_with? '.md'}
		files.map! do |e| 
			File.join(directory, e)
		end
    
    files_paths = [directory] | files
		
		
		if dirs
			dirs.each do |sub_dir|
        files_paths << get_directory_files(File.join(directory, sub_dir))
      end
		end
		
    files_paths
	end
	
	# returns an array of nown pages
	def list_pages(files_paths=nil)
    files_paths ||= self.files    
    
    directory = files_paths.shift

    directory_entry = entry_for_directory(directory)
    directory_entry[:files] = files_paths.map! do |entry|
      if entry.class == String
        entry_path = Pathname.new(entry)
        entry_rel_path = entry_path.relative_path_from(dir_path)
			  if File.file? entry
          link = entry_rel_path.to_path.chomp(".md")
				  {:dir => false, :title => file_to_pagename(entry), :link => link}
			  end
      elsif entry.class == Array
         list_pages(entry)       
      end
    end
    
    directory_entry
	end
	
	def entry_for_directory(directory)
    directory_path = Pathname.new(directory)
    dirname = directory_path.relative_path_from(dir_path).to_path
    
		splits = dirname.split('/')
		if dirname == "."
			title = "Root"
		else
			title = splits.join(" » ")
		end
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
		filename.split('/').last.chomp(".md").gsub('_', ' ').capitalize
	end
		
	# returns a page instance for a given filename
	def page(permalink)
		file = dir + '/' + permalink + '.md'
		dir_path = dir + '/' + permalink
		# check if this is a directory path
		if File.directory?(dir_path)
			return Folder.new(permalink, self, dir_path)
		elsif File.exists? file
			# check if we can read content, return nil if not
			content = File.new(file, :encoding => "UTF-8").read
			return nil if content.nil?
			
			# return a new Page instance
			return Page.new(content, permalink, self)
		end
		nil
	end

	# create a new page and return it when done
	def save(permalink, content)
		# FIXME - if the file exists, this should bail out
		
		# write the contents into the file
		file = dir + '/' + permalink + '.md'
		f = File.new(file, "w")
		f.write(content)
		f.close
		
		# return the new file
		return page(permalink)
	end
end




