source "http://rubygems.org"

gem "bio", ">= 1.4.2"

if defined?(JRUBY_VERSION)
    gem "msgpack-jruby", ">= 1.2.0"
else
    gem "msgpack", ">= 0.4.7"
end

group :development do
  gem "rake"
  gem "bundler", "~> 1.1.4"
  gem "jeweler", "~> 1.8.3"
  gem "rspec", "~> 2.7.0"
  gem "cucumber", ">= 0"
end
