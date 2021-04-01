require 'rails_helper'

RSpec.describe "Movie Service" do
  describe ".top_movies" do
    it "returns the first 40 top rated movies in an array" do
      VCR.use_cassette('top_50_movies') do
        limit = 50
        expect(MovieService.top_rated(limit)).to be_an(Array)
        expect(MovieService.top_rated(limit)[0]).to be_an(OpenStruct)
        expect(MovieService.top_rated(limit).length).to eq(limit)
      end
    end

    it "returnes an error if the request is not completed" do
      api_key = ENV['movie_api_key']
      stub_request(:get, "https://api.themoviedb.org/3/movie/top_rated?api_key=#{api_key}&language=en-US&page=1").
        to_return(status: 500, body: "", headers: {})

      limit = 40
      data = MovieService.top_rated(limit)

      expect(data).to eq({error: true})
    end
  end

  describe ".create_objects" do
    describe "happy path" do
      before :each do
      @limit = 2
      @info = [{:id=>19404,
                :poster_path=>"/2CAL2433ZeIihfX1Hb2139CX0pW.jpg",
                :title=>"Dilwale Dulhania Le Jayenge",
                :video=>false,
                :vote_average=>8.7,
                :vote_count=>2748},
               {:id=>724089,
                :poster_path=>"/pci1ArYW7oJ2eyTo2NMYEKHHiCP.jpg",
                :title=>"Gabriel's Inferno Part II",
                :video=>false,
                :vote_average=>8.7,
                :vote_count=>1219},
               {:id=>278,
                :poster_path=>"/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg",
                :release_date=>"1994-09-23",
                :title=>"The Shawshank Redemption",
                :video=>false,
                :vote_average=>8.7,
                :vote_count=>18615}]
          end
      it "creates an array of OpenStruct oblects" do
        expect(MovieService.create_objects(@info, @limit)).to be_an(Array)
        expect(MovieService.create_objects(@info, @limit).length).to eq(2)
        expect(MovieService.create_objects(@info, @limit)[0]).to be_an(OpenStruct)
      end

      it "each OpenStruct oblect has only the relevent info" do
        data = MovieService.create_objects(@info, @limit)[0]

        expect(data).to be_an(OpenStruct)
        expect(data).to respond_to(:id)
        expect(data).to respond_to(:title)
        expect(data).to respond_to(:vote_average)
        expect(data).to respond_to(:poster_path)
        expect(data).to_not respond_to(:vote_count)
        expect(data).to_not respond_to(:video)
        expect(data).to_not respond_to(:release_date)
      end
    end

    describe "sad path" do
      it "does not error if info missing" do
        limit = 2
        info = [{}, {}, {}]

        data = MovieService.create_objects(info, limit)[0]

        expect(data).to be_an(OpenStruct)
        expect(data).to respond_to(:id)
        expect(data).to respond_to(:title)
        expect(data).to respond_to(:vote_average)
        expect(data).to respond_to(:poster_path)
        expect(data).to_not respond_to(:vote_count)
        expect(data).to_not respond_to(:video)
        expect(data).to_not respond_to(:release_date)
      end
    end
  end

  describe ".search" do
    it "returns an array of movie objects equal to limit" do
      VCR.use_cassette('search_for_movies_limit_50') do
        limit = 50
        keywords = 'the'
        expect(MovieService.search(keywords, limit)).to be_an(Array)
        expect(MovieService.search(keywords, limit).length).to be <= limit
      end
    end

    it "returns an array of all movie objects if less then the limit" do
      VCR.use_cassette('search_for_movies_short') do
        limit = 40
        keywords = 'finding nemo'
        expect(MovieService.search(keywords, limit).length).to be <= limit
      end
    end

    it "returnds an OpenStruct object with appropriate values" do
      VCR.use_cassette('search_for_movies') do
        limit = 40
        keywords = 'the'
        data = MovieService.search(keywords, limit)
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
      data = MovieService.search(keywords, limit)

      expect(data).to eq({error: true})
    end
  end

  describe ".trending" do
    it "returns the first 10 trending movies in an array" do
      VCR.use_cassette('trending_movies_limit_10') do
        limit = 10
        expect(MovieService.trending(limit)).to be_an(Array)
        expect(MovieService.trending(limit)[0]).to be_an(OpenStruct)
        expect(MovieService.trending(limit).length).to eq(limit)
      end
    end

    it "returnes an error if the request is not completed" do
      api_key = ENV['movie_api_key']
      stub_request(:get, "https://api.themoviedb.org/3/trending/movie/week?api_key=#{api_key}&page=1").
        to_return(status: 500, body: "", headers: {})

      limit = 10
      data = MovieService.trending(limit)

      expect(data).to eq({error: true})
    end
  end

  describe ".movie_info" do
    it "returnds an OpenStruct object with appropriate values" do
      VCR.use_cassette('all_movie_info') do
        movie_id = 550
        data = MovieService.movie_info(movie_id)
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

  describe ".make_api_call" do
    it "returns info a error if an api call has any status but 200" do
      api_key = ENV['movie_api_key']
      stub_request(:get, "https://bad_url.com/?api_key=#{api_key}").
        to_return(status: 500, body: "", headers: {})

        url = "https://bad_url.com"

      expect(MovieService.make_api_call(url)).to eq({error: true})
    end
  end

  describe ".cast_info" do
    it "returns a array of hashes with all of the relevent cast info" do
      info = {cast: [{ :id=>819,
                :name=>"Edward Norton",
                :popularity=>8.85,
                :profile_path=>"/5XBzD5WuTyVQZeS4VI25z2moMeY.jpg",
                :cast_id=>4,
                :character=>"The Narrator"},
               {:id=>287,
                :name=>"Brad Pitt",
                :popularity=>17.097,
                :profile_path=>"/oTB9vGIBacH5aQNS0pUM74QSWuf.jpg",
                :cast_id=>5,
                :character=>"Tyler Durden"},
               {:id=>1283,
                :name=>"Helena Bonham Carter",
                :popularity=>12.526,
                :profile_path=>"/DDeITcCpnBd0CkAIRPhggy9bt5.jpg",
                :cast_id=>6,
                :character=>"Marla Singer"}],
              not_cast: "not actor"}


      expect(MovieService.cast_info(info)).to be_an(Array)
      expect(MovieService.cast_info(info)[0]).to be_an(Hash)
      expect(MovieService.cast_info(info)[0]).to have_key(:name)
      expect(MovieService.cast_info(info)[0]).to have_key(:character)
      expect(MovieService.cast_info(info)[0]).to have_key(:id)
      expect(MovieService.cast_info(info)[0]).to_not have_key(:popularity)
      expect(MovieService.cast_info(info)[0]).to_not have_key(:profile_path)
    end

    it "returns a array of hashes with all of the relevent cast info, ignoring missing info" do
      info = {cast: [{}],
              not_cast: "not actor"}


      expect(MovieService.cast_info(info)).to be_an(Array)
      expect(MovieService.cast_info(info)[0]).to be_an(Hash)
      expect(MovieService.cast_info(info)[0]).to have_key(:name)
      expect(MovieService.cast_info(info)[0]).to have_key(:character)
      expect(MovieService.cast_info(info)[0]).to have_key(:id)
      expect(MovieService.cast_info(info)[0]).to_not have_key(:popularity)
      expect(MovieService.cast_info(info)[0]).to_not have_key(:profile_path)
    end
  end

  describe ".review_info" do
    it "returns a array of hashes with all of the relevent review info" do
      info = { :id=>550,
               :results=>
                [{:author=>"Goddard",
                  :content=>
                   "review",
                  :created_at=>"2018-06-09T17:51:53.359Z"},
                 {:author=>"Brett Pascoe",
                  :content=>"review",
                  :created_at=>"2018-07-05T13:22:41.754Z"},
                 {:author=>"msbreviews",
                  :content=>
                   "My review where i'm full of myself!",
                  :created_at=>"2020-11-22T17:13:46.301Z"},
                 {:author=>"r96sk",
                  :content=>
                   "My review",
                  :created_at=>"2021-01-13T03:23:09.309Z"}]}

      expect(MovieService.review_info(info)).to be_an(Array)
      expect(MovieService.review_info(info)[0]).to be_an(Hash)
      expect(MovieService.review_info(info)[0]).to have_key(:author)
      expect(MovieService.review_info(info)[0]).to have_key(:content)
      expect(MovieService.review_info(info)[0]).to_not have_key(:created_at)
    end

    it "returns a array of hashes with all of the relevent review info, ignoring missing info" do
      info = { id: 550, results: [{}]}

      expect(MovieService.review_info(info)).to be_an(Array)
      expect(MovieService.review_info(info)[0]).to be_an(Hash)
      expect(MovieService.review_info(info)[0]).to have_key(:author)
      expect(MovieService.review_info(info)[0]).to have_key(:content)
      expect(MovieService.review_info(info)[0]).to_not have_key(:created_at)
    end
  end

  describe ".movies_by_cast_id" do
    it "returns an array of movie objects equal to limit" do
      VCR.use_cassette('brad_pit_movies') do
        limit = 10
        id = 287
        expect(MovieService.movies_by_cast_id(id, limit)).to be_an(Array)
        expect(MovieService.movies_by_cast_id(id, limit).length).to be <= limit
      end
    end

    it "returns an array of all movie objects if less then the limit" do
      VCR.use_cassette('brad_pit_movies_limit_500') do
        limit = 500000
        id = 287
        expect(MovieService.movies_by_cast_id(id, limit).length).to be < limit
      end
    end

    it "returnds an OpenStruct object with appropriate values" do
      VCR.use_cassette('brad_pit_movies') do
        limit = 10
        id = 287
        data = MovieService.movies_by_cast_id(id, limit)
        expect(data[0]).to be_an(OpenStruct)
        expect(data[0]).to respond_to(:id)
        expect(data[0]).to respond_to(:title)
        expect(data[0]).to respond_to(:vote_average)
        expect(data[0]).to respond_to(:poster_path)
      end
    end

    it "returnes an error if the request is not completed" do
      api_key = ENV['movie_api_key']
      stub_request(:get, "https://api.themoviedb.org/3/person/287/movie_credits?api_key=#{api_key}&language=en-US").
        to_return(status: 500, body: "", headers: {})
        limit = 10
        id = 287
      data = MovieService.movies_by_cast_id(id, limit)

      expect(data).to eq({error: true})
    end
  end

  describe ".person_info" do
    it "returnds an OpenStruct object with appropriate values" do
      VCR.use_cassette('person_info') do
        id = 287
        data = MovieService.person_info(id)
        expect(data).to be_an(OpenStruct)
        expect(data).to respond_to(:id)
        expect(data).to respond_to(:name)
        expect(data).to respond_to(:biography)
        expect(data).to respond_to(:profile_path)
      end
    end

    it "returnes an error if the request is not completed" do
      api_key = ENV['movie_api_key']
      stub_request(:get, "https://api.themoviedb.org/3/person/287?api_key=#{api_key}&language=en-US").
      to_return(status: 500, body: "", headers: {})
      id = 287
      data = MovieService.person_info(id)

      expect(data).to eq({error: true})
    end
  end

  describe ".get_needed_info" do
    it "returns an array of movie objects equal to limit" do
      VCR.use_cassette('get_needed_info_limit_50') do
        limit = 50
        uri = "movie/top_rated?language=en-US"
        expect(MovieService.get_needed_info(uri, limit)).to be_an(Array)
        expect(MovieService.get_needed_info(uri, limit).length).to be <= limit
      end
    end

    it "returns an array of all movie objects if less then the limit" do
      VCR.use_cassette('get_needed_info_short') do
        limit = 40
        uri = "search/movie?language=en-US&query=finding%20nemo&include_adult=false"
        expect(MovieService.get_needed_info(uri, limit).length).to be <= limit
      end
    end

    it "returnds an OpenStruct object with appropriate values" do
      VCR.use_cassette('get_needed_info_40') do
        limit = 40
        uri = "movie/top_rated?language=en-US"
        data = MovieService.get_needed_info(uri, limit)
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
      uri = "movie/top_rated?language=en-US"
      limit = 40
      data = MovieService.get_needed_info(uri, limit)

      expect(data).to eq({error: true})
    end
  end
end
