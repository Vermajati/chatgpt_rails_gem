class PromptController < ApplicationController
  require 'httparty'

  def index
    @prompt = "Type your message here:"
  end

  def reply
    user_input = params[:user_input]
    @response = get_chatgpt_response(user_input)
    render 'index'
  end

  private

  def get_chatgpt_response(prompt)
    response = HTTParty.post("https://api.openai.com/v1/chat/completions",
                             headers: {
                               "Content-Type" => "application/json",
                               "Authorization" => "Bearer #{ENV['OPENAI_API_KEY']}"
                             },
                             body: {
                               model: "text-davinci", # Updated model name
                               prompt: prompt,
                               max_tokens: 150
                             }.to_json)
    debugger
     if response.code == 200 && response.parsed_response && response.parsed_response['choices'].present?
    return response.parsed_response['choices'][0]['text']
  else
    error_message = response.parsed_response['error']['message'] if response.parsed_response && response.parsed_response['error']
    Rails.logger.error "Error fetching response from ChatGPT API: #{response.code} - #{error_message}"
    return "Error: #{error_message}"
  end
  end
end