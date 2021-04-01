require 'rails_helper'
require 'ostruct'

RSpec.describe "Cast Facade" do
  it "person Atrabute" do
    VCR.use_cassette('cast_facade_test') do
      @show = CastFacade.new(2, 10)

      expect(@show.person).to be_an(OpenStruct)
      expect(@show.person).to respond_to(:id)
      expect(@show.person).to respond_to(:name)
      expect(@show.person).to respond_to(:profile_path)
      expect(@show.person).to respond_to(:biography)
    end
end

  it "person Atrabute" do
    VCR.use_cassette('cast_facade_test') do
      @show = CastFacade.new(2, 10)

      expect(@show.results).to be_an(Array)
      expect(@show.results[0]).to be_an(OpenStruct)
      expect(@show.results[0]).to respond_to(:id)
      expect(@show.results[0]).to respond_to(:title)
      expect(@show.results[0]).to respond_to(:poster_path)
      expect(@show.results[0]).to respond_to(:vote_average)
    end
  end
end
