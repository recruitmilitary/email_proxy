# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "email_proxy/version"

Gem::Specification.new do |s|
  s.name        = "email_proxy"
  s.version     = EmailProxy::VERSION
  s.authors     = ["Michael Guterl"]
  s.email       = ["michael@diminishing.org"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "email_proxy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_runtime_dependency "mini-smtp-server"
  s.add_runtime_dependency "rumbster"
end
