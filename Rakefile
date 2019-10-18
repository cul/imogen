# -*- ruby -*-

require 'rubygems'
require 'rake/extensiontask'

Rake::ExtensionTask.new('imogencv') do |ext|
	ix = ARGV.index('opencv4-include')
	ext.config_options << "--with-opencv4-include=#{ARGV[ix + 1]}" if ix
	ix = ARGV.index('opencv4-lib')
	ext.config_options << "--with-opencv4-lib=#{ARGV[ix + 1]}" if ix
end
Rake::Task[:spec].prerequisites << :compile