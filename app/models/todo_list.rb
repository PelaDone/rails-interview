class TodoList < ApplicationRecord
  has_many :items

  validates :name, presence: true
  validates_uniqueness_of :name
end