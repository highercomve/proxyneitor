require "proxyneitor/version"
require 'proxyneitor/base'
require "thor"


module Proxyneitor

  class CLI < Thor
    desc "create APP_NAME PORT", "This create the new app in ~/Proxies/APP_NAME/ngnix.conf"
    def create(app, port)
      proxy = Proxyneitor::Base.new(app)
      proxy.create(port)

      say "All done!", :green

      say "NOTE: you have to add #{app}.dev to your /etc/hosts file", :yellow
    end

    desc "delete APP_NAME", "This eliminate a app in ~/Proxies/APP_NAME/"
    def delete(app)

      answer = ask "Are you sure of removing app folder?", :limited_to => ['y', 'n']

      if answer =~ /(y|Y)/
        proxy = Proxyneitor::Base.new(app)
        proxy.remove

        say "All done!", :green
      else
        say "No deletes for today", :red
      end
    end

    desc "install", "install proxynator from scrach"
    option :reinstall, :type => :boolean
    def install
      proxy = Proxyneitor::Base.new
      proxy.install(options[:reinstall])
      say "All done!", :green
    end

    desc "list", "List of proxies inside proxyneitor"
    def list
      say "All applications: \n\n", :green
      proxy = Proxyneitor::Base.new
      proxy.list
      say "\n\n"
    end
  end
end
