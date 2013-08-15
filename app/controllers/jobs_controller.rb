class JobsController < ApplicationController
  def index
    @ip = ProxyWorker.new.perform
    #@ip = AlertWorker.new.perform(2)
  end
end
