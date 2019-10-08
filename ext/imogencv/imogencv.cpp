#include "rice/Class.hpp"
#include "opencv2/features2d.hpp"
#include "opencv2/imgproc.hpp"
#include "opencv2/imgcodecs.hpp"

using namespace Rice;

Object process_kaze_features(VALUE filename)
{
	Check_Type(filename, T_STRING);
	cv::Mat image = imread(StringValueCStr(filename), cv::IMREAD_GRAYSCALE);
	std::vector<cv::KeyPoint> keypoints;
	cv::Ptr<cv::KAZE> alg = cv::KAZE::create();
	cv::Mat features;
	alg->detectAndCompute(image, cv::noArray(), keypoints, features);
}


extern "C"
void Init_imogencv()
{
	Module rb_mOpenCV = define_module("ImogenCV");
	Class rb_cKazeFeatures = rb_mOpenCV.define_class("KazeFeatures");
	rb_cKazeFeatures.define_method("process", process_kaze_features);
}