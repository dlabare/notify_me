require 'logger'

module NotifyMe
  class Logger < Logger

    MEMORY_SIZE_LIMIT = 5242880 # 5 MB

    attr_accessor :memory_log

    def self.new(logdev = Rails.root.join('log', 'notify_me.log'), shift_age = 0, shift_size = 1048576)
      super(logdev, shift_age, shift_size)
    end

    def info(msg)
      log_in_memory(msg)
      super
    end

    def debug(msg)
      log_in_memory(msg)
      super
    end

    private

      def log_in_memory(msg)
        return if @memory_log.to_s.size > MEMORY_SIZE_LIMIT

        puts msg
        (@memory_log ||= '') << msg << "\n"

        if @memory_log.size > MEMORY_SIZE_LIMIT
          @memory_log << "Memory log limit reached, subsequent messages will not be stored, but can be found at: #{RAILS_ROOT}/log/notify_me.log"
        end
      end
      
  end
end

