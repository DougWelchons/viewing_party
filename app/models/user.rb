class User < ApplicationRecord
  has_many :friends
  has_many :parties
  has_many :party_friends
  has_many :parties, through: :party_friends

  validates :email, uniqueness: true, presence: true
  validates_presence_of :password, require: true
  validates_presence_of :name, require: true

  has_secure_password
end
