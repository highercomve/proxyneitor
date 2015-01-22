require "bundler/gem_tasks"

desc 'Tags version, pushes to remote, and pushes gem'
task :release_to_github => :build do
  sh "git tag v#{Proxyneitor::VERSION}"
  sh "git push origin master"
  sh "git push origin v#{Proxyneitor::VERSION}"
end
