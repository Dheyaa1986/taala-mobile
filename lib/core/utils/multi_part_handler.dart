import 'package:dio/dio.dart';

class ImageMultiPartHandler {
  static Future<MultipartFile> getMediaMultiPartFilesFromFile(String path) async {
    return await MultipartFile.fromFile(path, filename: path.split('/').last);
  }
}
