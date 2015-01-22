require "proxyneitor/version"
require "thor"
require "erb"
require 'pathname'
require 'fileutils'

module Proxyneitor

  class CLI < Thor
    desc "create APP_NAME PORT", "This create the new app in ENV['PROXYNEITOR_ROOT']/APP_NAME/ngnix.conf"
    def create(app, port)
      app = app
      port = port
      # Use de ~/Proxies folder by default but can be configurate by setting environment variable PROXYNEITOR_ROOT
      root = ENV['PROXYNEITOR_ROOT'] || File.join(ENV['HOME'],'Proxies')
      app_dir = File.join(root, app)

      ## Create ~/Proxies/APP_NAME folder if dont exist
      Dir.mkdir(app_dir) unless File.directory?(app_dir)

      ssl = File.exists?(File.join(root, app, 'ssl')) ? File.join(root, app, 'ssl') : File.join(root, app, 'tls')
      use_ssl = File.exists?(File.join(ssl, 'server.crt')) && File.exists?(File.join(ssl, 'server.key'))

      # write app/nginx.conf

      puts "Building nginx conf for #{app_dir}"

      template = File.open(File.join(Pathname.new(__FILE__).dirname, 'proxyneitor/templates/nginx.conf.erb'), 'rb').read
      File.open(File.join(root, app, 'nginx.conf'), 'w') do |file|
        file.write(ERB.new(template).result(binding))
      end

      puts "Restarting nginx"
      system('sudo nginx -s reload')

      puts "All done!"

      puts "NOTE: you have to add #{app}.dev to your /etc/hosts file"
    end

    desc "delete APP_NAME", "This eliminate a app in ENV['PROXYNEITOR_ROOT']/APP_NAME/ngnix.conf"
    def delete(app)
      root = ENV['PROXYNEITOR_ROOT'] || File.join(ENV['HOME'],'Proxies')
      app_dir = File.join(root, app)

      puts "Removing app from #{app_dir}"
      FileUtils.rm_rf(app_dir)

      puts "All done!"
    end

    desc "install", "install proxynator from scrach"
    def install
      root = ENV['PROXYNEITOR_ROOT'] || File.join(ENV['HOME'],'Proxies')
      os = Gem::Platform.local.os

      puts "Instaling nginx"

      if os == 'darwin'
        system('brew install nginx')
        nginx_folder = '/usr/local/etc/nginx/'
      else
        system('sudo apt-get install nginx')
        nginx_folder = '/etc/nginx/'
      end

      puts "Loading new nginx.conf file"

      Dir.mkdir(File.join(nginx_folder, 'sites-enabled')) unless File.directory?(File.join(nginx_folder, 'sites-enabled'))

      template = File.open(File.join(Pathname.new(__FILE__).dirname, 'proxyneitor/templates/base_nginx.conf.erb'), 'rb').read
      File.open(File.join(root, app, 'nginx.conf'), 'w')  { |file| file.write(ERB.new(template).result(binding)) }

      puts "creating default server for nginx"
      unless File.exists?(File.join(nginx_folder, 'sites-enabled/default'))
        default_site_template = File.open(File.join(Pathname.new(__FILE__).dirname, 'proxyneitor/templates/default'), 'rb').read
        File.open(File.join(nginx_folder, 'sites-enabled', 'default'), 'w')  { |file| file.write(default_site_template) }
      end

      puts "All done!"
    end
  end

end
