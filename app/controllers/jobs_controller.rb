class JobsController < ApplicationController
  def index
    ProxyScraperWorker.new.perform
    @ip = "oki"
    #@ip = AlertWorker.new.perform(1)
  end
end
