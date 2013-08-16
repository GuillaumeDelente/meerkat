class JobsController < ApplicationController
  def index
    @ip = ProxyWorker.new.perform
    #@ip = AlertWorker.new.perform(0)
  end
end
