import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

Future<String?> pickAndUploadImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile == null) return null;

  final file = File(pickedFile.path);
  final fileName = path.basename(file.path);

  final storageRef =
      FirebaseStorage.instance.ref().child('item_images/$fileName');

  final uploadTask = await storageRef.putFile(file);
  final downloadUrl = await uploadTask.ref.getDownloadURL();

  return downloadUrl;
}
