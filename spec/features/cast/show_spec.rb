require 'rails_helper'

RSpec.describe "Cast Show Page" do
  describe "as an authinticated user" do
    before :each do
      @user = User.create!(name: "Name", email: "email@domain.com", password: "password")
      visit root_path
      fill_in :email, with: @user.email
      fill_in :password, with: @user.password
      click_button "Log In"
    end

    describe "when I visit a movie show page" do
      it "next to each actor, it shows a button 'Other Movies'" do
        VCR.use_cassette('movie_show_page') do
          visit movie_path(550)

          within("#movie_cast") do
            expect(page).to have_button('Other movies with Brad Pitt')
          end
        end
      end
      it "next to each actor, it shows a button 'Other Movies'" do
        VCR.use_cassette('cast_redirect') do
          visit movie_path(550)

          within("#movie_cast") do
            click_button 'Other movies with Brad Pitt'
          end

          expect(current_path).to eq(cast_path(287))
        end
      end
    end

    describe "when I visit the cast show page" do
      it "shows that persons name" do
        VCR.use_cassette('brad_pit') do
          visit cast_path(287)

          expect(page).to have_content("Movies that Brad Pitt has stared in:")
        end
      end

      it "shows that persons biography" do
        VCR.use_cassette('brad_pitt') do
          visit cast_path(287)

          expect(page).to have_content("Biograph: William Bradley Pitt is an American actor and film producer.")
        end
      end

      it "shows movies that personm has been in" do
        VCR.use_cassette('brad_pitt') do
          visit cast_path(287)

          expect(page).to have_content("Meet Joe Black")
          expect(page).to have_content("Fury")
          expect(page).to have_content("World War Z")
        end
      end

      it "renders an error if the api calls are unsussessfull" do
        api_key = ENV['movie_api_key']
        stub_request(:get, "https://api.themoviedb.org/3/person/287/movie_credits?api_key=#{api_key}&language=en-US").
        to_return(status: 500, body: "", headers: {})
        stub_request(:get, "https://api.themoviedb.org/3/person/287?api_key=#{api_key}&language=en-US").
        to_return(status: 500, body: "", headers: {})
        visit cast_path(287)

        expect(page).to have_content("Sorry, there was a server error while processing your request!")
      end
    end
  end

  describe "As an unauthenticated user" do
    describe "when I visit the Cast show page" do
      it "redirects me to the login page with a flash message" do
        visit movies_path

        expect(current_path).to eq(root_path)
        expect(page).to have_content("You must be logged in to view this page")
      end
    end
  end
end
