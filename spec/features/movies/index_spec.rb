require 'rails_helper'

RSpec.describe "Movies index page" do
  describe "As an unauthenticated user" do
    describe "when I visit the movies index page it" do
      it "redirects me to the login page with a flash message" do
        visit discover_path

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

    describe "When I visit the movies page it" do
      it "shows the 'Find Top Rated Movies' button at the top of the page" do
        visit movies_path

        expect(page).to have_button('Find Top Rated Movies')
      end

      it "returns the top 40 movies when 'Find Top Rated Movies' is clicked" do
        VCR.use_cassette('top_40_movies') do
          visit movies_path

          click_button("Find Top Rated Movies")

          expect(current_path).to eq(movies_path)

          expect(page).to have_content("Gabriel's Inferno Part III")
          expect(page).to have_content("Gabriel's Inferno Part II")
        end
      end

      it "shows each movie title as a link to its show page" do
        VCR.use_cassette('top_40_movies') do
          visit movies_path

          click_button("Find Top Rated Movies")

          expect(page).to have_link("Gabriel's Inferno Part III")
          expect(page).to have_link("Gabriel's Inferno Part II")
        end
      end

      it "shows a search field to search movies" do
        visit movies_path

        expect(page).to have_field(:search)
        expect(page).to have_button("Search")
      end

      it "lists the first 40 results that match the search keywords" do
        VCR.use_cassette('search_for_movies') do
          visit movies_path

          fill_in :search, with: "the"
          click_button "Search"

          expect(current_path).to eq(movies_path)

          expect(page).to have_content("We found 40 results")
        end
      end

      it "returns all of the results if there are less then 40" do
        VCR.use_cassette('search_for_movies_short') do
          visit movies_path

          fill_in :search, with: "finding nemo"
          click_button "Search"

          expect(current_path).to eq(movies_path)

          expect(page).to have_content("We found 3 results")
        end
      end
    end
  end

  describe "sad path and error" do
    before :each do
      @user = User.create!(name: "Name", email: "email@domain.com", password: "password")
      visit root_path
      fill_in :email, with: @user.email
      fill_in :password, with: @user.password
      click_button "Log In"
    end

    it "500 error" do
      api_key = ENV['movie_api_key']
      stub_request(:get, "https://api.themoviedb.org/3/movie/top_rated?api_key=#{api_key}&language=en-US&page=1").
        to_return(status: 500, body: "", headers: {})

      visit movies_path

      click_button("Find Top Rated Movies")
      expect(current_path).to eq(movies_path)

      expect(page).to have_content("Sorry, there was a server error while processing your request!")
    end
  end

  describe "As an unauthenticated user" do
    describe "when i visit the movies index page" do
      it "redirects me to the login page with a flash message" do
        visit movies_path

        expect(current_path).to eq(root_path)
        expect(page).to have_content("You must be logged in to view this page")
      end
    end
  end
end
