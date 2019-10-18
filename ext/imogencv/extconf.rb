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

incdir_default = "/usr/local/include"
libdir_default = "/usr/local/lib"

# expect to call with --with-opencv4-include=DIR and --with-opencv4-lib=DIR
incdir, libdir = dir_config("opencv4", incdir_default, libdir_default)
unless incdir && incdir != incdir_default
	puts "using default opencv4 include path: #{incdir}"
end

opencv_header = 'opencv2/features2d.hpp'

unless find_header(opencv_header, *[incdir, incdir_default, "/usr/local"].compact.uniq)
	header_path = File.join(incdir, opencv_header)
	exist = File.exist?(header_path)
	puts "header exist at #{header_path} : #{exist}"
	tried = try_header(cpp_include(opencv_header), "-I#{incdir}".quote)

	unless tried and add_flags_if_header(opencv_header, incdir, libdir)
		puts "Cannot find required header: #{opencv_header}"
		exit 1
	end
end

append_cflags('-stdlib=libc++')
@libdir_basename ||= 'lib'
$LIBRUBYARG.prepend(' ') # there's some weird spacing issue in rice's lib linking routine
create_makefile('imogencv')