require 'dropbox_sdk'

require_relative 'file_system_abstract'

class FileSystemDropbox < FileSystemAbstract
  attr_accessor :root, :client
  
  APP_KEY = 'mik9ymck8fy6797'
  APP_SECRET = 'glf280onty1il32'
  
  #FIXME:
  ACCESS_TOKEN = 'M8GMafCxPoYAAAAAAAAAAWmihV9mJ3zAYbhhBBTepVm9aNME0UKlK_LFUmuijbVs'
  USER_ID = '1656128'
  
  def initialize(root)
    @client = DropboxClient.new(ACCESS_TOKEN)
    @root = root
  end
  
  def self.new(root)
    instance = super
    return instance if instance.is_root_valid?
  end
  
  def new_file(path, content)
    absolute_path = get_absolute_path(path)
    response = client.put_file(absolute_path, content)
  end
  
  def mkdir(path)
    absolute_path = get_absolute_path(path)
    self.client.file_create_folder(absolute_path)
  end
  
  def get_file_content(path)
    absolute_path = get_absolute_path(path)
    content, metadata = client.get_file_and_metadata(absolute_path)
    return content
  end
  
  def get_directory_files(path)
    absolute_path = get_absolute_path(path)
    begin
      metadata = client.metadata(absolute_path)
    rescue
      return []
    end
    metadata["contents"].collect do |entry|
      entry_absolute_path = entry["path"]
      File.basename(entry_absolute_path)
    end
  end
  
  def is_directory?(path)
    absolute_path = get_absolute_path(path)
    begin
      return client.metadata(absolute_path)["is_dir"]
    rescue
    end
    return false
  end
  
  def is_file?(path, extension = nil)
    if extension
      filename  = File.basename(path)
      dirpath = File.dirname(path)
      path = File.join(dirpath, "#{filename}.#{extension}")
    end
      absolute_path = get_absolute_path(path)
    begin
      return !client.metadata(absolute_path)["is_dir"]
    rescue
    end
    return false
  end
  
  def get_absolute_path(path)
    File.join(self.root, path)
  end
  
  def is_root_valid?
    begin
      return client.metadata(self.root)["is_dir"]
    rescue
    end
    return false
  end
end