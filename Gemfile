source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

gem 'bcrypt'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'devise'
gem 'http'
gem 'jbuilder', '~> 2.7'
gem "puma", ">= 3.12.3"
gem "nokogiri", ">= 1.10.8"
gem 'rails', '~> 6.0.0'
gem 'sprockets', '< 4'
gem 'sassc-rails'
gem 'webpacker', '~> 4.0'
gem 'faker'
gem 'bootstrap', '~> 4.5'
gem 'jquery-rails'
gem 'execjs'
gem 'mini_racer'
gem 'sendgrid'
gem "mailgun-ruby"
gem 'carrierwave', '~> 2.1'
gem "cloudinary"
gem 'simple_form', '~> 5.0', '>= 5.0.2'
gem 'finishing_moves'
gem 'sortable-rails'
gem 'bootstrap-editable-rails'
gem 'closure_tree'
gem 'searchkick'
gem 'bonsai-elasticsearch-rails', '~> 7'
gem 'elasticsearch-model', github: 'elastic/elasticsearch-rails', branch: 'master'
gem 'elasticsearch-rails', github: 'elastic/elasticsearch-rails', branch: 'master'
gem 'rest-client'
gem 'font-awesome-sass', '~> 5.13.0'
gem 'order_as_specified'


group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring'
  gem 'web-console', '>= 3.3.0'
end

group :development, :test do
  gem 'amazing_print'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  gem 'grade_runner', github: 'firstdraft/grade_runner'
  gem 'pry-rails'
  gem 'sqlite3', '~> 1.4.1'
  gem 'table_print'
  gem 'web_git', github: 'firstdraft/web_git'
end

group :development do
  gem 'annotate', '< 3.0.0'
  gem 'better_errors', '2.6'
  gem 'binding_of_caller'
  gem 'draft_generators', github: 'firstdraft/draft_generators', branch: 'winter-2020'
  gem 'letter_opener'
  gem 'meta_request'
  gem 'rails_db', '2.3.1'
end

group :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'rspec-html-matchers'
  gem 'rspec-rails'
  gem 'webmock'
end

group :production do
  gem 'pg'
end
