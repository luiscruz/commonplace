require 'find'
require 'pathname'

require_relative 'file_system_abstract'

class FileSystemLocal < FileSystemAbstract
  attr_accessor :root
  
  def initialize(root)
    @root = root
  end
  
  def self.new(root)
    instance = super
    return instance if instance.is_root_valid?
  end
  
  def new_file(path, content)
    f = File.new(get_absolute_path(path), "w")
		f.write(content)
		f.close
  end
  
  def mkdir(path)
    FileUtils.mkdir_p get_absolute_path(path)
  end
  
  def get_file_content(path)
    File.new(get_absolute_path(path), :encoding => "UTF-8").read
  end
  
  def get_directory_files(path)
    Dir.entries(get_absolute_path(path))
  end
  
  def is_directory?(path)
    File.directory? get_absolute_path(path)
  end
  
  def is_file?(path, extension = nil)
    if extension
      filename  = File.basename(path)
      dirpath = File.dirname(path)
      path = File.join(dirpath, "#{filename}.#{extension}")
    end
    File.file? get_absolute_path(path)
  end
  
  def get_absolute_path(path)
    File.join(self.root, path)
  end
  
  def is_root_valid?
    is_directory?('')
  end
  
end