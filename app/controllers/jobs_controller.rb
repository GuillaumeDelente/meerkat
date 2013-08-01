class JobsController < ApplicationController
  def index
    #ProxyScraperWorker.perform_async
    @ip = AlertWorker.new.perform(1)
  end
end
