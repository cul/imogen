#include "rice/Class.hpp"
#include "opencv2/features2d.hpp"
#include "opencv2/imgproc.hpp"
#include "kaze_features/point2f.hpp"
using namespace Rice;

extern "C";
void Init_keypoint()
{
	Data_Type<cv::KeyPoint> rb_cKeyPoint =
		define_class<cv::KeyPoint>("KeyPoint")
		.define_constructor(Constructor<cv::KeyPoint>())
		.define_method("overlap?", cv::KeyPoint::overlap)
}
