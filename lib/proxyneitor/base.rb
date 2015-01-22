require "erb"
require 'pathname'
require 'fileutils'
require 'proxyneitor/builders'

module Proxyneitor

  class Base
    include Proxyneitor::Builders

    def initialize(app = nil)
      @root = File.join(ENV['HOME'],'Proxies')
      @os = Gem::Platform.local.os
      @app = app 
    end

  end


end
