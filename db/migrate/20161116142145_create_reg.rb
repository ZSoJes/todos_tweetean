class CreateReg < ActiveRecord::Migration
  def change
    create_table :twitter_users, :id => false do |t|
      t.integer :id, :null => false   #id personalizado, no autoincrement
      t.string :name_user
      t.string :user_id_by_twitter
      t.string :token           # tokens temporales
      t.string :token_secret    # por usuarios o usuario
    end
    add_index :twitter_user, :id, :unique => true

    create_table :tweets do |t|
      t.belongs_to :twitter_user, index: true, :limit => 8
      t.string :tweet_w
      t.timestamp :created_at
    end
  end
end
