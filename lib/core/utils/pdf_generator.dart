import 'dart:io';
import 'package:flutter_html_to_pdf_updated/flutter_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';

class PdfGenerator {
  static Future<String?> generatePdf({
    required String htmlContent,
    required String fileName,
  }) async {
    try {
      final appDocDir = await _getStorageDirectory();
      if (appDocDir != null) {
        final targetPath = appDocDir.path;
        final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
          htmlContent,
          targetPath,
          fileName,
        );
        return generatedPdfFile.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Directory?> _getStorageDirectory() async {
    if (Platform.isAndroid) {
      return await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    }
    return null;
  }
}