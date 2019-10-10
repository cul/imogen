require 'mkmf-rice'
pkg_config('opencv4')
osx = RbConfig::CONFIG['target_os'] =~ /darwin/
if osx
	$CFLAGS << " " << '-std=c++14' # damn the torpedoes!
end

append_cflags('-stdlib=libc++')

incdir, libdir = dir_config("opencv4", "/usr/local/include", "/usr/local/lib")

unless have_header('opencv2/features2d.hpp') do |pt| puts "tried header at #{pt}"; pt; end
	print("need opencv4\n")
	exit 1
end

puts CONFIG["configure_args"]
$LIBRUBYARG.prepend(' ') # there's some weird spacing issue in rice's lib linking routine
create_makefile('imogencv')