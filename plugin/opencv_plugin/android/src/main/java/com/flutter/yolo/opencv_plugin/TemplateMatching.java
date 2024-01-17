package com.flutter.yolo.opencv_plugin;

import android.graphics.Bitmap;
import android.os.Environment;
import android.util.Pair;
import android.util.TimingLogger;

import com.tencent.mars.xlog.Log;

import org.opencv.android.Utils;
import org.opencv.core.Core;
import org.opencv.core.CvException;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.Point;
import org.opencv.core.Rect;
import org.opencv.core.Scalar;
import org.opencv.core.Size;
import org.opencv.imgcodecs.Imgcodecs;
import org.opencv.imgproc.Imgproc;

import java.util.ArrayList;
import java.util.List;


/**
 * Created by Stardust on 2017/11/25.
 */

public class TemplateMatching {

    private static final String LOG_TAG = "TemplateMatching";

    public static final int MAX_LEVEL_AUTO = -1;
    public static final int MATCHING_METHOD_DEFAULT = Imgproc.TM_CCOEFF_NORMED;

    public static Point fastTemplateMatching(Mat img, Mat template, float threshold) {
        return fastTemplateMatching(img, template, MATCHING_METHOD_DEFAULT, 0.75f, threshold, MAX_LEVEL_AUTO);
    }

    private static void release(Mat mat){
        if (mat!=null){
            mat.release();
        }
    }

    /**
     * 采用图像金字塔算法快速找图
     *
     * @param img             图片
     * @param template        模板图片
     * @param matchMethod     匹配算法
     * @param weakThreshold   弱阈值。该值用于在每一轮模板匹配中检验是否继续匹配。如果相似度小于该值，则不再继续匹配。
     * @param strictThreshold 强阈值。该值用于检验最终匹配结果，以及在每一轮匹配中如果相似度大于该值则直接返回匹配结果。
     * @param maxLevel        图像金字塔的层数
     * @return
     */
    public static Point fastTemplateMatching(Mat img, Mat template, int matchMethod, float weakThreshold, float strictThreshold, int maxLevel) {
        TimingLogger logger = new TimingLogger(LOG_TAG, "fast_tm");
        if (maxLevel == MAX_LEVEL_AUTO) {
            //自动选取金字塔层数
            maxLevel = selectPyramidLevel(img, template);
            logger.addSplit("selectPyramidLevel:" + maxLevel);
        }
        //保存每一轮匹配到模板图片在原图片的位置
        Point p = null;
        Mat matchResult = null;
        double similarity = 0;
        boolean isFirstMatching = true;
        for (int level = maxLevel; level >= 0; level--) {
            //放缩图片
            Mat src = getPyramidDownAtLevel(img, level);
            Mat currentTemplate = getPyramidDownAtLevel(template, level);
            //如果在上一轮中没有匹配到图片，则考虑是否退出匹配
            if (p == null) {
                //如果不是第一次匹配，并且不满足shouldContinueMatching的条件，则直接退出匹配（返回null）
                if (!isFirstMatching && !shouldContinueMatching(level, maxLevel)) {
                    break;
                }
                release(matchResult);
                matchResult = matchTemplate(src, currentTemplate, matchMethod);
                if (matchResult != null){
                    Pair<Point, Double> bestMatched = getBestMatched(matchResult, matchMethod, weakThreshold);
                    p = bestMatched.first;
                    similarity = bestMatched.second;
                }
            } else {
                //根据上一轮的匹配点，计算本次匹配的区域
                Rect r = getROI(p, src, currentTemplate);
                release(matchResult);
                Mat m = new Mat(src, r);
                matchResult = matchTemplate(m, currentTemplate, matchMethod);
                if (matchResult != null) {
                    release(m);
                    Pair<Point, Double> bestMatched = getBestMatched(matchResult, matchMethod, weakThreshold);
                    //不满足弱阈值，返回null
                    if (bestMatched.second < weakThreshold) {
                        //    p = null;
                        //  break;
                    }
                    p = bestMatched.first;
                    similarity = bestMatched.second;
                    p.x += r.x;
                    p.y += r.y;
                }
            }
            if (src != img)
                release(src);
            if (currentTemplate != template)
                currentTemplate.release();
            //满足强阈值，返回当前结果
            if (similarity >= strictThreshold) {
                pyrUp(p, level);
                break;
            }
            logger.addSplit("level:" + level + " point:" + p);
            isFirstMatching = false;
        }
        logger.addSplit("result:" + p);
        logger.dumpToLog();
        if (similarity < strictThreshold) {
            return null;
        }
        return p;
    }


    private static Mat getPyramidDownAtLevel(Mat m, int level) {
        if (level == 0) {
            return m;
        }
        int cols = m.cols();
        int rows = m.rows();
        for (int i = 0; i < level; i++) {
            cols = (cols + 1) / 2;
            rows = (rows + 1) / 2;
        }
        Mat r = new Mat(rows, cols, m.type());
        Size size = new Size(cols, rows);
        try {
            Imgproc.resize(m, r, size);
        }catch (Exception e){
//            RuntimeLog.e("level:"+level+","+cols+"*"+rows+","+size);
            throw e;
        }
        return r;
    }

    private static void pyrUp(Point p, int level) {
        for (int i = 0; i < level; i++) {
            p.x *= 2;
            p.y *= 2;
        }
    }

    private static boolean shouldContinueMatching(int level, int maxLevel) {
        if (level == maxLevel && level != 0) {
            return true;
        }
        if (maxLevel <= 2) {
            return false;
        }
        return level == maxLevel - 1;
    }

    private static Rect getROI(Point p, Mat src, Mat currentTemplate) {
        int x = (int) (p.x * 2 - currentTemplate.cols() / 4);
        x = Math.max(0, x);
        int y = (int) (p.y * 2 - currentTemplate.rows() / 4);
        y = Math.max(0, y);
        int w = (int) (currentTemplate.cols() * 1.5);
        int h = (int) (currentTemplate.rows() * 1.5);
        if (x + w >= src.cols()) {
            w = src.cols() - x - 1;
        }
        if (y + h >= src.rows()) {
            h = src.rows() - y - 1;
        }
        return new Rect(x, y, w, h);
    }

    private static int selectPyramidLevel(Mat img, Mat template) {
        int minDim = min(img.rows(), img.cols(), template.rows(), template.cols());
        //这里选取16为图像缩小后的最小宽高，从而用log(2, minDim / 16)得到最多可以经过几次缩小。
        int maxLevel = (int) (Math.log(minDim / 16) / Math.log(2));
        if (maxLevel < 0) {
            return 0;
        }
        //上限为6
        return Math.min(6, maxLevel);
    }
    public static int min(int... ints) {
        int min = ints[0];
        for (int i = 1; i < ints.length; i++) {
            min = ints[i] < min ? ints[i] : min;
        }
        return min;
    }

    public static Mat matchTemplate(Mat img, Mat temp, int match_method) {
        int result_cols = img.cols() - temp.cols() + 1;
        int result_rows = img.rows() - temp.rows() + 1;
        if (result_cols <= 0){
            result_cols = 0;
        }
        if (result_rows <= 0){
            result_rows = 0;
        }
        Mat result = new Mat(result_rows, result_cols, CvType.CV_32FC1);
        try {
            Imgproc.matchTemplate(img, temp, result, match_method);
        }catch (CvException e){
            e.printStackTrace();
            return null;
        }
        return result;
    }

    public static Pair<Point, Double> getBestMatched(Mat tmResult, int matchMethod, float threshold) {
        TimingLogger logger = new TimingLogger(LOG_TAG, "best_matched_point");
        // FIXME: 2017/11/26 正交化?
        //   Core.normalize.css(tmResult, tmResult, 0, 1, Core.NORM_MINMAX, -1, new Mat());
        Core.MinMaxLocResult mmr = Core.minMaxLoc(tmResult);
        logger.addSplit("minMaxLoc");
        double value;
        Point pos;
        if (matchMethod == Imgproc.TM_SQDIFF || matchMethod == Imgproc.TM_SQDIFF_NORMED) {
            pos = mmr.minLoc;
            value = -mmr.minVal;
        } else {
            pos = mmr.maxLoc;
            value = mmr.maxVal;
        }
        logger.addSplit("value:" + value);
        logger.dumpToLog();
        return new Pair<>(pos, value);
    }

    public static ArrayList<Pair<Point, Double>> getAllMatch1(Mat src, Mat template, float threshold, int matchMethod) {
        ArrayList<Pair<Point, Double>> resultList = new ArrayList<>();
        // 获取匹配结果
        long before = System.currentTimeMillis();
        while(true) {
            double value;
            Point pos;

            Mat matchResult = matchTemplate(src, template, matchMethod);


            Core.MinMaxLocResult mmr = Core.minMaxLoc(matchResult);
            if (matchMethod == Imgproc.TM_SQDIFF || matchMethod == Imgproc.TM_SQDIFF_NORMED) {
                pos = mmr.minLoc;
                value = -mmr.minVal;
            } else {
                pos = mmr.maxLoc;
                value = mmr.maxVal;
            }
            if (value > threshold) {
                resultList.add(new Pair<>(pos, value));
                Imgproc.rectangle(src, new Rect((int)pos.x, (int)pos.y, template.cols(), template.rows()), new Scalar(0,0,0), -1);
            } else {
                break;
            }
        }
        long after = System.currentTimeMillis();
        Log.i("chenshengfa", "cost %d", after - before);
        return resultList;
    }


    public static ArrayList<Pair<Point, Double>> getAllMatch2(Mat src, Mat template, boolean useBinary, float threshold, int matchMethod) {
        Mat matchSource = src;
        Mat templateSource = template;
        if (useBinary) {
            Mat greyImage = new Mat();
            Mat greyTemplate = new Mat();
            Imgproc.cvtColor(src, greyImage, Imgproc.COLOR_BGR2GRAY);
            Imgproc.cvtColor(template, greyTemplate, Imgproc.COLOR_BGR2GRAY);;

            Mat binarySrc = new Mat();
            Mat binaryTemplate = new Mat();
            Imgproc.threshold(greyImage, binarySrc, 180, 255, Imgproc.THRESH_BINARY);
            Imgproc.threshold(greyTemplate, binaryTemplate, 180, 255, Imgproc.THRESH_BINARY);

            matchSource = binarySrc;
            templateSource = binaryTemplate;
        } else {
//            Log.i("chenshengfa", "useBinary is false");
        }
//        Bitmap srcBitmap = matToBitmap(matchSource);
//        Bitmap templateBitmap = matToBitmap(templateSource);
        ArrayList<Pair<Point, Double>> resultList = new ArrayList<>();
        // 创建匹配结果
        int resultWidth = matchSource.cols() - templateSource.cols() + 1;
        int resultHeight = matchSource.rows() - templateSource.rows() + 1;
//        Mat result = new Mat(resultHeight, resultWidth, CvType.CV_32FC1);
        Mat result = new Mat(resultHeight, resultWidth, CvType.CV_8UC1);

        // 进行模板匹配
        long before = System.currentTimeMillis();
        Imgproc.matchTemplate(matchSource, templateSource, result, Imgproc.TM_CCOEFF_NORMED);
        Core.MinMaxLocResult mmr = Core.minMaxLoc(result);
        double maxValue = mmr.maxVal;
        if (maxValue < threshold) {
            return resultList;
        }
//        long after1 = System.currentTimeMillis();
//        Log.i("chenshengfa", "detect cost %d", after1 - before);

        // 遍历二值化结果，获取匹配位置
        for (int row = 0; row < result.rows(); row++) {
            for (int col = 0; col < result.cols(); col++) {
                double value = result.get(row, col)[0];
                if (value > threshold) {

                    // 过滤重复区域
                    Point currentPoint = new Point(col, row);
                    boolean isDuplicate = false;
                    for (Pair<Point, Double> existingPoint : resultList) {
                        double xDistance = Math.abs(currentPoint.x - existingPoint.first.x);
                        double yDistance = Math.abs(currentPoint.y - existingPoint.first.y);
                        if (xDistance < 50 && yDistance < 50) {
                            isDuplicate = true;
                            if (value > existingPoint.second) {
                                resultList.remove(existingPoint);
                                resultList.add(new Pair<>(currentPoint, value));
                            }
                            break;
                        }
                    }
                    if (!isDuplicate) {
                        resultList.add(new Pair<>(currentPoint, value));
                    }
                }
            }
        }
//        long after2 = System.currentTimeMillis();
//        Log.i("chenshengfa", "result cost %d", after2 - after1);
//        Log.i("chenshengfa", "res %d", resultList.size());
//        for(int i = 0; i < resultList.size(); i++) {
//            Imgproc.rectangle(src, resultList.get(i).first,
//                    new Point(resultList.get(i).first.x + templateSource.cols(), resultList.get(i).first.y + templateSource.rows()),
//                    new Scalar(0, 0, 255), 2);
//        }

//        Bitmap resultBitmap = matToBitmap(src);
//        if (resultList.size() == 0) {
//            Imgproc.rectangle(src, mmr.maxLoc,
//                    new Point(mmr.maxLoc.x + binaryTemplate.cols(), mmr.maxLoc.y + binaryTemplate.rows()),
//                    new Scalar(0, 0, 255), 2);
//        }

        return resultList;
    }

    public static Bitmap matToBitmap(Mat mat) {
        Bitmap bitmap = Bitmap.createBitmap(mat.cols(), mat.rows(), Bitmap.Config.ARGB_8888);
        Utils.matToBitmap(mat, bitmap);
        return bitmap;
    }


}