class PartyFriend < ApplicationRecord
  belongs_to :user
  belongs_to :party

  validates_presence_of :party
  validates_presence_of :user
end
