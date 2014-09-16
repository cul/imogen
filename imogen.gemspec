# -*- encoding: utf-8 -*-
Gem::Specification.new do |spec|
  spec.name = 'imogen'
  spec.authors = ["Ben Armintor"]
  spec.email = "armintor@gmail.com"
  spec.require_paths = ["lib"]
  spec.files = Dir.glob("{lib,spec}/**/*")
  spec.summary = "derivative generation via FreeImage and smart square thumbnail via OpenCV"
  spec.homepage    = "https://github.com/cul/imogen"
  spec.version = "0.0.7"

  spec.add_dependency 'ruby-opencv'
  spec.add_development_dependency 'rspec'
end
