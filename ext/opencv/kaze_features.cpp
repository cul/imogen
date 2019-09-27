#include "rice/Class.hpp"
#include "opencv2/features2d.hpp"
#include "opencv2/imgproc.hpp"

using namespace Rice;


VALUE process(VALUE filename)
{
	Check_Type(filename, T__STRING);
	Mat image = imread(StringValueCStr(filename),IMREAD_GRAYSCALE);
	vector<KeyPoint> keypoints;
	Ptr<cv::KAZE> alg = KAZE::create();
	Mat features;
	alg->detectAndCompute(image, noArray(), keypoints, features);

}

extern "C"
void Init_kaze_features()
{
	Class rb_cKazeFeatures = define_class("KazeFeatures");
}