class JobsController < ApplicationController
  def index
    #ProxyScraperWorker.new.perform
    @ip = AlertWorker.new.perform(2)
  end
end
