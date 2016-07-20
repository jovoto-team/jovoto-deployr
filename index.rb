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
    @opsworks = Aws::OpsWorks::Client.new region: 'us-east-1'
  end

  def go branch
    app_id = APPS[branch] or return p "the branch #{branch} is not configured for auto-deploy."

    workload = {
      stack_id: '08fa10ff-dcda-45f8-afec-5b0348a49141',
      app_id:   app_id,
      command:  {
        name: 'deploy',
        args: { migrate: ['true'] }
      }
    }
    # p workload
    begin
      @opsworks.create_deployment workload
      p "dispatched branch '#{branch}' -> app #{app_id}"
    rescue Exception => e
      p e.inspect
      p e.backtrace
    end
  end
end

post '/' do
  if (payload = params[:payload])
    parsed  = JSON::parse(payload)
    ref     = parsed['ref']
    if branch = ref.gsub(%r{refs/heads/}, '')
      Dispatcher.new.go branch
    end
  end
end
