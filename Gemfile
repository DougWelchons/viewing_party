source 'https://rubygems.org'

git_source(:github) do |repo_name|
   repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby '2.5.3'

gem 'rails', '5.2.4.3'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'mimemagic', '~> 0.3.6'
gem 'bootstrap', '~> 5.0.0.beta2'
gem 'jquery-rails'
# gem 'mini_racer', '~> 0.1.14'
gem 'bootsnap'
gem 'jbuilder', '~> 2.5'
gem 'bcrypt'
gem 'mimemagic', '~> 0.3.6'
gem "figaro"
gem 'faraday'

group :development, :test do
  gem 'pry'
  gem 'travis'
  gem 'shoulda-matchers'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop-rails'
end

group :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'launchy'
  gem 'simplecov'
  gem "vcr"
  gem 'webmock'
  gem 'orderly'

end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
