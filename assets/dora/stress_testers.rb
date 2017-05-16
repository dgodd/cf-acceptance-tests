require 'roda'
require 'open3'

class StressTesters < Roda
  ACCEPTED_OPTIONS = %w[timeout cpu io vm vm-bytes vm-stride vm-hang vm-keep hdd hdd-bytes].freeze

  plugin :all_verbs

  route do |r|
    r.get do
      run(r, 'pgrep stress | xargs -r ps -H')
    end

    r.post do
      command = ["./stress"]

      ACCEPTED_OPTIONS.each do |option|
        command << "--#{option} #{r[option]}" if r[option]
      end

      pid = Process.spawn(command.join(" "), in: "/dev/null", out: "/dev/null", err: "/dev/null")
      Process.detach(pid)

      r.response.status = 201
    end

    r.delete do
      run(r, 'pkill stress')
    end
  end

  private

  def run(r, command)
    output = []
    exit_status = 0

    Open3.popen2e(command) do |_, stdout_and_stderr, wait_thr|
      output += stdout_and_stderr.readlines
      exit_status = wait_thr.value
    end

    r.response.status = (exit_status == 0 ? 200 : 500)
    output.join
  end
end
