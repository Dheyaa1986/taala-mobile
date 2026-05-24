import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
class ImageMultiPartHandler{

  // static Future<MultipartFile>? getMediaMultiPartFilesFromCroppedfile(CroppedFile? image) async {
  //   String path = image?.path??'';
  //   return await MultipartFile.fromFile(path, filename: path.split('/').last);
  // }
  static Future<MultipartFile> getMediaMultiPartFilesFromFile(String path) async {

    return await MultipartFile.fromFile(path, filename: path.split('/').last);
  }
/*  static Future<MultipartFile>? getMediaMultiPartFilesFromBytes(CroppedFile? image) async {
    var result = await FlutterImageCompress.compressWithFile(
      image?.path??'',
      quality: 95,

    );
    String path=image?.path??'';
    MultipartFile? file;
    result==null?{
      file= await MultipartFile.fromFile(path, filename: path.split('/').last),
    }:{
      file=  MultipartFile.fromBytes(result.toList(),  filename: path.split('/').last),
    };
    return file;
    // Uint8List bytes=await image?.readAsBytes()??Uint8List(0);

  }*/
}