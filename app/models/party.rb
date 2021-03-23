class Party < ApplicationRecord
  belongs_to :host, class_name: 'User'
  belongs_to :movie
  has_many :party_friends
  has_many :users, through: :party_friends

  validates_presence_of :host, require: true
  validates_presence_of :movie, require: true
  validates_presence_of :date, require: true
  validates_presence_of :start_time, require: true
end
