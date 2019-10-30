#include "rice/Class.hpp"
#include "rice/Constructor.hpp"
#include "rice/Enum.hpp"
#include "opencv2/features2d.hpp"
#include "opencv2/imgproc.hpp"
#include "opencv2/imgcodecs.hpp"

using namespace Rice;

Object process_kaze_features(Object r_image)
{
	cv::Mat image = from_ruby<cv::Mat>(r_image);
	std::vector<cv::KeyPoint> keyPoints;
	cv::Ptr<cv::KAZE> alg = cv::KAZE::create();
	cv::Mat features;
	alg->detectAndCompute(image, cv::noArray(), keyPoints, features);
	Array a;
	for(cv::KeyPoint keyPoint : keyPoints)
	{
		a.push(to_ruby<cv::Point2f>(keyPoint.pt));
	}
	keyPoints.clear();
	return a;
}

Object load_grayscale(Object filename)
{
	Check_Type(filename, T_STRING);
	cv::String const c_path = cv::String(String(filename).str());
	cv::Mat image = imread(c_path, cv::IMREAD_GRAYSCALE);
	return to_ruby<cv::Mat>(image);
}

Object point2f_x(Object self)
{
	cv::Point2f point = from_ruby<cv::Point2f>(self);
	return to_ruby<int>(point.x);
}

Object point2f_y(Object self)
{
	cv::Point2f point = from_ruby<cv::Point2f>(self);
	return to_ruby<int>(point.y);
}

Object mat_cols(Object self)
{
	cv::Mat image = from_ruby<cv::Mat>(self);
	return to_ruby<int>(image.cols);
}

Object mat_rows(Object self)
{
	cv::Mat image = from_ruby<cv::Mat>(self);
	return to_ruby<int>(image.rows);
}

Object mat_good_features_to_track(Object self, int maxCorners, double qualityLevel, double minDistance, int blockSize, bool useHarrisDetector, double k)
{
	cv::Mat image = from_ruby<cv::Mat>(self);
	cv::Mat mask;
	std::vector<cv::Point2f> corners;
	cv::goodFeaturesToTrack(image, corners, maxCorners, qualityLevel, minDistance, mask, blockSize, useHarrisDetector, k);
	Array a;
	for(cv::Point2f corner : corners)
	{
		a.push(to_ruby<cv::Point2f>(corner));
	}
	corners.clear();
	return a;
}

extern "C"
void Init_imogencv()
{
	Module rb_mOpenCV = define_module("ImogenCV");
	Class rb_cKazeFeatures = rb_mOpenCV.define_class("KazeFeatures");
	rb_cKazeFeatures.define_singleton_method("process", &process_kaze_features);
	Data_Type<cv::Mat> rb_cMat = rb_mOpenCV.define_class<cv::Mat>("Mat")
		.define_method(Identifier("cols"), &mat_cols)
		.define_method(Identifier("rows"), &mat_rows)
		.define_method("good_features_to_track", &mat_good_features_to_track)
		.define_singleton_method("load_grayscale", &load_grayscale);
	Data_Type<cv::Point2f> rb_cPoint2f = rb_mOpenCV.define_class<cv::Point2f>("Point2f")
		.define_method(Identifier("x"), &point2f_x)
		.define_method(Identifier("y"), &point2f_y);
}