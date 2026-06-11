import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class ReportService {
  static Future<void> generateReport({
    required Map<String, dynamic> stats,
    required Map<String, dynamic> severity,
    required List<dynamic> threats,
    required List<dynamic> alerts,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final formattedDate = DateFormat('dd MMMM yyyy, hh:mm a').format(now);

    // Load built-in font from printing package (no Unicode issues)
    final font = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        build: (context) => [

          // ── HEADER ──
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey800,
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Enterprise Security Report",
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.Text(
                  "CONFIDENTIAL",
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.red300,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // ── SECURITY SUMMARY ──
          pw.Text(
            "Security Summary",
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(),
          pw.SizedBox(height: 8),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _statBox("Total Threats", "${stats["threats"] ?? 0}", PdfColors.red),
              _statBox("Total Alerts", "${stats["alerts"] ?? 0}", PdfColors.orange),
              _statBox("High Risk Events", "${stats["high_risk"] ?? 0}", PdfColors.purple),
              _statBox("Users", "${stats["users"] ?? 0}", PdfColors.blue),
            ],
          ),

          pw.SizedBox(height: 24),

          // ── SEVERITY BREAKDOWN ──
          pw.Text(
            "Severity Breakdown",
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(),
          pw.SizedBox(height: 8),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _statBox("High", "${severity["high"] ?? 0}", PdfColors.red),
              _statBox("Medium", "${severity["medium"] ?? 0}", PdfColors.orange),
              _statBox("Low", "${severity["low"] ?? 0}", PdfColors.green),
            ],
          ),

          pw.SizedBox(height: 24),

          // ── LATEST THREAT INTELLIGENCE ──
          pw.Text(
            "Latest Threat Intelligence",
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(),
          pw.SizedBox(height: 8),

          if (threats.isEmpty)
            pw.Text("No threat intelligence available.")
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(4),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                // Table header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
                  children: [
                    _tableHeader("CVE ID"),
                    _tableHeader("Title"),
                    _tableHeader("Vendor"),
                    _tableHeader("Severity"),
                  ],
                ),
                // Table rows
                ...threats.take(10).map((threat) {
                  return pw.TableRow(
                    children: [
                      _tableCell(threat["cve"] ?? "-"),
                      _tableCell(threat["title"] ?? "-"),
                      _tableCell(threat["vendor"] ?? "-"),
                      _tableCellColored(
                        threat["severity"] ?? "-",
                        _severityColor(threat["severity"] ?? ""),
                      ),
                    ],
                  );
                }),
              ],
            ),

          pw.SizedBox(height: 24),

          // ── RECENT ALERTS ──
          pw.Text(
            "Recent Alerts",
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(),
          pw.SizedBox(height: 8),

          if (alerts.isEmpty)
            pw.Text("No recent alerts.")
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(5),
                1: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
                  children: [
                    _tableHeader("Message"),
                    _tableHeader("Severity"),
                  ],
                ),
                ...alerts.take(10).map((alert) {
                  return pw.TableRow(
                    children: [
                      _tableCell(alert["message"] ?? "-"),
                      _tableCellColored(
                        alert["severity"] ?? "-",
                        _severityColor(alert["severity"] ?? ""),
                      ),
                    ],
                  );
                }),
              ],
            ),

          pw.SizedBox(height: 32),

          // ── FOOTER ──
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "Generated by Enterprise Security Monitor",
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
              pw.Text(
                "Generated on: $formattedDate",
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  // ── HELPERS ──

  static pw.Widget _statBox(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
      ),
    );
  }

  static pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }

  static pw.Widget _tableCellColored(String text, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  static PdfColor _severityColor(String severity) {
    switch (severity.toUpperCase()) {
      case "HIGH":
      case "CRITICAL":
        return PdfColors.red;
      case "MEDIUM":
        return PdfColors.orange;
      default:
        return PdfColors.green;
    }
  }
}