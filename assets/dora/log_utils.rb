require "logging_service"

class LogUtils < Roda
  STDOUT.sync = true

  $run = false
  $sequence_number = 0
  $logging_service = ::LoggingService.new

  route do |r|
    r.on 'sleep' do
      r.get 'count' do
        $logging_service.log_message_count
      end

      r.get 'running' do
        $logging_service.running
      end

      r.on :logspeed do |logspeed|
        r.get 'limit', :limit do |limit|
          limit = limit.to_i
          $logging_service.produce_logspeed_output(limit, logspeed, r.host)
        end

        r.get do
          $logging_service.produce_logspeed_output(0, logspeed, r.host)
        end
      end
    end

    r.get 'bytesize', :bytesize do |bytesize|
      $run = true
      logString = "0" * bytesize.to_i
      STDOUT.puts("Muahaha... let's go. No wait. Logging #{bytesize} bytes per logline.")
      while $run do
        STDOUT.puts(logString)
      end
    end

    r.get 'stop' do
      $logging_service.stop
    end
  end

  private

  def produce_log_output(linecount, tag="")
    linecount.to_i.times do |i|
      STDOUT.puts "#{Time.now.strftime("%FT%T.%N%:z")} line #{i} #{tag}"
      $stdout.flush
    end
  end
end
