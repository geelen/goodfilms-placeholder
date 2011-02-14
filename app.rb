require 'sinatra'
require 'haml'
require 'digest/sha1'
require 'candy'
BSON::ObjectID = BSON::ObjectId
Candy.db = 'goodfilms'

set :haml, :format => :html5, :escape_html => true

class Object; alias :L :lambda; end

class PrivateBetaSignup; include Candy::Piece end
class PrivateBetaSignups; include Candy::Collection; collects :private_beta_signup end

before {
  puts "\n#{request.request_method} #{request.path} #{params.inspect}"
}

titles = L{|host| host =~ /movi/ ? 'goodmovi.es' : 'goodfil.ms' }
copies = [L{|title| film = title.gsub(/^good|\.|s$/,''); %Q{
  You love #{film}s. You love it when a #{film} leaves you breathless,
  staggered, elated or moved. And you hate it when a #{film} wastes
  your time.
}},L{|title| film = title.gsub(/^good|\.|s$/,''); %Q{
  Keep track of the #{film}s you plan to watch,
  who you want to watch them with,
  who recommended them to you,
  and which ones you thought were great.
}}]

get '/' do
  title = titles[request.host]
  copy = copies[Digest::SHA1.hexdigest(request.ip)[-1].hex % 2][title]
  haml :index, :locals => {title: title, copy: copy}
end

post '/signup' do
  PrivateBetaSignup.new(email: params[:email], ip: request.ip, host: request.host)
  title = titles[request.host]
  haml :signup, :locals => {title: title}
end

get '/:host/:copy' do
  title = titles[params[:host]]
  copy = copies[params[:copy].to_i][title]
  haml :index, :locals => {title: title, copy: copy}
end

get '*' do
  redirect '/'
end
