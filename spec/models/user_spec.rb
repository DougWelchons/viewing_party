require 'rails_helper'

RSpec.describe User, type: :model do
  describe "relationships" do
    it { should have_many :friends }
    it { should have_many :parties }
    it { should have_many :party_friends }
    it { should have_many(:parties).through(:party_friends) }
  end

  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should validate_presence_of :password }
  end
end
