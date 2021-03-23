class ChangeColumnNameParties < ActiveRecord::Migration[5.2]
  def change
    change_table :parties do |t|
      t.rename :user_id, :host_id
    end
  end
end
