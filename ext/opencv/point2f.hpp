#include "rice/Class.hpp"
#include "opencv2/features2d.hpp"
using namespace Rice;

extern "C";
void Init_point2f()
{
	Data_Type<cv::Point2f> rb_cPoint2f =
		define_class<cv::Point2f>("Point2f")
		.define_constructor(Constructor<cv::Point2f, float, float>())
}
