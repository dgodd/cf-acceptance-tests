require 'roda'
require 'open3'

class Curl < Roda
  route do |r|
    r.get :host, [:port, true] do |host, port|
      port ||= '80'
      curl(host, port)
    end
  end

  private

  def curl(host, port)
    stdout, stderr, status = Open3.capture3("curl -m 3 -v -i #{host}:#{port}")
    { stdout: stdout, stderr: stderr, return_code: status.exitstatus }.to_json
  end
end
