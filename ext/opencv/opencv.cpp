#include "rice/Class.hpp"
#include "opencv2/features2d.hpp"
#include "opencv2/imgproc.hpp"

using namespace Rice;


extern "C"
void Init_opencv()
{
	Module rb_mOpenCV = define_module("OpenCV");
}