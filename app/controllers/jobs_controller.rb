class JobsController < ApplicationController
  def index
    ProxyScraperWorker.perform_async
    @proxies = Proxy.all
  end
end
