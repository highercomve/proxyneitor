module Proxyneitor
  module Builders
    def create(port)
      root = @root
      app = @app

      ## Create ~/Proxies/APP_NAME folder if dont exist
      Dir.mkdir(app_dir) unless File.directory?(app_dir)

      ssl = ssl_folder
      use_ssl = use_ssl?
      # write app/nginx.conf
      puts "Building nginx conf for #{app_dir}"

      render_template('nginx.conf.erb', app_file_url('nginx.conf'), false) do |file, template|
        file.write ERB.new(template).result(binding)
      end

      restart_nginx

    end

    def remove
      app = @app
      root = @root
      directory = app_dir

      remove_folder directory
      restart_nginx
    end

    def install(force=false)
      root = @root
      os = @os

      puts "Instaling nginx"
      nginx_folder = load_nginx_folder
      puts "Instalation force" if force == true

      conf_file = File.join(nginx_folder, 'nginx.conf')
      render_template('base_nginx.conf.erb', conf_file, !force) do |file, template|
        puts "Loading new nginx.conf file"
        file.write(ERB.new(template).result(binding))
      end

      puts "This configuration asume that you have this settings in #{nginx_folder}:"
      puts "        include /etc/nginx/conf.d/*.conf;"
      puts "        include /etc/nginx/sites-enabled/*;"

      puts "Setting site-enabled folder and default"
      sites_enabled = File.join(nginx_folder, 'sites-enabled')
      Dir.mkdir(sites_enabled) unless File.directory?(sites_enabled)

      render_template('default', File.join(sites_enabled, 'default'), !force) do |file, template|
        file.write(template)
      end

      puts "Setting conf.d folder and proxyneitor"
      conf_d = File.join(nginx_folder, 'conf.d')
      Dir.mkdir(conf_d) unless File.directory?(conf_d)

      render_template('proxyneitor_site', File.join(conf_d, 'proxyneitor.conf'), !force) do |file, template|
        file.write ERB.new(template).result(binding)
      end

      restart_nginx
    end

    def app_dir
      File.join(@root, @app)
    end

    def ssl_folder
      @ssl ||= File.exists?(File.join(@root, @app, 'ssl')) ? File.join(@root, @app, 'ssl') : File.join(@root, @app, 'tls')
    end

    def use_ssl?
      @user_ssl ||= File.exists?(File.join(@ssl, 'server.crt')) && File.exists?(File.join(@ssl, 'server.key'))
    end

    def app_file_url(file)
      File.join(app_dir, file)
    end

    def render_template(template_url, target , optional = true, &block)
      unless File.exists?(target) && optional == true

        puts "Rendering #{target}"
        template = File.open(File.join(Pathname.new(__FILE__).dirname, 'templates', template_url), 'rb').read

        File.open(target, 'w') do |file|
          block.call(file, template)
        end
      end
    end

    def restart_nginx
      puts "Restarting nginx"
      system('sudo nginx -s reload')
    end

    def remove_folder(directory)
      puts "Removing app from #{app_dir}"
      FileUtils.rm_rf(directory)
    end

    def load_nginx_folder
      if @os == 'darwin'
        system('brew install nginx')
        nginx_folder = '/usr/local/etc/nginx/'
      else
        system('sudo apt-get install nginx')
        nginx_folder = '/etc/nginx/'
      end
    end

    def list
      Dir.glob(File.join(@root, '*')).each { |f| puts f.split('/')[-1] }
    end


    # module_function :create, :install, :remove
  end
end
