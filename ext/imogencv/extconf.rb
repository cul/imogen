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

required_headers = {}
required_libs = {}

required_headers['opencv4'] = [ 'opencv2/features2d.hpp' ]
required_libs['opencv4'] = [
	'opencv_core',
	'opencv_imgcodecs',
	'opencv_imgproc',
	'opencv_features2d'
]

required_libs['zlib'] = ['z']
required_libs['libwebp'] = ['webp']
required_libs['libjpeg'] = ['jpeg']
required_libs['libtiff-4'] = ['tiff']
required_libs['libpng'] = ['png16']
required_libs['jasper'] = [] # just run pkg-config if you can
required_libs['OpenEXR'] = ['IlmImf']

all_deps = (required_libs.keys | required_headers.keys).sort.uniq
all_deps.each do |dep_key|
	has_pkg_config = (pkg_config(dep_key) || []).detect { |c| c =~ /\-L\/\w+/ }

	# expect to call with --with-opencv4-include=DIR and --with-opencv4-lib=DIR or --withopencv4-dir=DIR
	incdir, libdir = dir_config(dep_key, incdir_default, libdir_default) unless has_pkg_config

	unless !has_pkg_config && incdir && incdir != incdir_default
		puts "using default #{dep_key} include path: #{incdir_default}"
	end

	unless !has_pkg_config && libdir && libdir != libdir_default
		puts "using default #{dep_key} library path: #{libdir_default}"
	end

	include_paths = [incdir_default, "/usr/local"]
	include_paths = ([incdir, File.join(incdir, dep_key)] | include_paths) if incdir

	required_headers.fetch(dep_key, []).each do |hdr|
		unless find_header(hdr, *include_paths.compact.uniq)
			open(MakeMakefile::Logging.instance_variable_get(:@logfile), 'r') do |logblob|
				logblob.each { |logline| puts logline.strip }
			end
			puts "Cannot find required header: #{hdr}"
			puts "if this output is from rake compile, consider adding:"
			puts "rake compile -- --with#{dep_key}-include=DIR"
			exit 1
		end
	end

	lib_paths = [libdir_default, "/usr/local"]
	lib_paths.unshift(libdir) if libdir

	required_libs.fetch(dep_key, []).each do |lib|
		unless find_library(lib, nil, *lib_paths.compact.uniq)
			puts "Cannot find required lib: #{lib}"
			exit 1
		end
	end
end

append_cflags('-stdlib=libc++')
@libdir_basename ||= 'lib'
$LIBRUBYARG.prepend(' ') # there's some weird spacing issue in rice's lib linking routine
create_makefile('imogencv')