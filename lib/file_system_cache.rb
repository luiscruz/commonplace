require 'moneta'
require_relative 'file_system_abstract'
require_relative 'folder'

class FileSystemCache < FileSystemAbstract
  attr_accessor :main_file_system, :store
  
  # APP_KEY = 'mik9ymck8fy6797'
  # APP_SECRET = 'glf280onty1il32'

  def initialize(main_file_system)
    @main_file_system = main_file_system
    
    @store = Moneta.new(:Memcached, expires: true)
    @store.clear() #prevent using cache from previous wikis
  end

  def new_file(path, content)
    main_file_system.new_file(path, content)
    store[escape_path(path)] = {isfile: true, content: content}
  end
  
  def mkdir(path)
    main_file_system.mkdir(path)
    store[escape_path(path)] = {isdir: true}
  end
  
  def get_file_content(path)
    # binding.remote_pry
    file = store[escape_path(path)] || {}
    file_content = file[:content]
    if file_content.nil?
      file_content = main_file_system.get_file_content(path)
      file[:content] = file_content
      store[escape_path(path)] = file
    end
    return file_content
  end
  
  def get_entries(path)
    directory = store[escape_path(path)] || {}
    entries = directory[:entries]
    if entries.nil?
      entries = main_file_system.get_entries(path)
      directory[:entries] = entries
      store[escape_path(path)] = directory
    end
    return entries
  end
  
  def is_directory?(path)
    directory = store[escape_path(path)] || {}
    if directory[:isdir].nil?
       directory[:isdir] = main_file_system.is_directory?(path)
       store[escape_path(path)] = directory
    end
    return directory[:isdir]
  end
  
  def is_file?(path, extension = nil)
    if extension
      filename  = File.basename(path)
      dirpath = File.dirname(path)
      path = File.join(dirpath, "#{filename}.#{extension}").to_s
    end
    
    file = store[escape_path(path)] || {}
    if file[:isfile].nil?
       file[:isfile] = main_file_system.is_file?(path)
       store[escape_path(path)] = file
    end
    return file[:isfile]
  end
  
  def escape_path path
    path = path.to_s
    if path.length == 0
      path = '/'
    end
    return path
  end
  
end