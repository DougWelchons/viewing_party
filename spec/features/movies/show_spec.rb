require 'rails_helper'

RSpec.describe 'Movie Show Page' do
  describe 'can return api movie content' do
    it 'shows a button to create a viewing party and movie info' do
      VCR.use_cassette('all_movie_info') do
        visit("/movies/550")
          expect(page).to have_button("Create Viewing Party for Movie")
          within "#movie_info" do
            expect(page).to have_content("Movie title:Fight Club")
            expect(page).to have_content("Drama")
            expect(page).to have_content("2 hours and 19 minutes")
            expect(page).to have_content("Average_Rating: 8.4")
            expect(page).to have_content('Summary: A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy. Their concept catches on, with underground "fight clubs" forming in every town, until an eccentric gets in the way and ignites an out-of-control spiral toward oblivion.')
        end
      end
    end
  end

  describe "As an unauthenticated user" do
    describe "when I visit a movie's show  page it" do
      it "redirects me to the login page with a flash message" do
        visit "/movies/550"

        expect(current_path).to eq(root_path)
        expect(page).to have_content("You must be logged in to view this page")
      end
    end
  end

  describe "As an authenticated user" do
    before :each do
      @user = User.create!(name: "Name", email: "email@domain.com", password: "password")
      visit root_path
      fill_in :email, with: @user.email
      fill_in :password, with: @user.password
      click_button "Log In"
    end
    describe 'can return api movie content' do
      it 'shows a button to create a viewing party and movie info' do

        json_response = File.read('spec/fixtures/movie_details.json')
        json_cast_response = File.read('spec/fixtures/cast_details.json')
        json_review_response = File.read('spec/fixtures/review_details.json')
        body = JSON.parse(json_response)
        cast_body = JSON.parse(json_cast_response)
        review_body = JSON.parse(json_review_response)
          stub_request(:get, "https://api.themoviedb.org/3/movie/550?api_key=8fcfd8353e4732fe3783cb092cfaf65e&language=en-US").
            to_return(status: 200, body: json_response, headers: {})
            stub_request(:get, "https://api.themoviedb.org/3/movie/550/credits?api_key=8fcfd8353e4732fe3783cb092cfaf65e&language=en-US").
        to_return(status: 200, body: json_cast_response, headers: {})
        stub_request(:get, "https://api.themoviedb.org/3/movie/550/reviews?api_key=8fcfd8353e4732fe3783cb092cfaf65e&language=en-US&page=1").
          to_return(status: 200, body: json_review_response, headers: {})

        visit("/movies/550")
          expect(page).to have_button("Create Viewing Party for Movie")
          within "#movie_info" do
            expect(page).to have_content(body["title"])
            expect(page).to have_content(body["genres"][0]["name"])
            expect(page).to have_content("2 hours and 19 minutes")
            expect(page).to have_content(body["vote_average"])
            expect(page).to have_content(body["overview"])
        end
      end
    end

    it "vcr data reveals movie cast info" do
      VCR.use_cassette('all_movie_info') do
        visit("/movies/550")
          within "#movie_cast" do
          expect(page).to have_content("Edward Norton as The Narrator")
          expect(page).to have_content("Brad Pitt as Tyler Durden")
          expect(page).to have_content("Holt McCallany as The Mechanic")
          expect(page).to have_content("Richmond Arquette as Intern")
        end
      end
    end

    it "shows movie review authors and review" do
    VCR.use_cassette('all_movie_info') do
      visit("/movies/550")
        within "#movie_reviews" do
          expect(page).to have_content("Goddard")
          expect(page).to have_content("Brett Pascoe")
          expect(page).to have_content("msbreviews")
          expect(page).to have_content("r96sk")
          expect(page).to have_content("4 Reviews")
        end
      end
    end
  end
end
