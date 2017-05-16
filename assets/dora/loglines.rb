require 'roda'

class Loglines < Roda
  STDOUT.sync = true
  route do |r|
    r.is :linecout do |linecount|
      produce_log_output(params[:linecount])
      "logged #{params[:linecount]} line to stdout"
    end

    r.is :linecout, :tag do |linecount, tag|
      produce_log_output(linecount, tag)
      "logged #{linecount} line with tag #{tag} to stdout"
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
