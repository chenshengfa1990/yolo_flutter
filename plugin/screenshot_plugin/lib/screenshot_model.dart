
class ScreenshotModel {
  late String filePath;
  late int width;
  late int height;

  ScreenshotModel(this.filePath, this.width, this.height);

  ScreenshotModel.fromJson(Map<String, dynamic> json)
      : filePath = json['filePath'],
        width = json['width'],
        height = json['height'];
}