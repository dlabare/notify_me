module NotifyMe
  class Config
    
    @@recipients = @@from = @@env = nil
    
    def self.recipients=(r)
      @@recipients = r
    end
    
    def self.recipients
      @@recipients || []
    end
    
    def self.from=(f)
      @@from = f
    end
    
    def self.from
      @@from || default_from
    end
    
    def self.env=(e)
      @@env = e
    end
    
    def self.env
      @@env || ENV['RACK_ENV'] || ENV['RAILS_ENV']
    end
    
    def self.default_from
      'Your Mom<yourmom@yourmom.com>'
    end
    
    def self.subject_leader
      if self.env
        "[NotifyMe-#{self.env}] "
      else
        '[NotifyMe] '
      end
    end
    
    def self.default_subject
      'NotifyMe Event'
    end
    
    def self.default_message
      'Event Complete'
    end
    
  end
end