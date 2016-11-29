# Guardar los Twitter Handles(Controles de Twitter)
class TwitterUser < ActiveRecord::Base
  # Remember to create a migration!
  has_many :tweets

  def tweet_later(text)
    user_data = twitter_account.user_search(session[:username]).first                 # busca en API todo de usuario
    # tweet = # Crea un tweet relacionado con este usuario en la tabla de tweets
    Tweet.create(twitter_user_id: user_data.id, tweet_w: text)
    # Este es un método de Sidekiq con el cual se agrega a la cola una tarea para ser
    # 
    TweetWorker.perform_async(tweet.id)
    #La última linea debe de regresar un sidekiq job id
  end

end