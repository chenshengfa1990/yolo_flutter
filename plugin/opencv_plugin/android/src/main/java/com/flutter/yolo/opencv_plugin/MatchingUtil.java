package com.flutter.yolo.opencv_plugin;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.os.Environment;
import android.util.Log;
import android.util.Pair;

import org.opencv.android.Utils;
import org.opencv.core.Core;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.MatOfRect;
import org.opencv.core.Point;
import org.opencv.core.Rect;
import org.opencv.core.Size;
import org.opencv.imgcodecs.Imgcodecs;
import org.opencv.imgproc.Imgproc;

import java.util.ArrayList;
import java.util.List;


public class MatchingUtil {

    public static ArrayList<OpenCvDetectModel> match(Bitmap srcBitmap, Bitmap templateBitmap, String labelName, boolean useBinary, int threshold) {
        Mat sourceMat = new Mat();
        Utils.bitmapToMat(srcBitmap, sourceMat);

        Point pointLeftTop = new Point(125 * sourceMat.cols() / 1184, 339 *  sourceMat.rows() / 540);
        Point pointRightBottom = new Point(985 * sourceMat.cols() / 1184, 400 * sourceMat.rows() / 540);
        Rect regionRect = new Rect(pointLeftTop, pointRightBottom);

        Mat croppedSrc = new Mat(sourceMat, regionRect);

        Mat templateMat = new Mat();
        Utils.bitmapToMat(templateBitmap, templateMat);

        Mat scaleDetect = new Mat();
        Size newSize = new Size(templateMat.cols() * sourceMat.cols() / 1184, templateMat.rows() * sourceMat.rows() / 540);
        Imgproc.resize(templateMat, scaleDetect, newSize);

        sourceMat.release();
        templateMat.release();
//        return pyramidMatch(sourceImg, detectImg,(float)threshold / 100.f);
//        allMatch(sourceImg, detectImg, (float)threshold / 100.f);
        return allMatch2(croppedSrc, scaleDetect, labelName, useBinary, (float)threshold / 100.f);
    }

    public static OpenCvDetectModel match(Mat inFile, Bitmap templateFile, android.graphics.Rect rect, int threshold) {
        return match(inFile,templateFile,rect == null?null:new org.opencv.core.Rect(rect.left,rect.top,rect.width(),rect.height()),threshold);
    }

    public static OpenCvDetectModel match(Mat inFile, Bitmap templateFile,org.opencv.core.Rect rect, int threshold) {
        if (inFile == null || inFile.empty()){
            return null;
        }
        if (rect!=null){
            try {
                inFile = new Mat(inFile,rect);
            } catch (Exception e){
//                RuntimeLog.i("区域已超出屏幕,自动使用全屏识别");
            }
        }
        Mat tempImg = new Mat();
        Utils.bitmapToMat(templateFile,tempImg);
        ImageUtils.recycle(templateFile);

        return pyramidMatch(inFile,tempImg,(float)threshold / 100.f);
    }


    /*
    * 金字塔图像算法
    * */
    private static OpenCvDetectModel pyramidMatch(Mat sourceImg, Mat detectImg,float threshold) {
        long c = System.currentTimeMillis();
        if (sourceImg == null || sourceImg.empty()) {
            Log.e("OpenCVPlugin", "图像识别: 图像为空！");
            return null;
        }
        if (detectImg == null || detectImg.empty()){
            Log.e("OpenCVPlugin", "图像识别: 待识别图像为空！");
            return null;
        }

        org.opencv.core.Point point = TemplateMatching.fastTemplateMatching(sourceImg, detectImg, TemplateMatching.MATCHING_METHOD_DEFAULT,
                0.75f, threshold, TemplateMatching.MAX_LEVEL_AUTO);


        if (point != null) {
            //RuntimeLog.log("MatchingUtil","true math use "+(System.currentTimeMillis() - c)+"ms");
//            return new OpenCvDetectModel((int)point.x, (int)point.y, detectImg.cols(), detectImg.rows());
        }
        //RuntimeLog.log("MatchingUtil","false math use "+(System.currentTimeMillis() - c)+"ms");
        return null;
    }

    private static void allMatch1(Mat src, Mat template, float threshold) {
        TemplateMatching.getAllMatch1(src, template, threshold, TemplateMatching.MATCHING_METHOD_DEFAULT);
    }

    private static ArrayList<OpenCvDetectModel> allMatch2(Mat src, Mat template, String labelName, boolean useBinary, float threshold) {
        return TemplateMatching.getAllMatch2(src, template, labelName, useBinary, threshold);
    }
}