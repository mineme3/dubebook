import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/customer.dart';
import '../models/app_transaction.dart';

class ReportService {
  static Future<void> generateCustomerReport(Customer customer, List<AppTransaction> transactions) async {
    final pdf = pw.Document();

    double totalDebt = 0.0;
    double totalPaid = 0.0;
    for (var tx in transactions) {
      if (tx.transactionType == 'debt' && tx.status == 0) {
        totalDebt += tx.total;
      } else if (tx.status == 1) {
        totalPaid += tx.total;
      }
    }
    final remaining = totalDebt - totalPaid;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "DUBE BOOK STATEMENT",
                          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text("Credit & Payment History Summary", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                      ],
                    ),
                    pw.Text(
                      DateTime.now().toLocal().toString().substring(0, 10),
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 16),

                // Customer Details
                pw.Text("STATEMENT FOR:", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                pw.SizedBox(height: 4),
                pw.Text(customer.name, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                if (customer.email != null) pw.Text("Email: ${customer.email}", style: const pw.TextStyle(fontSize: 10)),
                if (customer.phone != null) pw.Text("Phone: ${customer.phone}", style: const pw.TextStyle(fontSize: 10)),
                
                pw.SizedBox(height: 24),

                // Financial Cards
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard("Total Credit Added", "${totalDebt.toStringAsFixed(2)} ETB", PdfColors.red800),
                    _buildSummaryCard("Total Amount Settled", "${totalPaid.toStringAsFixed(2)} ETB", PdfColors.green800),
                    _buildSummaryCard("Remaining Outstanding", "${remaining.toStringAsFixed(2)} ETB", PdfColors.blueGrey800),
                  ],
                ),

                pw.SizedBox(height: 32),
                pw.Text("TRANSACTION LOGS", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
                pw.SizedBox(height: 8),

                // Table
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                  cellHeight: 25,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.center,
                    2: pw.Alignment.centerRight,
                    3: pw.Alignment.center,
                    4: pw.Alignment.center,
                  },
                  headers: ['Item Name', 'Type', 'Amount', 'Date', 'Status'],
                  data: transactions.map((t) {
                    return [
                      t.itemName,
                      t.transactionType.toUpperCase(),
                      "${t.total.toStringAsFixed(2)} ETB",
                      t.date.toString().substring(0, 10),
                      t.status == 1 ? 'PAID' : 'UNPAID',
                    ];
                  }).toList(),
                ),

                pw.Spacer(),
                pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Text("Thank you for using Dube Book! Generated securely from mobile client.", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                )
              ],
            ),
          );
        },
      ),
    );

    // Show PDF print / preview dialog directly
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _buildSummaryCard(String title, String value, PdfColor color) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
