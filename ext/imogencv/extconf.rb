require 'mkmf-rice'
pkg_config('opencv4')
osx = RbConfig::CONFIG['target_os'] =~ /darwin/
if osx
	$CFLAGS << " " << '-std=c++14' # damn the torpedoes!
end

append_cflags('-stdlib=libc++')

puts CONFIG["configure_args"]
$LIBRUBYARG.prepend(' ') # there's some weird spacing issue in rice's lib linking routine
create_makefile('imogencv')