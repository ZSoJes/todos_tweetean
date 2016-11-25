get '/' do
  erb :index
end

# get '/:handle' do
#   user = params[:handle]
#   user_data = CLIENT.user_search(user).first

#   @user_id = user_data.id
#   @full_name =user_data.name
#   @url = user_data.profile_image_url("original")

#   @tweets = CLIENT.user_timeline(user, count: 8)
#   erb :twitter_handle
# end

# post '/log' do
# user = params[:access_token]
# redirect to "/#{@access_token}"
# end

get '/sign_in' do
  puts "Comenzar login"
  puts "*"*100
# El método `request_token` es uno de los helpers
# Esto lleva al usuario a una página de twitter donde sera atentificado con sus credenciales
redirect request_token.authorize_url(:oauth_callback => "http://#{host_and_port}/auth")
# Cuando el usuario otorga sus credenciales es redirigido a la callback_url 
# Dentro de params twitter regresa un 'request_token' llamado 'oauth_verifier'
end

get '/auth' do
  puts "Comenzar autenticacion"
  puts "+"*100
# Volvemos a mandar a twitter el 'request_token' a cambio de un 'access_token' 
# Este 'access_token' lo utilizaremos para futuras comunicaciones.   
@access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
# Despues de utilizar el 'request token' ya podemos borrarlo, porque no vuelve a servir. 

puts "-"*100
session.delete(:request_token)

session[:oauth_token] = @access_token.params['oauth_token']
session[:oauth_token_secret] = @access_token.params['oauth_token_secret']
session[:username] = "@#{@access_token.params['screen_name']}"

puts session[:username]
puts "-"*100

TwitterUser.create(name_user: session[:username],token: session[:oauth_token],token_secret: session[:oauth_token_secret])

# Aquí es donde deberás crear la cuenta del usuario y guardar usando el 'access_token' lo siguiente:
# nombre, oauth_token y oauth_token_secret

redirect to "/#{session[:username]}"
# No olvides crear su sesión 
end
# Para el signout no olvides borrar el hash de session

get '/:username' do
  puts "Cargando pagina...."
  puts "*"*100
  @busqueda = false;
  CLIENT = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_KEY']
    config.consumer_secret     = ENV['TWITTER_SECRET']
    config.access_token        = session[:oauth_token]
    config.access_token_secret = session[:oauth_token_secret]
  end

  @user = session[:username]

tuit_user = TwitterUser.find_or_create_by(name_user: session[:username])
tuit_log = Tweet.where(id: tuit_user.id)                                 # busca los twits del este usuario en bd
user_data = CLIENT.user_search(session[:username]).first                 # busca en API todo de usuario


user = TwitterUser.find_by(name_user: @user)
user.user_id_by_twitter = user_data.id
user.save


@full_name = user_data.name                                              # nombre
@url = user_data.profile_image_url_https("original")                     # avatar


@tweets_c = CLIENT.user_timeline(user_data.user_name)

if tuit_log.empty?                                                       # La base de datos no tiene tweets?
  @tweets_c.reverse_each do  |t|
    Tweet.create(twitter_user_id: user_data.id, tweet_w: t.text)
  end
end

@tiempo = Time.now - @tweets_c.first.created_at                          #desde el ultimo tuit
if Time.now - @tweets_c.first.created_at > 500                           # si los tuits estan desactualizados
  @tweets_c.reverse_each do  |t|
    if Tweet.find_by(tweet_w: t.text).nil?
      Tweet.create(twitter_user_id: user_data.id, tweet_w: t.text)
    end
  end
end


# Se hace una petición por los ultimos 10 tweets a la base de datos. 
@tweets = Tweet.where(twitter_user_id: user_data.id).order(:created_at).last(10)
erb :twitter_handle
end

post '/fetch' do
  @tweet = params[:mensaje]
  puts "Publicar un nuevo tweet..."
  puts "*"*100

  CLIENT = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_KEY']
    config.consumer_secret     = ENV['TWITTER_SECRET']
    config.access_token        = session[:oauth_token]
    config.access_token_secret = session[:oauth_token_secret]
  end

  unless @tweet.blank?
    CLIENT.update(@tweet)
  end
end

post '/actualiza_lista' do
puts "Recargar lista de tuits..."
puts "*"*100

CLIENT = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_KEY']
  config.consumer_secret     = ENV['TWITTER_SECRET']
  config.access_token        = session[:oauth_token]
  config.access_token_secret = session[:oauth_token_secret]
end

user_data = CLIENT.user_search(session[:username]).first
@tweets_c = CLIENT.user_timeline(user_data.user_name)

@tweets_c.reverse_each do  |t|
  if Tweet.find_by(tweet_w: t.text).nil?
    Tweet.create(twitter_user_id: user_data.id, tweet_w: t.text)
  end
end

@tweets = Tweet.where(twitter_user_id: user_data.id).order(:created_at).last(10)
erb :tweet_list, layout: false 
end

post '/buscar' do
  puts params[:userName]
  @busqueda = true;

  CLIENT = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_KEY']
    config.consumer_secret     = ENV['TWITTER_SECRET']
    config.access_token        = session[:oauth_token]
    config.access_token_secret = session[:oauth_token_secret]
  end

  user_data = CLIENT.user_search(params[:userName]).first
  @tweets_c = CLIENT.user_timeline(user_data.user_name)
  @tweets_c.reverse_each do  |t|
    if Tweet.find_by(tweet_w: t.text).nil?
      Tweet.create(twitter_user_id: user_data.id, tweet_w: t.text)
    end
  end

  @tweets = Tweet.where(twitter_user_id: user_data.id).order(:created_at).last(10)
  erb :tweet_list
end

post "/exit" do
  session.delete(:username)
  session.delete(:oauth_token)
  session.delete(:oauth_token_secret)
  redirect to "/"
end