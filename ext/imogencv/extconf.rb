require 'mkmf-rice'

osx = RbConfig::CONFIG['target_os'] =~ /darwin/

if osx
	$CFLAGS << " -x c++ -std=c++14"# damn the torpedoes!
else
	$CFLAGS << " -x c++"
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

have_library('stdc++')
# MakeMakefile::CONFTEST_C = "#{CONFTEST}.cc"

# with --with-opencv4-config=FILEPATH
opencv4_config = (pkg_config('opencv4') || []).detect { |c| c =~ /\-L\/\w+/ }

# expect to call with --with-opencv4-include=DIR and --with-opencv4-lib=DIR
incdir, libdir = dir_config("opencv4", incdir_default, libdir_default)

unless !opencv4_config && incdir && incdir != incdir_default
	puts "using default opencv4 include path: #{incdir_default}"
end

unless !opencv4_config && libdir && libdir != libdir_default
	puts "using default opencv4 library path: #{incdir_default}"
end

opencv_header = 'opencv2/features2d.hpp'

unless find_header(opencv_header, *[incdir, incdir_default, "/usr/local"].compact.uniq)
	open(MakeMakefile::Logging.instance_variable_get(:@logfile), 'r') do |logblob|
		logblob.each { |logline| puts logline.strip }
	end
	puts "Cannot find required header: #{opencv_header}"
	puts "if this output is from rake compile, consider adding:"
	puts "rake compile -- --with-opencv4-include=DIR"
	exit 1
end

required_libs = [
	'opencv_core',
	'opencv_imgcodecs',
	'opencv_imgproc',
	'opencv_features2d'
]
required_libs.each do |lib|
	unless find_library(lib, nil, *[libdir, libdir_default, "/usr/local"].compact.uniq)
		puts "Cannot find required lib: #{lib}"
		exit 1
	end
end

append_cflags('-stdlib=libc++')
@libdir_basename ||= 'lib'
$LIBRUBYARG.prepend(' ') # there's some weird spacing issue in rice's lib linking routine
create_makefile('imogencv')