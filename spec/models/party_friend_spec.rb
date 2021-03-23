require 'rails_helper'

RSpec.describe PartyFriend, type: :model do
  describe "relationships" do
    it { should belong_to :party }
    it { should belong_to :user }
  end

  describe "validations" do
    it { should validate_presence_of :party }
    it { should validate_presence_of :user }
  end
end
