require 'rails_helper'

RSpec.describe "Discover index page" do
  describe "As an unauthenticated user" do
    describe "when I visit the discover index page it" do
      it "redirects me to the login page with a flash message" do
        visit discover_path

        expect(current_path).to eq(root_path)
        expect(page).to have_content("You must be logged in to view this page")
      end
    end
  end

  describe "as an authenticated user" do
    before :each do
      @user = User.create!(name: "Name", email: "email@domain.com", password: "password")
      visit root_path
      fill_in :email, with: @user.email
      fill_in :password, with: @user.password
      click_button "Log In"
    end

    describe "when I visit the discover index page it" do
      it "shows a link to find the top rated movies" do
        visit discover_path

        expect(page).to have_button('Find Top Rated Movies')
      end

      it "redirects to the movies page and shows the top rated movies" do
        VCR.use_cassette('top_40_movies') do
          visit discover_path

          click_button("Find Top Rated Movies")

          expect(current_path).to eq(movies_path)

          expect(page).to have_content("Gabriel's Inferno Part III")
          expect(page).to have_content("Gabriel's Inferno Part II")
        end
      end

      it "shows a field to search for movies" do
        visit discover_path

        expect(page).to have_field(:search)
        expect(page).to have_button("Search")
      end

      it "redirects to the movies page and shows my searech results" do
        VCR.use_cassette('search_movies_fight_club') do
          visit movies_path

          fill_in :search, with: "fight club"
          click_button "Search"

          expect(current_path).to eq(movies_path)
          save_and_open_page
          expect(page).to have_link("Fight Club")
          expect(page).to have_link("Insane Fight Club")
          expect(page).to have_link("Insane Fight Club II - This Time It’s Personal")
        end
      end
    end

    it "shows a link to find the trending movies" do
      visit discover_path

      expect(page).to have_button('Top 10 Trending Movies This Week')
    end

    it "redirects to the movies page and shows the top rated movies" do
      VCR.use_cassette('trending_movies') do
        visit discover_path

        click_button("Top 10 Trending Movies This Week")

        expect(current_path).to eq(movies_path)

        expect(page).to have_content("Zack Snyder's Justice League")
        expect(page).to have_content("Godzilla vs. Kong")
      end
    end
  end
end
