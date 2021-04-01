require 'rails_helper'
require 'ostruct'

RSpec.describe "Movie Facade" do
  describe ".top_rated" do
    it "returns an array of movie objects equal to or less the limit" do
      VCR.use_cassette('top_40_movies') do
        limit = 40
        expect(MovieFacade.top_rated(limit)).to be_an(Array)
        expect(MovieFacade.top_rated(limit).length).to be <= limit
      end
    end

    it "returnds an OpenStruct object with appropriate values" do
      VCR.use_cassette('top_40_movies') do
        limit = 40
        data = MovieFacade.top_rated(limit)
        expect(data[0]).to be_an(OpenStruct)
        expect(data[0]).to respond_to(:id)
        expect(data[0]).to respond_to(:title)
        expect(data[0]).to respond_to(:vote_average)
        expect(data[0]).to respond_to(:poster_path)
      end
    end

    it "returnes an error if the request is not completed" do
      api_key = ENV['movie_api_key']
      stub_request(:get, "https://api.themoviedb.org/3/movie/top_rated?api_key=#{api_key}&language=en-US&page=1").
        to_return(status: 500, body: "", headers: {})

      limit = 40
      data = MovieFacade.top_rated(limit)

      expect(data).to eq({error: true})
    end
  end

  describe ".search" do
    it "returns an array of movie objects equal to limit" do
      VCR.use_cassette('search_for_movies') do
        limit = 40
        keywords = 'the'
        expect(MovieFacade.search(keywords, limit)).to be_an(Array)
        expect(MovieFacade.search(keywords, limit).length).to be <= limit
      end
    end

    it "returns an array of all movie objects if less then the limit" do
      VCR.use_cassette('search_for_movies_short') do
        limit = 40
        keywords = 'finding nemo'
        expect(MovieFacade.search(keywords, limit).length).to be <= limit
      end
    end

    it "returnds an OpenStruct object with appropriate values" do
      VCR.use_cassette('search_for_movies') do
        limit = 40
        keywords = 'the'
        data = MovieFacade.search(keywords, limit)
        expect(data[0]).to be_an(OpenStruct)
        expect(data[0]).to respond_to(:id)
        expect(data[0]).to respond_to(:title)
        expect(data[0]).to respond_to(:vote_average)
        expect(data[0]).to respond_to(:poster_path)
      end
    end

    it "returnes an error if the request is not completed" do
      api_key = ENV['movie_api_key']
      stub_request(:get, "https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&include_adult=false&language=en-US&page=1&query=the").
        to_return(status: 500, body: "", headers: {})
      keywords = "the"
      limit = 40
      data = MovieFacade.search(keywords, limit)

      expect(data).to eq({error: true})
    end
  end

  describe ".movie_info" do
    it "returnds an OpenStruct object with appropriate values" do
      VCR.use_cassette('all_movie_info') do
        movie_id = 550
        data = MovieFacade.movie_info(movie_id)
        expect(data).to be_an(OpenStruct)
        expect(data).to respond_to(:id)
        expect(data).to respond_to(:title)
        expect(data).to respond_to(:genres)
        expect(data).to respond_to(:runtime)
        expect(data).to respond_to(:runtime_hours)
        expect(data).to respond_to(:runtime_mins)
        expect(data).to respond_to(:vote_average)
        expect(data).to respond_to(:overview)
        expect(data).to respond_to(:cast)
        expect(data).to respond_to(:reviews)
        expect(data).to respond_to(:poster_path)
      end
    end
  end

  describe ".trending" do
    it "returns an array of movie objects equal to or less the limit" do
      VCR.use_cassette('trending_movies') do
         limit = 40
        expect(MovieFacade.trending(limit)).to be_an(Array)
        expect(MovieFacade.trending(limit).length).to be <= limit
       end
     end

    it "returnds an OpenStruct object with appropriate values" do
      VCR.use_cassette('trending_movies') do
        limit = 40
         data = MovieFacade.trending(limit)
         expect(data[0]).to be_an(OpenStruct)
        expect(data[0]).to respond_to(:id)
        expect(data[0]).to respond_to(:title)
        expect(data[0]).to respond_to(:vote_average)
        expect(data[0]).to respond_to(:poster_path)
      end
    end
  end

  describe ".search_results" do
    it "can hit top rated" do
      search = "Top Rated"
      limit = 1
      expect(MovieFacade).to receive(:top_rated)
      MovieFacade.search_results(search, limit)
    end

    it "can hit trending movies" do
      search = 'Trending Movies'
      limit = 1
      expect(MovieFacade).to receive(:trending)
      MovieFacade.search_results(search, limit)
    end

    it "can hit search" do
      search = 'something else'
      limit = 1
      expect(MovieFacade).to receive(:search).with(search, limit)
      MovieFacade.search_results(search, limit)
    end

    it "wont hit any end points without a serch keyword" do
      search = ''
      limit = 1
      expect(MovieFacade).to_not receive(:top_rated)
      expect(MovieFacade).to_not receive(:trending)
      expect(MovieFacade).to_not receive(:search).with(search, limit)
      MovieFacade.search_results(search, limit)
    end
  end
end
