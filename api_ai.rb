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
    products = HTTParty.get "https://obscure-basin-19654.herokuapp.com/product?name=#{product}"
        
    # build hash response containing 3 products
    if products.any?
      products_elements = []                                    
      # get the top 3 deals to give more contex to the user
      products.each_with_index do |val, index|        
        products_elements << {
                              :title => val["description"], 
                              :subtitle => val["price"], 
                              :buttons => [{:type => "web_url", :url => val["short_best_offer_link"], :title => "Comprar"}],
                              :image_url => val["image_link"]
                             }
        break if index == 2
      end
      
      top_3_deals_hash = {:attachment => 
                          {:type => "template", 
                           :payload => {
                             :template_type => "generic",
                             :elements => products_elements
                           }
                          }
                        }
            
      return top_3_deals_hash
    else
      return {:text => "Não encontrei nenhum #{product_name}"}
      return {:text => "Não encontrei nenhum #{product}"}
    end 
   
  end
  
end
