# -*- encoding: utf-8 -*-
Gem::Specification.new do |spec|
  spec.name = 'imogen'
  spec.authors = ["Ben Armintor"]
  spec.email = "armintor@gmail.com"
  spec.require_paths = ["lib"]
  spec.files = Dir.glob("{lib,spec}/**/*")
  spec.summary = "IIIF image derivative generation helpers for Vips"
  spec.homepage    = "https://github.com/cul/imogen"
  spec.version = "0.2.0"

  spec.add_dependency 'ruby-vips'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end