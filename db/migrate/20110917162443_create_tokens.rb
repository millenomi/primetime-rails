class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string :username
      t.string :token
      t.string :action

      t.timestamps
    end
  end
end
