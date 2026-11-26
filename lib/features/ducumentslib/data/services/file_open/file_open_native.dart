import 'dart:io';
import 'dart:typed_data';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

Future<void> openDownloadedDocument(
  Uint8List bytes,
  String filename,
  String contentType,
) async {
  final safeName = filename.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  final directory = await getTemporaryDirectory();
  final file = File(
    '${directory.path}/multiasso_${DateTime.now().microsecondsSinceEpoch}_$safeName',
  );
  await file.writeAsBytes(bytes, flush: true);
  final result = await OpenFilex.open(file.path, type: contentType);
  if (result.type != ResultType.done) throw StateError(result.message);
}
