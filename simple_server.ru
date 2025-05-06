require "socket"
require "logger"
require "rack"
require "rackup"

class App
  def call(env)
    if env["PATH_INFO"] == "/"
      [200, {"content-type" => "text/plain"}, ["It works!"]]
    else
      [404, {"content-type" => "text/plain"}, ["Not Found"]]
    end
  end
end

class SimpleServer
  def self.run(app, **options)
    new(app, options).start
  end

  def initialize(app, options)
    @app = app
    @options = options
    @logger = Logger.new($stdout)
  end

  def start
    @logger.info "SimpleServer starting on #{@options[:Host]}:#{@options[:Port]}"
    server = TCPServer.new(@options[:Host], @options[:Port].to_i)
    loop do
      client = server.accept

      request_line = client.gets&.chomp
      %r[^GET (?<path>.+) HTTP/1.1$].match(request_line)
      path = Regexp.last_match(:path)

      unless path
        client.puts "HTTP/1.1 501 Not Implemented"
        client.close
        next
      end

      request_headers = {}
      loop do
        header_field = client.gets&.chomp
        break if header_field.nil? || header_field.empty?
        
        match = %r[^(?<name>[^:]+):\s+(?<value>.+)$].match(header_field)
        break unless match

        request_headers[match[:name]] = match[:value]
      end

      env = {
        Rack::REQUEST_METHOD    => "GET",
        Rack::SCRIPT_NAME       => "",
        Rack::PATH_INFO         => path,
        Rack::SERVER_NAME       => @options[:Host],
        Rack::SERVER_PORT       => @options[:Port].to_s,
        Rack::SERVER_PROTOCOL   => "HTTP/1.1",
        Rack::RACK_INPUT        => client,
        Rack::RACK_ERRORS       => $stderr,
        Rack::QUERY_STRING      => "",
        Rack::RACK_URL_SCHEME   => "http",
      }

      status, headers, body = @app.call(env)

      client.puts "HTTP/1.1 #{status} #{Rack::Utils::HTTP_STATUS_CODES[status]}"
      headers.each do |name, value|
        client.puts "#{name}: #{value}"
      end
    end
  end
end

Rackup::Handler.register "simple_server", SimpleServer

run App.new
