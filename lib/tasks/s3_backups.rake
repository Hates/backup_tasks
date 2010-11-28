require 'aws/s3'
require 'yaml'
require 'erb'
require 'active_record'

namespace :s3 do

  desc "Backup the database to S3"
  task :db_backup do
    archive = "#{'db'}-#{Rails.env}-#{Time.now.to_s(:number)}"
    database, user, password = retrieve_db_info
    cmd = "mysqldump --opt --skip-add-locks -u#{user} "
    cmd += " -p'#{password}' " unless password.nil?
    cmd += " #{database} > #{archive}.sql"
    result = system(cmd)
    raise("mysqldump failed.  msg: #{$?}") unless result
    send_to_s3(archive)

    archive = "#{'db'}-#{Rails.env}_facebook-#{Time.now.to_s(:number)}"
    database, user, password = retrieve_db_info
    cmd = "mysqldump --opt --skip-add-locks -u#{user} "
    cmd += " -p'#{password}' " unless password.nil?
    cmd += " #{database}_facebook > #{archive}_facebook.sql"
    result = system(cmd)
    raise("mysqldump failed.  msg: #{$?}") unless result
    send_to_s3("#{archive}_facebook")
  end

end

def retrieve_db_info
  # read the remote database file....
  # there must be a better way to do this...
  result = File.read Rails.root.join("config", "database.yml")
  result.strip!
  config_file = YAML::load(ERB.new(result).result)
  username = config_file[Rails.env]['username'] || "root"
  password = config_file[Rails.env]['password']
  return [
    config_file[Rails.env]['database'],
    username,
    password
  ]
end

def send_to_s3(tmp_file)
  @s3_configs ||= YAML::load(ERB.new(IO.read(Rails.root.join("config" , "s3.yml")).result))
  AWS::S3::Base.establish_connection!(:access_key_id => @s3_configs[Rails.env]['access_key_id'], :secret_access_key => @s3_configs[Rails.env]['secret_access_key'])
  AWS::S3::Bucket.create("db-#{Rails.env}")

  archive = "#{tmp_file}.tar.gz"
  cmd = "tar -cpzf #{archive} #{tmp_file}.sql"
  puts cmd
  system cmd

  AWS::S3::S3Object.store(archive, open(archive), "db-#{Rails.env}")
  cmd = "rm -rf #{archive} #{tmp_file}.sql"
  puts cmd
  system cmd
end

