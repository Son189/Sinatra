require "sinatra"
require "sinatra/activerecord"
require "sinatra/reloader"
require_relative "config/database.yml"

require 'yaml'

# Load the database configuration from database.yml
db_config = YAML.load_file('./config/database.yml')

# Configure the database connection
ActiveRecord::Base.establish_connection(db_config['development'])

# Define your models here
class Meme < ActiveRecord::Base
end

db_config = YAML.load_file('./config/database.yml')
ActiveRecord::Base.establish_connection(db_config['development'])
class App < ActiveRecord::Base

enable :sessions

get "/" do
  erb :home
end

get "/signup" do
  erb :signup
end

post "/signup" do
  user = User.new(
    username: params[:username],
    password: params[:password]
  )

  if user.save
    session[:user_id] = user.id
    redirect "/login"
  else
    erb :signup
  end
end

get "/login" do
  erb :login
end

post "/login" do
  user = User.find_by(username: params[:username])

  if user && user.authenticate(params[:password])
    session[:user_id] = user.id
    redirect "/home"
  else
    erb :login
  end
end

get "/home" do
  erb :home
end
post '/memes' do
  meme = Meme.new(
    top_text: params[:top_text],
    bottom_text: params[:bottom_text],
    image_url: params[:image_url]
  )
  if meme.save
    status 201
    meme.to_json
  else
    status 422
    { error: meme.errors.full_messages }.to_json
  end
end

# Get all memes
get '/memes' do
  memes = Meme.all
  memes.to_json
end

# Search for memes
get '/memes/search' do
  query = params[:q]
  memes = Meme.where('top_text LIKE ? OR bottom_text LIKE ?', "%#{query}%", "%#{query}%")
  memes.to_json
end

# Delete meme
delete '/memes/:id' do
  meme = Meme.find(params[:id])
  if meme.destroy
    status 204
  else
    status 422
    { error: 'Failed to delete meme' }.to_json
  end
end
end