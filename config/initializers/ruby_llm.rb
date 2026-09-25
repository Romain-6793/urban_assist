RubyLLM.configure do |config|
  config.openai_api_key = ENV["OPENAI_API_KEY"]
  config.openai_api_base = "https://models.github.ai/inference"
  # ... see RubyLLM configuration guide for other models
end
