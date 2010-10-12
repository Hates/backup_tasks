# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "backup_tasks/version"

Gem::Specification.new do |s|
  s.name        = "backup_tasks"
  s.version     = BackupTasks::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Richard Hart"]
  s.email       = ["richard@ur-ban.com"]
  s.homepage    = "http://github.com/Hates/backup_tasks"
  s.summary     = %q{Simple rake task for backing up to S3.}
  s.description = %q{Simple rake task for backing up to S3.}

  s.rubyforge_project = "backup_tasks"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
