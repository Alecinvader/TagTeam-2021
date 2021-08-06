import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tagteamprod/server/errors/error_handler.dart';

class StorageUtility {
  Future<String> uploadFile(String filePath, String refParent, ErrorHandler handler) async {
    File file = File(filePath);
    String fileRefPath = '';
    String fileName = file.path.split('/').last;

    try {
      await FirebaseStorage.instance.ref(refParent).child('$fileName').putFile(file).then((data) {
        fileRefPath = data.ref.fullPath;
      });
    } on FirebaseException catch (e) {
      handler.onError(e);
      throw e;
    }

    return fileRefPath;
  }

  Future<String?> getImageURL(String? imageRef, ErrorHandler handler) async {
    String? downloadURL;
    if (imageRef != null) {
      try {
        downloadURL = await FirebaseStorage.instance.ref(imageRef).getDownloadURL();
      } on FirebaseException catch (e) {
        throw e;
      } catch (e) {
        throw e;
      }
    }

    return downloadURL;
    // Within your widgets:
    // Image.network(downloadURL);
  }

  Future<String> getImagePath(ErrorHandler handler) async {
    final picker = ImagePicker();
    XFile? pickedFile;

    try {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
    } catch (error) {
      handler.onError(error);
      throw error;
    }

    if (pickedFile != null) {
      return pickedFile.path;
    } else {
      return '';
    }
  }
}
