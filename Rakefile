require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Generate documentation for the devise_active_directory_authenticatable plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'DeviseActiveDirectoryAuthenticatable'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "devise_active_directory_authenticatable"
    gemspec.summary = "Active Directory authentication module for Devise"
    gemspec.description = "Active Directory authentication module for Devise, based off of LDAP Authentication"
    gemspec.email = "ajrkerr@gmail.com"
    gemspec.homepage = "http://github.com/ajrkerr/devise_activedirectory_authenticatable"
    gemspec.authors = ["Adam Kerr"]
    gemspec.add_dependency "devise", ">= 1.1.5"
    gemspec.add_dependency "active_directory", ">= 1.2.3"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
