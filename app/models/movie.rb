class Movie < ApplicationRecord
  has_many :parties

  validates_presence_of :name
  validates_presence_of :duration
end
