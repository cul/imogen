require 'mkmf-rice'

osx = RbConfig::CONFIG['target_os'] =~ /darwin/

if osx
	$CFLAGS << " " << '-std=c++14' # damn the torpedoes!
end

def real_inc_dir(src)
	 File.symlink?(src) ? File.realdirpath(src) : src
end

incdir, libdir = dir_config("opencv", '/usr/local/include/opencv4', '/usr/local/lib/opencv4')

unless find_header('opencv2/features2d.hpp', incdir)
	puts "find_header failed (opencv4)"
	a_file = File.join(incdir, 'opencv2/features2d.hpp')
	exists = File.exist?(a_file)
	puts "#{a_file} exists ... #{exists}"
	if exists
		inc_opt = "-I#{incdir}".quote
		lib_opt = "-L#{libdir}".quote
		puts "adding compiler flags:\n#{inc_opt}\n#{lib_opt}"
		$INCFLAGS << " " << inc_opt
		$LIBPATH = $LIBPATH | [libdir]
	else
		exit 1
	end
end
append_cflags('-stdlib=libc++')
@libdir_basename ||= 'lib'
$LIBRUBYARG.prepend(' ') # there's some weird spacing issue in rice's lib linking routine
create_makefile('imogencv')