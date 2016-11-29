class TweetWorker < ActiveRecord::Base
  # Remember to create a migration!
  include Sidekiq::Worker

  def perform(tweet_id)
  	# tweet = # Encuentra el tweet basado en el 'tweet_id' pasado como argumento
    tweet = Tweets.find_by(id: tweet_id)
    puts ":::"*30
    puts "soy tweet #{tweet}"
    # user  = # Utilizando relaciones deberás encontrar al usuario relacionado con dicho tweet
    user = TweetUser.find_by(tweet.id)

    puts ":::"*30
    puts "soy user #{user}"

    id = user.tweet(tweet.tweet_w)
    # Manda a llamar el método del usuario que crea un tweet (user.tweet)
    twitter_account.update(user.tweet)
  end
end
