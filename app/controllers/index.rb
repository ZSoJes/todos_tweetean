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
  puts "  ++~~++ "*100
  # El método `request_token` es uno de los helpers
  # Esto lleva al usuario a una página de twitter donde sera atentificado con sus credenciales
  redirect request_token.authorize_url(:oauth_callback => "http://#{host_and_port}/auth")
  # Cuando el usuario otorga sus credenciales es redirigido a la callback_url 
  # Dentro de params twitter regresa un 'request_token' llamado 'oauth_verifier'
end

get '/auth' do
  puts "Comenzar autenticacion"
  puts " +-+ "*100
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
  miUsuario = twitterUser_data(session[:username])
  
  existeUsuario = TwitterUser.find_by(name_user: session[:username])

  unless existeUsuario.nil?
    existeUsuario.token = session[:oauth_token]
    existeUsuario.token_secret = session[:oauth_token_secret]
    existeUsuario.save
  else
    TwitterUser.create(id: miUsuario.id,
                     name_user: session[:username],
                     token: session[:oauth_token],
                     token_secret: session[:oauth_token_secret])
  end
  # Aquí es donde deberás crear la cuenta del usuario y guardar usando el 'access_token' lo siguiente:
  # nombre, oauth_token y oauth_token_secret

  redirect to "/#{session[:username]}"
  # No olvides crear su sesión 
  # Para el signout no olvides borrar el hash de session
end

get '/:username' do
  puts "Cargando pagina...."
  puts "*"*100
  @busqueda = false;

  # TwitterUser.find_or_create_by(name_user: session[:username])             # ver los datos que retengo
  miUsuario = twitterUser_data(session[:username])                         # ver los datos que tiene twitter del usuario
  tuit_log = Tweet.where(id: miUsuario.id)                                 # busca los twits del este usuario en bd

  @full_name = miUsuario.name                                              # nombre
  @url = miUsuario.profile_image_url_https("original")                     # avatar


  @tweet = twitter_account.user_timeline(session[:username])

  if tuit_log.empty?                                                       # La base de datos no tiene tweets?
    @tweet.reverse_each do  |t|
      Tweet.create(twitter_user_id: miUsuario.id, tweet: t.text)
    end
  end

  @tiempo = Time.now - @tweet.first.created_at                             #desde el ultimo tuit
  if Time.now - @tweet.first.created_at > 500                              # si los tuits estan desactualizados
    @tweet.reverse_each do |t|
      if Tweet.find_by(tweet: t.text).nil?
        Tweet.create(twitter_user_id: miUsuario.id, tweet: t.text)
      end
    end
  end

  # Se hace una petición por los ultimos 10 tweets a la base de datos. 
  @tweets = Tweet.where(twitter_user_id: miUsuario.id).order(:created_at).last(10)
  erb :twitter_handle
end

post '/fetch' do
  @tweet = params[:mensaje]
  puts "Publicar un nuevo tweet..."
  puts "*"*100

  unless @tweet.blank?
    twitter_account.update(@tweet)
  end
end

post '/actualiza_lista' do
  puts "Recargar lista de tuits..."
  puts "*"*100

  miUsuario = twitterUser_data(session[:username])
  @tweet = twitter_account.user_timeline(miUsuario.user_name)
  @tweet.reverse_each do |t|
    if Tweet.find_by(tweet: t.text).nil?
      Tweet.create(twitter_user_id: miUsuario.id, tweet: t.text)
    end
  end

  @tweets = Tweet.where(twitter_user_id: miUsuario.id).order(:created_at).last(10)
  erb :tweet_list, layout: false 
end

post '/buscar' do
  @busqueda = true;

  miUsuario = twitterUser_data(params[:userName])
  @tweets_c = twitter_account.user_timeline(miUsuario.user_name)
  @tweets_c.reverse_each do  |t|
    if Tweet.find_by(tweet: t.text).nil?
      Tweet.create(twitter_user_id: miUsuario.id, tweet: t.text)
    end
  end

  @tweets = Tweet.where(twitter_user_id: miUsuario.id).order(:created_at).last(10)
  erb :tweet_list
end


get '/late/ya' do
  est = params[:estado]
  puts "estado: #{est}"
  puts "uso get"
  puts "*"*100
  puts session[:serie_num_id]
  erb :future
end

post '/late/ya/que' do
  tweet = params[:mensaje]
  time = params[:time]

  user = TwitterUser.find_by(name_user: session[:username])
  id = user.tweet_later(tweet, session[:serie_num_id])#, time)

  puts "*-*~~~~~~~+-+"*50
  puts "#{id}"
  puts job_is_complete(id)
  redirect to "/status/#{id}"
  # id
end

get '/status/:job_id' do
  # regresa el status de un job a una petición AJAX
  job_id = params[:job_id]
  if job_is_complete(job_id)
    @estado = true
  else
    @estado = false
  end
  redirect to '/late/ya'
end

post "/exit" do
  session.delete(:username)
  session.delete(:oauth_token)
  session.delete(:oauth_token_secret)
  redirect to "/"
end
