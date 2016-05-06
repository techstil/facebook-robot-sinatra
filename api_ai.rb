require 'api-ai-ruby'
require 'json'

module ApiAi
  # init API.ai
  @ai_client = ApiAiRuby::Client.new(
    :client_access_token => ENV["APIAI_ACCESS_TOKEN"],
    :subscription_key => ENV["APIAI_SUBSCRIPTION_KEY"]
  )
  
  def self.chat(message)
    response = @ai_client.text_request(message)
    
    require "pp"
    pp response
        
    # processing action intents at api.ai
    action = self.process_action(response)
    return action unless action.nil?
    
    # get the answers to phrases not related to pre-trained action    
    if response[:result][:speech] == ""
      if response[:result][:metadata][:html].nil?
        {:text => "Não tenho resposta para isso. Poderia reformular sua frase?"}
      end
    else
        {:text => response[:result][:speech]}
    end
  end
  
  def self.process_action(response)
    if response[:result][:action] == "get_price"
      product_name = response[:result][:parameters][:product]
      self.get_price(product_name)
    else
      nil
    end
  end
  
  def self.get_price(product)
        
    # build hash response containing 3 products
      products_elements << {
                              :title => "Ruusuinen Unelma", 
                              :subtitle => "35€", 
                              :buttons => [{:type => "web_url", :url => "https://www.interflora.fi/product/4/007_Ruusuinen_unelma/", :title => "Kauppa"}],
                              :image_url => val["https://www.interflora.fi/assets/r/w/306/h/306/f/products/2014/11/17/11/06/38/007-ruusuinen-unelma-1200-jpg"]
                             }


      products_elements << {
                              :title => "Päivänsäde + Suklaasydän", 
                              :subtitle => "44€", 
                              :buttons => [{:type => "web_url", :url => "https://www.interflora.fi/product/451/P__iv__ns__de___Suklaasyd__n/", :title => "Kauppa"}],
                              :image_url => val["https://www.interflora.fi/assets/r/w/306/h/306/f/products/2016/03/03/01/03/40/interflora5300pieni-jpg"]
                             }

      products_elements << {
                              :title => "Naiselle!", 
                              :subtitle => "45€", 
                              :buttons => [{:type => "web_url", :url => "https://www.interflora.fi/product/444/268_Naiselle_/", :title => "Kauppa"}],
                              :image_url => val["https://www.interflora.fi/assets/r/w/306/h/306/f/products/2016/02/29/12/16/44/interflora5331-1-jpg"]
                             }
      
      top_3_deals_hash = {:attachment => 
                          {:type => "template", 
                           :payload => {
                             :template_type => "generic",
                             :elements => products_elements
                           }
                          }
                        }
            
      return top_3_deals_hash
   
  end
  
end
