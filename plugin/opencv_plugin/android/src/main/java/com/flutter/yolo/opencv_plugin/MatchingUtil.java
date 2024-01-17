package com.flutter.yolo.opencv_plugin;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.util.Log;

import org.opencv.android.Utils;
import org.opencv.core.Core;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.MatOfRect;
import org.opencv.core.Point;
import org.opencv.core.Rect;
import org.opencv.core.Size;
import org.opencv.imgproc.Imgproc;

import java.util.List;


public class MatchingUtil {

    public static void match(Bitmap inFile, Bitmap detectFile, boolean useBinary, int threshold) {
        Bitmap.Config config = inFile.getConfig();
        Bitmap formatSrcImg = inFile;
        if (config != Bitmap.Config.ARGB_8888 || config != Bitmap.Config.RGB_565) {
            formatSrcImg = Bitmap.createBitmap(inFile.getWidth(), inFile.getHeight(), Bitmap.Config.ARGB_8888);
            Canvas canvas = new Canvas(formatSrcImg);
            canvas.drawBitmap(inFile, 0, 0, null);
        }
        Mat sourceImg = new Mat();
        Utils.bitmapToMat(formatSrcImg, sourceImg);

        Point pointLeftTop = new Point(251 * sourceImg.cols() / 2368, 659 *  sourceImg.rows() / 1080);
        Point pointRightBottom = new Point(1970 * sourceImg.cols() / 2368, 800 * sourceImg.rows() / 1080);
        Rect regionRect = new Rect(pointLeftTop, pointRightBottom);

        Mat croppedSrc = new Mat(sourceImg, regionRect);

        Mat detectImg = new Mat();
        Utils.bitmapToMat(detectFile, detectImg);

        Mat scaleDetect = new Mat();
        Size newSize = new Size(detectImg.cols() * sourceImg.cols() / 2368, detectImg.rows() * sourceImg.rows() / 1080);
        Imgproc.resize(detectImg, scaleDetect, newSize);

//        return pyramidMatch(sourceImg, detectImg,(float)threshold / 100.f);
//        allMatch(sourceImg, detectImg, (float)threshold / 100.f);
        allMatch2(croppedSrc, scaleDetect, useBinary, (float)threshold / 100.f);
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
            return new OpenCvDetectModel((int)point.x, (int)point.y, detectImg.cols(), detectImg.rows());
        }
        //RuntimeLog.log("MatchingUtil","false math use "+(System.currentTimeMillis() - c)+"ms");
        return null;
    }

    private static void allMatch1(Mat src, Mat template, float threshold) {
        TemplateMatching.getAllMatch1(src, template, threshold, TemplateMatching.MATCHING_METHOD_DEFAULT);
    }

    private static void allMatch2(Mat src, Mat template, boolean useBinary, float threshold) {
        TemplateMatching.getAllMatch2(src, template, useBinary, threshold, TemplateMatching.MATCHING_METHOD_DEFAULT);
    }
}