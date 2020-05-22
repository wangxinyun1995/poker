class CreatePokerGames < ActiveRecord::Migration[5.2]
  def change
    create_table :poker_games do |t|
      t.timestamps
    end
  end
end
