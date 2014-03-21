# schrodingersbox/meter_cat README

This engine makes monitoring the usage history of your Rails environment easier.

## Getting Started

1. Add this to your `Gemfile` and `bundle install`

		gem 'meter_cat', :git => 'https://github.com/schrodingersbox/meter_cat.git'

2. Add this to your `config/routes.rb`

		mount MeterCat::Engine => '/meter_cat'

3. Install and run migrations

        rake meter_cat:install:migrations
        rake db:migrate

4. Generate some random data

    rake meter_cat:random[my_test,0,100,365]

5. Restart your Rails server

6.  Visit http://yourapp/meter_cat in a browser for an HTML meter report

## How To

### Increment A Meter

The easiest way is to call `MeterCat.add`.

        MeterCat.add( :any_name_you_like )

You can also optionally pass a value and date.

        MeterCat.add( value = 1, created_on = Date.today )

### Set A Meter

The easiest way is to call `MeterCat.set`.

        MeterCat.set( :any_name_you_like )

You can also optionally pass a value and date.

        MeterCat.set( value = 1, created_on = Date.today )

This is useful where you want to record a single value for the day, such as from a daily cron job.

### Generate Development Data

`rake meter_cat:random[name, min, max, days]` can be used to generate random data for development.

The arguments are defined as follows:

 * name = String, Any string up to 64 characters long
 * min = Integer, Minimum generated value
 * max = Integer, Maximum generated value
 * days = Integer, Days prior to date to generate values for

e.g. The following command will generate data for `:my_test` with value between 0 and 100 for the last year.

        rake meter_cat:random[my_test,0,100,365]

### Configure Email Settings

Create or add to `config/initializers/meter_cat.rb`

    MeterCat.configure do |config|
      config.to = 'ops@schrodingersbox.com'
      config.from = 'ops@schrodingersbox.com'
      config.subject = "#{Rails.env.upcase} MeterCat Report"
    end

### Email A Meter Report

You can email a meter report using rake:

    rake meter_cat:mail

You can email a meter report in code:

    MeterCat.mail

### Require authentication

Create or add to `config/initializers/meter_cat.rb`

    MeterCat.configure do |config|
      config.authenticate_with do
        warden.authenticate! scope: :user
      end
    end

### Require authorization

Create or add to `config/initializers/meter_cat.rb`

    MeterCat.configure do |config|
      config.authorize_with do
        redirect_to main_app.root_path unless current_user.try(:admin?)
      end
    end

## Reference

 * [Getting Started with Engines](http://edgeguides.rubyonrails.org/engines.html)
 * [Testing Rails Engines With Rspec](http://whilefalse.net/2012/01/25/testing-rails-engines-rspec/)
 * [How do I write a Rails 3.1 engine controller test in rspec?](http://stackoverflow.com/questions/5200654/how-do-i-write-a-rails-3-1-engine-controller-test-in-rspec)
 * [Best practice for specifying dependencies that cannot be put in gemspec?](https://groups.google.com/forum/?fromgroups=#!topic/ruby-bundler/U7FMRAl3nJE)
 * [Clarifying the Roles of the .gemspec and Gemfile](http://yehudakatz.com/2010/12/16/clarifying-the-roles-of-the-gemspec-and-gemfile/)
 * [The Semi-Isolated Rails Engine](http://bibwild.wordpress.com/2012/05/10/the-semi-isolated-rails-engine/)
 * [FactoryGirl](https://github.com/thoughtbot/factory_girl)

## TODO

 * Action to bump meter and return an image, default to 1px transparent
 * Rake task to bump a meter with args
 * Publish as gem