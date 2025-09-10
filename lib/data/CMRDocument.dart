import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

String formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

class CMRDocument {
  final String sender;
  final String consignee;
  final String carrier;
  final String vehicleNumber;
  final String cargoDescription;
  final double weight;
  final String origin;
  final String destination;
  final DateTime date;

  CMRDocument({
    required this.sender,
    required this.consignee,
    required this.carrier,
    required this.vehicleNumber,
    required this.cargoDescription,
    required this.weight,
    required this.origin,
    required this.destination,
    required this.date,
  });

  pw.Document toPdf() {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Container(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('CMR International Consignment Note', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text('Sender: $sender'),
              pw.Text('Consignee: $consignee'),
              pw.Text('Carrier: $carrier'),
              pw.Text('Vehicle Number: $vehicleNumber'),
              pw.SizedBox(height: 10),
              pw.Text('Cargo Description:'),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Text(cargoDescription),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Weight: ${weight.toStringAsFixed(2)} kg'),
              pw.Text('Origin: $origin'),
              pw.Text('Destination: $destination'),
              pw.Text('Date: ${formatDate(date)}'),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(children: [pw.Text('Sender Signature:'), pw.SizedBox(height: 40), pw.Text('_____________________')]),
                  pw.Column(children: [pw.Text('Carrier Signature:'), pw.SizedBox(height: 40), pw.Text('_____________________')]),
                  pw.Column(children: [pw.Text('Receiver Signature:'), pw.SizedBox(height: 40), pw.Text('_____________________')]),
                ],
              )
            ],
          ),
        ),
      ),
    );

    return doc;
  }
}