require 'rails_helper'

RSpec.describe "Dashboard" do
  describe "As an unauthenticated user" do
    describe "when I visit the dashboard page it" do
      it "redirects me to the login page with a flash message" do
        visit dashboard_path

        expect(current_path).to eq(root_path)
        expect(page).to have_content("You must be logged in to view this page")
      end
    end
  end

  describe "As an authenticated user" do
  before :each do
    @user = User.create!(name: "name", email: "email@gmail.com", password: "password")
    visit root_path

      within(".login") do
        fill_in :email, with: @user.email
        fill_in :password, with: @user.password
        click_button("Log In")
      end
  end

  describe "when I visit a user dashboard it" do
    it "has a logout button" do 
      within "#navbar" do
      expect(page).to have_link("logout")
      
      click_link("logout")
      end
      expect(current_path).to eq(root_path) 
    end 

    it "has a welcome header" do
      expect(current_path).to eq(dashboard_path)
      expect(page).to have_content("Welcome #{@user.name}!")
    end

    it "has a button to discover movies" do
      expect(page).to have_button("Discover Movies")

      click_button "Discover Movies"

      expect(current_path).to eq(discover_path)
    end

    it "has a friends section" do
      within "#friends-#{@user.id}" do
        expect(page).to have_content("Friends")
        expect(page).to have_content("You have no one on your friends list yet")
        expect(page).to have_field(:email)
        expect(page).to have_button("Add Friend")
      end
    end

    it "has a viewing party section" do
      within "#viewing_party#{@user.id}" do
        expect(page).to have_content("Hosting:")
        expect(page).to have_content("Invited to:")
      end
    end
  end

  it "you can add friends to the friends section" do
    user2 = User.create!(name: "Jeremiah", email: "jeremiah@gmail.com", password: "password")
    user3 = User.create!(name: "Jeremiahhh", email: "jeremiah2@gmail.com", password: "password")
    user4 = User.create!(name: "Jeremiahh", email: "jeremiah3@gmail.com", password: "password")
    within "#friends-#{@user.id}" do
      fill_in :email, with: user2.email
      click_button("Add Friend")
      expect(current_path).to eq(dashboard_path())
      expect(page).to have_content(user2.name)
    end
  end

  it "holds multiple friends when added" do
    user2 = User.create!(name: "Jeremiah", email: "jeremiah@gmail.com", password: "password")
    user3 = User.create!(name: "Jeremiahhh", email: "jeremiah2@gmail.com", password: "password")
    user4 = User.create!(name: "Jeremiahh", email: "jeremiah3@gmail.com", password: "password")
    friend1 = Friend.create!(user_id:@user.id, friend_id: user2.id)
    within "#friends-#{@user.id}" do
      fill_in :email, with: user3.email
      click_button("Add Friend")
      expect(current_path).to eq(dashboard_path())
      expect(page).to have_content(user2.name)
      expect(page).to have_content(user3.name)
    end
  end

  it "returns a sad path if the email does not exist" do
    user2 = User.create!(name: "Jeremiah", email: "jeremiah@gmail.com", password: "password")
    user3 = User.create!(name: "Jeremiahhh", email: "jeremiah2@gmail.com", password: "password")
    user4 = User.create!(name: "Jeremiahh", email: "jeremiah3@gmail.com", password: "password")
    friend1 = Friend.create!(user_id:@user.id, friend_id: user2.id)
    within "#friends-#{@user.id}" do
        fill_in :email, with: 'Dominic@gmail.com'
        click_button("Add Friend")
        expect(current_path).to eq(dashboard_path())
    end
    expect(page).to have_content("That User Does Not Exist")
  end

  it "has both the hosted and invited viewing parties" do
    @friend1 = User.create(name: "Berry", email: "berry@gmail.com", password: 'password1')
    @friend2 = User.create(name: "John", email: "john@gmail.com", password: 'password1')
    @friendship = Friend.create(user_id: @user.id, friend_id: @friend1.id)
    @friendship2 = Friend.create(user_id: @user.id, friend_id: @friend2.id)
    @movie1 = Movie.create(name: 'The Godfather', duration: 175)
    @movie2 = Movie.create(name: 'The Shawshank Redemption', duration: 142)
    @party1 = Party.create!(movie_id: @movie1.id, duration: @movie1.duration, date: "2021/03/29", start_time: "6:00 PM", host_id: @user.id)
    @party2 = Party.create!(movie_id: @movie2.id, duration: @movie1.duration, date: "2021/03/29", start_time: "6:00 PM", host_id: @friend1.id)
    @party_friend1 = PartyFriend.create(party_id: @party1.id, user_id: @friend1.id)
    @party_friend1 = PartyFriend.create(party_id: @party1.id, user_id: @friend2.id)
    @party_friend1 = PartyFriend.create(party_id: @party2.id, user_id: @user.id)
    @party_friend1 = PartyFriend.create(party_id: @party2.id, user_id: @friend2.id)
    visit dashboard_path
    expect(page).to have_content("The Godfather")
    expect(page).to have_content(175)
    expect(page).to have_content("6:00PM")
    expect(page).to have_content("The Godfather")
    end
  end
end
