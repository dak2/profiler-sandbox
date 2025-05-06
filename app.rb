require 'sinatra'
require 'json'
require 'securerandom'

# Set the bind address to 0.0.0.0 to make the server accessible outside the container
set :bind, '0.0.0.0'
set :port, 4567

# Root endpoint
get '/' do
  "Welcome to the Profiler Sandbox!"
end

# Profile endpoint - returns sample profile data
get '/profile/:id' do
  content_type :json
  profile = {
    id: params[:id],
    name: "User #{params[:id]}",
    email: "user#{params[:id]}@example.com",
    created_at: Time.now.iso8601,
    stats: {
      cpu_usage: rand(1..100),
      memory_usage: rand(100..1000),
      disk_usage: rand(1..500)
    }
  }
  
  JSON.generate(profile)
end

# Health check endpoint
get '/health' do
  content_type :json
  JSON.generate({
    status: 'ok',
    timestamp: Time.now.iso8601,
    version: '1.0.0'
  })
end

# Profiler Sandbox endpoint - simulates collecting profiling data
post '/profile/collect' do
  content_type :json
  
  # Parse the request body
  request_payload = JSON.parse(request.body.read, symbolize_names: true)
  
  # Simulate processing the profiling data
  result = {
    success: true,
    profile_id: SecureRandom.uuid,
    timestamp: Time.now.iso8601,
    metrics: {
      execution_time: rand(10..500),
      memory_peak: rand(100..1000),
      cpu_time: rand(5..100)
    },
    request_data: request_payload
  }
  
  JSON.generate(result)
end

# Error handling
not_found do
  content_type :json
  status 404
  JSON.generate({
    error: 'Not Found',
    message: 'The requested resource could not be found'
  })
end

error do
  content_type :json
  status 500
  JSON.generate({
    error: 'Internal Server Error',
    message: 'An unexpected error occurred'
  })
end
