require './lib/commonplace'
require 'rubygems'
require 'sinatra'
require "sinatra/content_for"
require 'erb'
require 'yaml'
require_relative 'helpers'

class CommonplaceServer < Sinatra::Base	
  
  # HElpers
  helpers Sinatra::ContentFor
  helpers Helpers
  
  # jruby replacement for shotgun
  if defined?( JRUBY_VERSION )
    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader
      also_reload "./lib/*.rb"
    end
  end
  
  # Read configuration file
  configure do
    config = YAML::load(File.open("config/commonplace.yml"))
    set :config, {
      file_system: config['file_system'] || 'local',
      dropbox_access_token: config['dropbox_access_token'],
      dir: config['wikidir']
    }
    set :sitename, config['sitename']
    set :readonly, config['readonly']
    set :public_folder, "public"
    set :views, "views"
  end

  # Create Wiki
	configure do
    set :wiki, Commonplace.new(settings.config)
	end
  
  before do
    @wiki ||= settings.wiki
  end

	# if we've locked editing access on the config file, 
	# every method that edits, saves redirects to root
	# maybe this could be more elegant?
	before '/p/*' do 
		redirect "/" if settings.readonly
	end
	
	# show the homepage
	get '/' do
		show('_home', true)
	end
	
	# show the known page list
	get '/list' do
		@name = "Known pages"
		@pages = @wiki.list_pages
		erb :list
	end

	# show everything else
	get '/:page/raw' do
		@page = @wiki.page(params[:page])
		@page.raw.to_s
	end
	
	# edit a given page
	get	'/p/*/edit' do
		page_name = params[:splat].first
		@page = @wiki.page(page_name)
		if @page
			@name = "Editing " + @page.name
			@editing = true
			erb :edit
		else
			status 404
			@name = "404: Page not found"
			erb :error404
		end
	end
	
	# accept updates to a page
	post '/p/*/edit' do
		page_name = params[:splat].first
		page = @wiki.save(page_name, params[:content])
		redirect "/#{page.permalink}"
	end

	# create a new page
	get '/p/new/?' do
		@name = "New page"
		@editing = true
		erb :new
	end
	
	# create a new page
	get '/p/new/*' do |new_page_permalink|
    @new_page_permalink = new_page_permalink
		@newpagename = Page.permalink_to_title(new_page_permalink)
		@name = "Creating #{@newpagename}"
		@editing = true
		erb :new
	end
	
	# get all pages inside directories
	get '/*' do |page_name|
		show(page_name)
	end

	# save the new page
	post '/p/save' do
		if params[:filename] && params[:filename] != ""
			filename = params[:filename].gsub(" ", "_").downcase
			page = @wiki.save(filename, params[:content])
			redirect "/#{page.permalink}"
		else
			@alert = "You're missing something important - a page name. Please add that."
			@name = "New page"
			@content = params[:content]
			erb :new
		end
	end

	# returns a given page (or file) inside our repository
	def show(permalink, show_list_if_page_not_found=false)
		if !@wiki.valid?
			status 500
			@name = "Wiki directory not found"
			@error = "We couldn't find the wiki directory your configuration is pointing to.<br/>Fix that, then come back - we'll be happier then."
			erb :error500
		else
      @permalink = permalink
			if @page = @wiki.page(permalink)
				# may success come to those who enter here.
				@name = @page.name
				@content = @page.content
				erb :show
      elsif show_list_if_page_not_found
        redirect '/list'
			else
				status 404
				@newpage = permalink
				@name = "404: Page not found"
				erb :error404
			end
		end
	end
end
