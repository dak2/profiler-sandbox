# Profiler Sandbox API

A simple Rack-based API for collecting and retrieving profiling data.

## Endpoints

- `GET /` - Welcome message
- `GET /profile/:id` - Get profile data for a specific ID
- `GET /health` - Health check endpoint
- `POST /profile/collect` - Submit profiling data

## Building and Running

### Using Docker

Build the Docker image:

```bash
docker build -t profiler-sandbox .
```

Run the container:

```bash
docker run -p 4567:4567 profiler-sandbox
```

The API will be available at http://localhost:4567

### Running Locally

Install dependencies:

```bash
bundle install
```

Start the server:

```bash
bundle exec ruby app.rb
```

## Example API Calls

### Get Profile Data

```bash
curl http://localhost:4567/profile/123
```

### Health Check

```bash
curl http://localhost:4567/health
```

### Submit Profile Data

```bash
curl -X POST -H "Content-Type: application/json" -d '{"application":"myapp","duration":150,"timestamp":"2025-05-06T12:00:00Z"}' http://localhost:4567/profile/collect
