package com.flutter.yolo.opencv_plugin;

import android.graphics.Bitmap;
import android.os.Environment;

import org.opencv.android.Utils;
import org.opencv.core.Mat;
import org.opencv.core.Point;
import org.opencv.core.Rect;
import org.opencv.imgcodecs.Imgcodecs;
import org.opencv.imgproc.Imgproc;

public class CropTemplate {
    public static void crop(Bitmap sourceBitmap, String outPutName, int xLTop, int yLTop, int xRBottom, int yRBottom) {
        Mat sourceMat = new Mat();
        Utils.bitmapToMat(sourceBitmap, sourceMat);

        Point pointLeftTop = new Point(125 * sourceMat.cols() / 1184, 339 *  sourceMat.rows() / 540);
        Point pointRightBottom = new Point(985 * sourceMat.cols() / 1184, 400 * sourceMat.rows() / 540);
        Rect regionRect = new Rect(pointLeftTop, pointRightBottom);

        Mat croppedSourceMat = new Mat(sourceMat, regionRect);

        Point tempLeftTop = new Point(xLTop, yLTop);
        Point tempRightBottom = new Point(xRBottom, yRBottom);
        Rect tempRect = new Rect(tempLeftTop, tempRightBottom);

        Mat croppedResult = new Mat(croppedSourceMat, tempRect);
        Bitmap resultMaxBitmap = matToBitmap(croppedResult);
        String pathTemporary = OpencvPlugin.activityContext.getExternalFilesDir(Environment.DIRECTORY_DCIM).getPath() + outPutName;
        Mat rgbResult = new Mat();
        Imgproc.cvtColor(croppedResult, rgbResult, Imgproc.COLOR_BGR2RGB);
        Imgcodecs.imwrite(pathTemporary, rgbResult);

        ImageUtils.recycle(sourceBitmap);
        ImageUtils.recycle(resultMaxBitmap);
    }

    public static Bitmap matToBitmap(Mat mat) {
        Bitmap bitmap = Bitmap.createBitmap(mat.cols(), mat.rows(), Bitmap.Config.ARGB_8888);
        Utils.matToBitmap(mat, bitmap);
        return bitmap;
    }
}
