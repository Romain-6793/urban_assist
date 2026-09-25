RubyLLM.configure do |config|
  config.openai_api_key = ENV["OPENAI_API_KEY"]
  config.openai_api_base = "https://models.github.ai/inference/"
  config.default_model = "openai/gpt-4o-mini"
  # ... see RubyLLM configuration guide for other models
end
