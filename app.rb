require 'sinatra'
require 'haml'
require 'digest/sha1'
require 'candy'
# Candy.db = 'goodfilms'

set :haml, :format => :html5, :escape_html => true

class Object; alias :L :lambda; end

class PrivateBetaSignup; include Candy::Piece; end

titles = L{|host| host =~ /movi/ ? 'goodmovi.es' : 'goodfil.ms' }
copies = [L{|title| film = title.gsub(/^good|\.|s$/,''); %Q{
  You love #{film}s. You love it when a #{film} leaves you breathless,
  staggered, elated or moved. And you hate it when a #{film} wastes
  your time.
}},L{|title| film = title.gsub(/^good|\.|s$/,''); %Q{
  Keep track of the #{film}s you plan to watch,
  who you want to watch it with,
  who recommended it to you,
  and whether you thought it was great.
}}]

get '/' do
  title = titles[request.host]
  copy = copies[Digest::SHA1.hexdigest(request.ip)[-1].hex % 2][title]
  haml :index, :locals => {title: title, copy: copy}
end

get '/signup' do
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
