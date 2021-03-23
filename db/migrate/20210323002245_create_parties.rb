class CreateParties < ActiveRecord::Migration[5.2]
  def change
    create_table :parties do |t|
      t.references :user, foreign_key: true
      t.references :movie, foreign_key: true
      t.time :start_time
      t.date :date

      t.timestamps
    end
  end
end
