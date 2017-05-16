ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym
require 'securerandom'
require 'json'
require 'loglines'
require 'instances'
require 'curl'
require 'log_utils'
require 'stress_testers'

$stdout.sync = true
$stderr.sync = true
$counter = 0

ID = ((ENV["VCAP_APPLICATION"] && JSON.parse(ENV["VCAP_APPLICATION"])["instance_id"]) || SecureRandom.uuid).freeze

class Dora < Roda
  # use StressTesters
  # use LogUtils

  route do |r|
    r.root do
      "Hi, I'm Dora!"
    end

    r.get 'health' do
      $stderr.puts("Called /health #{$counter}")
      if $counter < 3
        $counter += 1
        r.response.status = 500
        "Hit /health #{$counter} times"
      else
        "I'm alive"
      end
    end

    r.get 'ping', :address do |address|
      `ping -c 4 #{address}`
    end

    r.get 'lsb_release' do
      `lsb_release --all`
    end

    r.get 'find', :filename do |filename|
      `find / -name #{filename}`
    end

    r.get 'sigterm' do
      "Available sigterms #{`man -k signal | grep list`}"
    end

    r.get 'sigterm', :signal do |signal|
      pid = Process.pid
      puts "Killing process #{pid} with signal #{signal}"
      Process.kill(signal, pid)
    end

    r.get 'dpkg', :package do |package|
      puts "Sending dpkg output for #{package}"
      `dpkg -l #{package}`
    end

    r.get 'delay', :seconds do |seconds|
      sleep seconds.to_i
      "YAWN! Slept so well for #{seconds.to_i} seconds"
    end

    r.get 'logspew', :kbytes do |kbytes|
      kb = "1" * 1024
      kbytes.to_i.times { puts kb }
      "Just wrote #{kbytes} kbytes to the log"
    end

    r.get 'echo', :destination, :output do |destination, output|
      redirect =
        case destination
        when "stdout"
          ""
        when "stderr"
          " 1>&2"
        else
          " > #{destination}"
        end

      system "echo '#{output}'#{redirect}"

      "Printed '#{output}' to #{destination}!"
    end

    r.on 'env' do
      r.is ":name" do |name|
        r.get do
          ENV[name]
        end
      end

      r.get do
        ENV.to_h.to_json
      end
    end

    r.get 'myip' do
      `ip route get 1 | awk '{print $NF;exit}'`
    end

    r.get 'largetext', :kbytes do |kbytes|
      fiveMB = 5 * 1024
      numKB = kbytes.to_i
      ktext="1" * 1024
      text=""
      size = numKB > fiveMB ? fiveMB : numKB
      size.times {text+=ktext}
      text
    end

    r.on 'loglines' do
      r.run Loglines
    end
    r.on 'curl' do
      r.run Curl
    end
    r.on 'log' do
      r.run LogUtils
    end
    r.on 'stress_testers' do
      r.run StressTesters
    end
    r.run Instances
  end
end
