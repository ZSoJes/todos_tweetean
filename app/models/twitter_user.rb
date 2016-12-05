# Guardar los Twitter Handles(Controles de Twitter)
class TwitterUser < ActiveRecord::Base
  # Remember to create a migration!
  has_many :tweets

  def tweet_later(text,user_id)
    # tweet = # Crea un tweet relacionado con este usuario en la tabla de tweets
    # TweetWorker.perform_in(1.minutes, 'mike', 1)
    tweet = Tweet.create(twitter_user_id: user_id, tweet_w: text)
    # Este es un método de Sidekiq con el cual se agrega a la cola una tarea para ser
    # 
    puts "tweet.id #{tweet.id}"
    puts "user.id #{user_id}"
    # TweetWorker.perform(user_id)
    TweetWorker.perform_async(tweet.id)
    #La última linea debe de regresar un sidekiq job id
  end

end