require 'rails_helper'

RSpec.describe Party, type: :model do
  describe "relationships" do
    it { should belong_to :host }
    it { should belong_to :movie }
    it { should have_many :party_friends }
    it { should have_many(:users).through(:party_friends) }
  end

  describe "validations" do
    it { should validate_presence_of :host }
    it { should validate_presence_of :movie }
    it { should validate_presence_of :date }
    it { should validate_presence_of :start_time }
  end
end
