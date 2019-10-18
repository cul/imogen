# -*- encoding: utf-8 -*-
Gem::Specification.new do |spec|
  spec.name = 'imogen'
  spec.authors = ["Ben Armintor"]
  spec.email = "armintor@gmail.com"
  spec.require_paths = ["lib"]
  spec.files = ['ext/imogencv/imogencv.cpp'] + Dir.glob("{lib,spec,ext/imogencv}/**/*")
  spec.summary = "derivative generation via FreeImage and smart square thumbnail via OpenCV"
  spec.homepage    = "https://github.com/cul/imogen"
  spec.version = "0.1.8"

  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rice'
  spec.add_development_dependency 'rake-compiler'
  spec.extensions = ['ext/opencv/extconf.rb']
end