require 'rubygems'
require 'sinatra'
require 'json'
require 'aws-sdk'

APPS = {
  'develop' => 'e5bd6ab7-d55f-4123-b8d4-31cb288fd59e',
  'release' => '3b5d8888-38a8-4145-8db7-29c5b2238d66'
}

class Dispatcher
  def initialize
    @opsworks = Aws::OpsWorks::Client.new
  end

  def go branch
    workload = {
      stack_id: '08fa10ff-dcda-45f8-afec-5b0348a49141',
      app_id:   APPS[branch],
      command:  {
        name: 'deploy',
        args: {
          migrate: ['true']
        }
      }
    }
    p workload
    begin
      result = @opsworks.create_deployment workload
      p result
      p "dispatched to '#{branch}'"
    rescue Exception => e
      p e.inspect
      p e.backtrace
    end
  end
end

post '/' do
  p "received post"
  if (payload = params[:payload])
    parsed = JSON::parse(payload)
    puts parsed
    ref = parsed['ref']
    if branch = ref.gsub(%r{refs/heads/}, '')
      p "-> rebuilding #{branch}"
      Dispatcher.new.go branch
    end
  end
end
