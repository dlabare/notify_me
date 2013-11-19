require 'notify_me/version'
require 'notify_me/config'
require 'notify_me/logger'
require 'notify_me/mailer'

module NotifyMe

  class ObserverError < StandardError; end
  
  @@observers = []
  
  def self.after(options = {}, &block)
    options[:recipients]      ||= Config.recipients
    options[:from]            ||= Config.from
    options[:subject]         ||= Config.default_subject
    options[:message]         ||= Config.default_message
    options[:logger]            = Logger.new # note that this is a NotifyMe::Logger instance
    options[:logger].formatter  = proc do |severity, datetime, progname, msg|
      "#{datetime.utc.strftime("%Y-%m-%d %H:%M:%S")}#{datetime.utc.formatted_offset}: #{msg}\n"
    end
    options[:time]            = Benchmark.realtime { yield options[:logger]}
    Mailer.send_email(:notify_me_success, options)
    notify_observers(:success, options)
  rescue Exception => e
    options[:error_message]   = e.message
    options[:error_backtrace] = e.backtrace.join("\n")
    Mailer.send_email(:notify_me_failure, options)
    notify_observers(:failure, options)
    raise e # re-raise the error
  end
  
  def self.add_observer(object)
    @@observers ||= []
    if object.respond_to?(:notify_me_success) && object.respond_to?(:notify_me_failure)
      @@observers << object
    else
      raise ObserverError.new("Could not add observer: #{object.inspect}. Class does not respond to :notify_me_success and :notify_me_failure")
    end
  end
  
  def self.observers
    @@observers
  end
  
  def self.clear_observers
    @@observers = []
  end
  
  def self.notify_observers(action, options)
    @@observers.each do |object|
      begin
        object.send("notify_me_#{action}", options)
      rescue NoMethodError
        Rails.logger.warn "NotifyMe Observer #{object.inspect} did not respond to 'notify_me_#{action.to_s}'"
      rescue Exception
        # we don't want any errors from the observers to bubble up to our NotifyMe.after method
      end
    end unless @@observers.blank?

    return nil
  end

end
