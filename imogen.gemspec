# -*- encoding: utf-8 -*-
Gem::Specification.new do |spec|
  spec.name = 'imogen'
  spec.authors = ["Ben Armintor", "Eric O'Hanlon"]
  spec.email = "armintor@gmail.com"
  spec.require_paths = ["lib"]
  spec.files = Dir.glob("{lib,spec}/**/*")
  spec.summary = "IIIF image derivative generation helpers for Vips"
  spec.homepage    = "https://github.com/cul/imogen"
  spec.version = "0.4.0-rc.1"

  spec.add_dependency 'ruby-vips'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.12'
end
