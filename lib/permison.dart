import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  if (await Permission.storage.request().isGranted) {
    print('Storage permission granted.');
  } else {
    print('Storage permission denied.');
  }

  if (await Permission.camera.request().isGranted) {
    print('Camera permission granted.');
  } else {
    print('Camera permission denied.');
  }
}
