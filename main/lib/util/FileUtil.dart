

class FileUtil {
  static String getFileName(String? filePath) {
    if (filePath?.isEmpty ?? true) {
      return '';
    }
    return filePath!.substring(filePath.lastIndexOf('/') + 1);
  }
}