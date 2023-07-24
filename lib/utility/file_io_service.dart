// File IO service using Shared Storage. Currently only for Android

import 'dart:typed_data';

import 'package:shared_storage/shared_storage.dart';
import 'package:tuple/tuple.dart';

class FileIOService {
  static FileIOService instance = FileIOService();

  Future<bool> saveToFile({required String fileName, required Uint8List bytes, String? mime, String? dialogTitle}) async {
    Uri? uri = await openDocumentTree();
    if (uri == null) return false;

    createFileAsBytes(
      uri,
      mimeType: mime ?? 'application/octet-stream',
      displayName: fileName,
      bytes: bytes,
    );

    return true;
  }

  Future<Tuple2<String, Uint8List>?> loadFile({String? allowedExtension}) async {
    Uri? uri = (await openDocument())?.first;
    if (uri == null) return null;

    Uint8List? result = await getDocumentContent(uri);
    List<String> filename = uri.pathSegments.last.split("/").last.split(".");
    if (filename.length >= 2) filename.removeLast();

    return result != null ? Tuple2(filename.join("."), result) : null;
  }
}