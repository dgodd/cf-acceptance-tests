require 'roda'
STDOUT.sync = true
STDERR.sync = true

class Main < Roda
  route do |r|
    r.root do
      <<-RESPONSE
Healthy
It just needed to be restarted!
My application metadata: #{ENV['VCAP_APPLICATION']}
My port: #{ENV['PORT']}
My custom env variable: #{ENV['CUSTOM_VAR']}
      RESPONSE
    end

    r.get 'log', :message do |message|
      STDOUT.puts(message)
      "logged #{message} to STDOUT"
    end
  end
end

Thread.new do
  while true do
    STDOUT.puts "Tick: #{Time.now.to_i}"
    sleep 1
  end
end
