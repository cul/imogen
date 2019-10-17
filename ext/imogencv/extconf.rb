require 'mkmf-rice'

osx = RbConfig::CONFIG['target_os'] =~ /darwin/
if osx
	$CFLAGS << " " << '-std=c++14' # damn the torpedoes!
	incdir, libdir = dir_config("opencv4", "/usr/local/include", "/usr/local/lib")
else
	incdir, libdir = dir_config("opencv", "/usr/local/include", "/usr/local/lib")
end
append_cflags('-stdlib=libc++')
@libdir_basename ||= 'lib'
$LIBRUBYARG.prepend(' ') # there's some weird spacing issue in rice's lib linking routine
create_makefile('imogencv')