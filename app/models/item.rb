class Item < ApplicationRecord
  belongs_to :todo_list

  validates :todo_list, presence: true
  validates :description, presence: true
end
