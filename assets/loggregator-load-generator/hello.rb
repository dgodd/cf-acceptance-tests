require 'roda'
STDOUT.sync = true

class Hello < Roda
  $run = false

  route do |r|

    r.root do
      <<-RESPONSE
  Endpoints:<br><br>
  <ul>
  <li>/log/sleep/:logspeed - set the pause between loglines to a millionth fraction of a second</li>
  <li>/log/bytesize/:bytesize - set the size of each logline in bytes</li>
  <li>/log/stop - stops any running logging</li>
  </ul>
      RESPONSE
    end

    r.on 'log' do
      r.get 'sleep', :logspeed do |logspeed|
        if $run
          "Already running.  Use /log/stop and then restart."
        else
          $run       = true
          sleep_time = logspeed.to_f/1000000.to_f

          STDOUT.puts("Muahaha... let's go. Waiting #{sleep_time} seconds between loglines. Logging 'Muahaha...' every time.")
          Thread.new do
            while $run do
              sleep(sleep_time)
              STDOUT.puts("Log: #{request.host} Muahaha...")
            end
          end

          "Muahaha... let's go. Waiting #{logspeed.to_f/1000000.to_f} seconds between loglines. Logging 'Muahaha...' every time."
        end
      end

      r.get 'bytesize', :bytesize do |bytesize|
        $run = true
        logString = "0" * bytesize.to_i
        STDOUT.puts("Muahaha... let's go. No wait. Logging #{bytesize} bytes per logline.")
        while $run do
          STDOUT.puts(logString)
        end
        ''
      end

      r.get 'stop' do
        $run = false
        time = Time.now
        STDOUT.puts("Sopped logs #{time}")
        ''
      end
    end
  end
end
