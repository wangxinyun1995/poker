class AddWinnerToPokerGames < ActiveRecord::Migration[5.2]
  def change
    add_column :poker_games, :lemo_poker, :string
    add_column :poker_games, :judy_poker, :string
    add_column :poker_games, :winner, :string
  end
end
