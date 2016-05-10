require 'sinatra'
require 'json'
require 'httparty'
require './api_ai'
 
#Bound to this address so that external hosts can access it, VERY IMPORTANT!
set :bind, '0.0.0.0'
 
set :logging, true

URL = "https://graph.facebook.com/v2.6/me/messages?access_token=#{ENV["PAGE_ACCESS_TOKEN"]}"

post '/page_webhook' do
  body = request.body.read
  payload = JSON.parse(body)
  
  # get the sender of the message
  sender = payload["entry"].first["messaging"].first["sender"]["id"]
  
  # get the message text
  message = payload["entry"].first["messaging"].first["message"]
  message = message["text"] unless message.nil?
    
  # ask Api.ai NLP api if it isn't a confirmation message from Facebook messenger API
  unless message.nil?
    
    if message == "flowers"
      response = ApiAi.get_price("buque")
    else
      response = ApiAi.chat(message)
    end
    
    puts "URL token: #{URL}"
        
    # post message to facebook messenger API
    @result = HTTParty.post(URL, 
        :body => { :recipient => { :id => sender}, 
                   :message => response
                 }.to_json,
        :headers => { 'Content-Type' => 'application/json' } )
        
        puts @result
  end
  
end

get '/page_webhook' do
  params['hub.challenge'] if ENV["VERIFY_TOKEN"] == params['hub.verify_token']
end

get '/fb_template' do
  content_type :json
  ApiAi.get_price(params['product']).to_json
end
 
get '/' do
  html = <<-HTML
<html>
<body>
Hello robots OverLords!<br/>
<br/>
Available endpoints:<br/>
<br/>
POST /page_webhook<br/>
GET  /page_webhook<br/>
GET  <a href="/fb_template?product=flowers">/fb_template?product=flowers</a>
</body>
</html>
HTML

  html
end
