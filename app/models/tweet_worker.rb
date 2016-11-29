class TweetWorker < ActiveRecord::Base
  # Remember to create a migration!
  include Sidekiq::Worker

  def perform(tweet_id)
  	# tweet = # Encuentra el tweet basado en el 'tweet_id' pasado como argumento
    tweet = Tweet.find(tweet_id)
    # puts ":::"*30
    # puts "soy tweet"
    # user  = # Utilizando relaciones deberás encontrar al usuario relacionado con dicho tweet
    user = TwitterUser.find_by(user_id_by_twitter: tweet.twitter_user_id)

    # puts ":::"*30
    # puts "soy user #{user}"

    # id = user.tweet(tweet.tweet_w)
    # Manda a llamar el método del usuario que crea un tweet (user.tweet)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_KEY']
      config.consumer_secret     = ENV['TWITTER_SECRET']
      config.access_token        = session[:oauth_token]
      config.access_token_secret = session[:oauth_token_secret]
    end
      client.update(tweet.tweet_w)
  end
end
