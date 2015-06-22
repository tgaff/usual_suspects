require 'rspec/core/rake_task'
require 'tempfile'
require 'fileutils'
namespace :usual_suspects do

  task :turn_off_alarm do
    puts "Turned off alarm. Would have liked 5 more minutes, though."
  end

  desc 'rename the application from UsualSupects to a specified camel-cased new name'
  task :rename_application, :new_name do |t, args|
    new_name = args[:new_name]
    byebug
    raise "Specify a new name for the application!" if new_name.nil?
    
    LIST_OF_FILES.each do |fname|
      find_and_replace_in_file(fname, 'UsualSuspects', new_name)
      find_and_replace_in_file(fname, underscore('UsualSuspects'), underscore(new_name))
    end
  end

  LIST_OF_FILES = [
    'app/views/layouts/application.html.erb',
    'config/application.rb',
    'config/initializers/session_store.rb'
  ]

  def find_and_replace_in_file(fname, find, replace)
    file_path = File.expand_path fname
    temp_file = Tempfile.new('usual_suspects')
    File.open(file_path, 'r').each do |line|
      temp_file.puts substitute(line, find, replace)
    end
    temp_file.close
    replace_file(temp_file.path, file_path)
  end

  def substitute(input, find, replace)
    input.gsub(find, replace)
  end

  def replace_file(source_path, dest_path)
    FileUtils.mv(source_path, dest_path, force: true)
  end

  private

  #borrowed from ActiveSupport
  def underscore(str)
    str.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end
