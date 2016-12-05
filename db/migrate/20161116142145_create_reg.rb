class CreateReg < ActiveRecord::Migration
  def change
    create_table :twitter_users, {id: false} do |t|
      t.integer :id   #id personalizado, no autoincrement
      t.string :name_user
      # t.string :user_id_by_twitter
      t.string :token           # tokens temporales
      t.string :token_secret    # por usuarios o usuario
    end
    execute "ALTER TABLE twitter_users ADD PRIMARY KEY (id);"

    create_table :tweets do |t|
      t.belongs_to :twitter_user, index: true
      t.string :tweet
      t.timestamp :created_at
    end
  end
end
