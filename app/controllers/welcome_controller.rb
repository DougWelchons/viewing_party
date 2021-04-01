class WelcomeController < ApplicationController
  skip_before_action :require_login
  def index
    @skip_navbar = true
  end
end
