require 'mkmf-rice'

osx = RbConfig::CONFIG['target_os'] =~ /darwin/
if osx
	$CFLAGS << " " << '-std=c++14' # damn the torpedoes!
end
append_cflags('-stdlib=libc++')
@libdir_basename ||= 'lib'
incdir, libdir = dir_config("opencv4", "/usr/local/include", "/usr/local/lib")
$LIBRUBYARG.prepend(' ') # there's some weird spacing issue in rice's lib linking routine
create_makefile('imogencv')