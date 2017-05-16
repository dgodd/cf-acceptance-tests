require 'roda'

class Instances < Roda
  route do |r|
    r.get 'id' do
      ID
    end

    r.post 'session' do
      response.set_cookie 'JSESSIONID', ID
      "Please read the README.md for help on how to use sticky sessions."
    end
  end
end
