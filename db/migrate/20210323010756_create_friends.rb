class CreateFriends < ActiveRecord::Migration[5.2]
  def change
    create_table :friends do |t|
      t.references :user
      t.references :friend

      t.timestamps
    end

    add_foreign_key :friends, :users, column: :user_id, primary_key: :id
    add_foreign_key :friends, :users, column: :friend_id, primary_key: :id
  end
end
