class AddUserIdBoards < ActiveRecord::Migration[5.2]
  def change
    add_reference :boards, :user, null: false, foreign_key: true
  end
end
