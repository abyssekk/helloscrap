class AddColumnsBoards < ActiveRecord::Migration[5.2]
  def change
    add_column :boards, :notice, :text, after: :body
  end
end
