require "sinatra"
require "sinatra/reloader" if development?
require "sass"
require 'data_mapper'
require 'dm-sqlite-adapter'

#connect DataMapper with the database blog.db
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/blog.db")

class Post
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :body, Text
  property :created_at, DateTime
  property :author, String
end

# Leg modellen vast
DataMapper.finalize

# Maak de poststabel aan in de database
Post.auto_upgrade!

enable :sessions

get '/' do
  erb :home
end

get '/style.css' do
  scss :"/scss/style"
end

get "/welcome/:name" do
  #params is een hash met daarin de variabelen die de route (get..do) binnenkrijgt
  @name = params[:name]
  erb :welcome
end

get '/about' do
  erb :about
end

get '/contact' do
  erb :about
end

get '/newpost' do
  erb :newpost
end

# @post en post zijn hier allebei goed - dit is de method
# waarbij de post wordt gemaakt (Post.new) en Post.save.
# deze route wordt ingezet vanaf "form"
post '/posts' do
  @post = Post.new(params[:post])
  @post.save
  redirect "/"
end

get '/posts' do
  @posts = Post.all
  @post = Post.get(params[:id])
  erb :posts
end

# READ - retrieves the relevant ("id") post from the database
# and shows it on a seperate page, then displays the relevant
# info for that post[:id] on the page
get '/post/:id' do
  erb :post
end

get '/post/:id/edit' do
  @post = Post.get(params[:id])
  erb :editpost
end

#this is a 'post' method (see editpost.erb), and should
# therefore start with post
post '/post/:id/edit' do
  @post = Post.get(params[:id])
  @post.attributes = params[:post]
  @post.save
  redirect '/posts'
end

get '/post/:id/delete' do
  @post = Post.get(params[:id])
  erb :deletepost
end

post '/post/:id/delete' do
  @post = Post.get(params[:id])
  @post.destroy
  redirect "/"
end

get '/login' do
  erb :login
end

post '/login' do
  if params[:username] == "Zitjepuik" &&
    params[:password] == "player"
    session[:logged_in] = true
    # Successfully login
  end

  redirect '/'
end

get '/logout' do
  session[:logged_in] = false
  redirect '/'
end
