require 'action_mailer'

module NotifyMe
  class Mailer < ActionMailer::Base

    class RecipientsError < StandardError; end

    #
    # If you're using Delayed::Job to send email, do it that way
    #
    def self.send_email(method, options)
      raise RecipientsError.new("You forgot to tell me who to notify! You can set NotifyMe::Config.recipients in an initializer, or pass in a :recipients => [] option to your NotifyMe.after() call") if options[:recipients].blank?

      if respond_to?(:delay)
        Mailer.delay.send(method, options)
      else
        Mailer.send(method, options).deliver
      end
    end

    def notify_me_success(options = {})
      @message = options[:message] 
      @time    = options[:time]

      if options[:logger]
        @memory_log = options[:logger].memory_log
      end

      mail(
        :to       => options[:recipients],
        :cc       => options[:cc],
        :from     => options[:from],
        :subject  => "#{Config.subject_leader}#{options[:subject]}"
      ) do |format|
        format.text { render(file: "#{File.dirname(__FILE__)}/emails/success.text.erb") }
        format.html { render(file: "#{File.dirname(__FILE__)}/emails/success.html.erb") }
      end
    end

    def notify_me_failure(options = {})
      @error_message   = options[:error_message]
      @error_backtrace = options[:error_backtrace]

      mail(
        :to       => options[:recipients],
        :cc       => options[:cc],
        :from     => options[:from],
        :subject  => "#{Config.subject_leader}FAILURE - #{options[:subject]}",
      ) do |format|
        format.text { render(file: "#{File.dirname(__FILE__)}/emails/failure.text.erb") }
        format.html { render(file: "#{File.dirname(__FILE__)}/emails/failure.html.erb") }
      end
    end

  end
end
