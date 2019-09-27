require 'mkmf-rice'
pkg_config('opencv4')
osx = RbConfig::CONFIG['target_os'] =~ /darwin/
if osx
	$CFLAGS << " " << '-std=c++17' # damn the torpedoes!
end

append_cflags('-stdlib=libc++')

puts CONFIG["configure_args"]
create_makefile('opencv','opencv')