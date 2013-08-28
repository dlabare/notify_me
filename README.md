# NotifyMe

A simple email notification system so you can ping yourself when certain things
happen in your web application.

## Installation

Add this line to your application's Gemfile:

    gem 'notify_me'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install notify_me

## Usage

Use it as a block to shoot a success/failure email to yourself when the block
executes:

    NotifyMe.after do
      do_something_that_you_wanna_know_whether_it_succeeds_or_fails
    end
    
It will fire off an email after completion so you can rest easy that something
occurred.

## Configuration

You'll can configure some initial settings. You have access to:

    NotifyMe::Config.recipients = ['whoshouldgetit@test.com','orothers@test.com']
    NotifyMe::Config.from = 'MySite@mysite.com'
    
Alternatively, you can override these when calling NotifyMe.after:

    NotifyMe.after(:from => 'someemail@test.com', :recipients => 'me@me.com') do
      do_something
    end
    
Current options:

    options[:recipients]
    options[:from]
    options[:cc]
    options[:subject]
    options[:message]

## Additional hooks

If you want to add an observer to these NotifyMe events, you can do so by adding:

    NotifyMe.observers(Object)
    
So long as the Object in question responds to the methods :notify_me_success and :notify_me_failure

For example, you can have an Audit model:

    class Audit < ActiveRecord::Base
      def self.notify_me_success(opts = {})
        create!(:message => opts[:message], :success => true)
      end

      def self.notify_me_failure(opts = {})
        create!(:message => opts[:message], :success => false)
      end
    end
    
To keep track of the notification events.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Improvements and suggestions appreciated.