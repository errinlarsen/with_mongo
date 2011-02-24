require 'uri'
require 'mongo'
require './picker.rb'

class MyApp < Sinatra::Base
  get '/pickers' do
    db = get_db
    found = db['pickers'].find()
    @pickers = found.map { |p| Picker.new( p["name"], p["text"] )}
    haml :pickers
  end

  get '/pickers/show/:name' do
    db = get_db
    found = db['pickers'].find_one({ :name => params[:name] })
    @picker = Picker.new( found['name'], found['text'] )
    haml :picker_show
  end

  get '/pickers/random' do
    db = get_db
    random = db['pickers'].find().to_a.shuffle.shift
    picker = Picker.new( random['name'], random['text'] )
    
    redirect "/pickers/show/#{picker.name.gsub(/\s/, '%20')}"
  end

  get '/pickers/new' do
    haml :picker_new
  end

  post '/pickers/create' do
    name = params[:name]
    text = params[:text]
    picker = Picker.new( name, text )

    db = get_db

    if db['pickers'].find_one({ :name => picker.name })
      redirect '/pickers'
    else
      db['pickers'].insert( picker.to_doc )
      redirect "/pickers/show/#{name}"
    end
  end

  post '/pickers/destroy/:name' do
    db = get_db
    db['pickers'].remove({ :name => params[:name] })
    redirect '/pickers'
  end

  private
  def get_db
    if ENV['MONGOHQ_HOST']
      puts "Running on MongoHQ" 
      uri = URI.parse( ENV['MONGOHQ_URL'] )
      conn = Mongo::Connection.from_uri( ENV['MONGOHQ_URI'] )
      db = conn.db( uri.path.gsub( /^\//, '' ))
    else
      puts "Using local database" 
      db = Mongo::Connection.new.db( 'mydb' )
    end

    return db
  end
end
