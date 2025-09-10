import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class FileSaver {
  // Удаляем жёстко прописанные заголовки, чтобы использовать кастомные
  // static const List<String> tableHeaders = [ ... ];

  static String _ensureExtension(String fileName, String ext) {
    if (!fileName.toLowerCase().endsWith(ext)) {
      return '$fileName$ext';
    }
    return fileName;
  }

  static Future<String> saveToExcel(
    List<List<dynamic>> data,
    String fileName,
    List<String> headers, // Добавляем кастомные заголовки
  ) async {
    fileName = _ensureExtension(fileName, '.xlsx');
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Используем переданные заголовки
    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    for (int i = 0; i < data.length; i++) {
      sheet.appendRow(
        data[i].map((e) => TextCellValue(e.toString())).toList(),
      );
    }

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    await file.create(recursive: true);
    await file.writeAsBytes(excel.encode()!);
    return filePath;
  }

  static Future<String> saveToPDF(
    List<List<dynamic>> data,
    String fileName,
    List<String> headers, // Добавляем кастомные заголовки
  ) async {
    fileName = _ensureExtension(fileName, '.pdf');
    final pdf = pw.Document();

    // Используем шрифт с поддержкой кириллицы (например, Roboto)
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );

    // Добавляем кастомные заголовки
    final tableData = [headers, ...data.map((row) => row.map((e) => e.toString()).toList())];
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Table.fromTextArray(
          data: tableData,
          cellStyle: pw.TextStyle(font: font),
          headerStyle: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    await file.create(recursive: true);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  static Future<void> exportAndShare({
    required List<List<dynamic>> data,
    required String type, // 'excel', 'pdf'
    required List<String> headers, // Добавляем кастомные заголовки
    String fileName = 'export',
  }) async {
    String filePath = '';
    if (type == 'excel') {
      filePath = await saveToExcel(data, fileName, headers);
    } else if (type == 'pdf') {
      filePath = await saveToPDF(data, fileName, headers);
    }
    if (await File(filePath).exists()) {
      await Share.shareXFiles([XFile(filePath)], text: 'Поделиться файлом');
    } else {
      throw Exception('Файл не создан');
    }
  }
}