# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

#指定代码的压缩级别
-optimizationpasses 5

#包名不混合大小写
-dontusemixedcaseclassnames

#不去忽略非公共的库类
-dontskipnonpubliclibraryclasses

 #优化 不优化输入的类文件
-dontoptimize

 #预校验
-dontpreverify

#忽略警告
-ignorewarnings

 #混淆时是否记录日志
-verbose
#保护注解
-keepattributes *Annotation*
# 指定混淆是采用的算法，后面的参数是一个过滤器
# 这个过滤器是谷歌推荐的算法，一般不做更改
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
# 避免混淆泛型, 这在JSON实体映射时非常重要
-keepattributes Signature

-keep class com.flutter.yolo.ncnn_plugin.** {*;}
-keep class com.tencent.mars.** {*;}

# 保留opencv下的所有类及其内部类
-keep class org.opencv.** {*;}
-keep class org.opencv.* {}
#tencent
-keep class com.tencent.mm.sdk.** {
     *;
}

#oss
-keep class com.alibaba.sdk.android.oss.** { *; }
-dontwarn okio.**
-dontwarn org.apache.commons.codec.binary.**