import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class FileDownloader {
  Future<String> downloadFileLocally(Response response, String fileName) async {
    final directory = await _getStorageDirectory();

    final fullPath = '${directory!.path}/Wbxpress';
    _createDirectory(fullPath);

    final bytes = _getBytesFromResponse(response);

    const fileType = 'pdf'; // Replace 'pdf' with your desired file type
    final path = '$fullPath/$fileType-$fileName.$fileType'; // Proper file path

    _saveFile(path, bytes);
    return path;
  }

  Future<Directory?> _getStorageDirectory() async {
    return Platform.isAndroid
        ? Directory('/storage/emulated/0/Download')
        : await getApplicationDocumentsDirectory();
  }

  void _createDirectory(String fullPath) {
    Directory(fullPath).createSync(recursive: true);
  }

  Uint8List _getBytesFromResponse(Response response) {
    final intList = response.bodyBytes;
    return Uint8List.fromList(intList);
  }

  void _saveFile(String path, Uint8List bytes) async {
    final file = File(path);

    try {
      await file.writeAsBytes(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
      print('File downloaded successfully at: $path');
      
    } on FileSystemException catch (err) {
      print('Error while writing file: $err');
      // Handle the error accordingly
    }
  }
}
