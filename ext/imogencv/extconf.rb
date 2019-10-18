require 'mkmf-rice'

osx = RbConfig::CONFIG['target_os'] =~ /darwin/

if osx
	$CFLAGS << " " << '-std=c++14' # damn the torpedoes!
end

def real_inc_dir(src)
	 File.symlink?(src) ? File.realdirpath(src) : src
end

def add_flags_if_header(header, header_dir, lib_dir)
	a_file = File.join(header_dir, header)
	exists = File.exist?(a_file)
	puts "#{a_file} exists ... #{exists}"
	if exists
		inc_opt = "-I#{header_dir}".quote
		lib_opt = "-L#{lib_dir}".quote
		puts "adding compiler flags:\n#{inc_opt}\n#{lib_opt}"
		$INCFLAGS << " " << inc_opt
		$LIBPATH = $LIBPATH | [lib_dir]
	end
	exists
end

incdir4, libdir4 = dir_config("opencv4", '/usr/local/include/opencv4', '/usr/local/lib/opencv4')
incdir, libdir = dir_config("opencv", '/usr/local/include/opencv', '/usr/local/lib/opencv')

opencv_header = 'opencv2/features2d.hpp'
unless find_header(opencv_header, incdir) || find_header(opencv_header, incdir4)
	puts "find_header failed (opencv4)"
	unless add_flags_if_header(opencv_header, incdir4, libdir4) ||
		add_flags_if_header(opencv_header, incdir, libdir) ||
		add_flags_if_header(opencv_header, '/usr/local/include', '/usr/local/lib')
		exit 1
	end
end
append_cflags('-stdlib=libc++')
@libdir_basename ||= 'lib'
$LIBRUBYARG.prepend(' ') # there's some weird spacing issue in rice's lib linking routine
create_makefile('imogencv')