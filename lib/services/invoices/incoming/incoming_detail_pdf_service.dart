import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:gizmoglobe_client/objects/invoice_related/incoming_invoice.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/functions/helper.dart';
import 'package:flutter/services.dart' show rootBundle;

class IncomingInvoicePdfService {
  static Future<pw.Document> generatePdf({
    required IncomingInvoice invoice,
    required Manufacturer? manufacturer,
    required Map<String, Product> products,
  }) async {
    // Load the NotoSans font
    final notoSansRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );
    final notoSansBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Theme(
            data: pw.ThemeData.withFont(
              base: notoSansRegular,
              bold: notoSansBold,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(notoSansRegular, notoSansBold),
                pw.SizedBox(height: 40),
                _buildCompanyInfo(manufacturer, notoSansRegular, notoSansBold),
                pw.SizedBox(height: 30),
                _buildInvoiceInfo(invoice, notoSansRegular, notoSansBold),
                pw.SizedBox(height: 20),
                _buildProductsTable(
                    invoice, products, notoSansRegular, notoSansBold),
                pw.SizedBox(height: 20),
                _buildFooter(invoice, notoSansRegular, notoSansBold),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader(pw.Font notoSansRegular, pw.Font notoSansBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: const pw.BoxDecoration(
        color: PdfColors.blue700,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'GIZMOGLOBE',
                style: pw.TextStyle(
                  font: notoSansBold,
                  color: PdfColors.white,
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Retailer Management System',
                style: pw.TextStyle(
                  font: notoSansRegular,
                  color: PdfColors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          pw.Text(
            'INCOMING INVOICE',
            style: pw.TextStyle(
              font: notoSansBold,
              color: PdfColors.white,
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCompanyInfo(Manufacturer? manufacturer,
      pw.Font notoSansRegular, pw.Font notoSansBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey400, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Manufacturer Information',
            style: pw.TextStyle(
              font: notoSansBold,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Name: ${manufacturer?.manufacturerName ?? 'Unknown'}',
            style: pw.TextStyle(font: notoSansRegular, fontSize: 12),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInvoiceInfo(
      IncomingInvoice invoice, pw.Font notoSansRegular, pw.Font notoSansBold) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Invoice ID:', invoice.incomingInvoiceID ?? 'N/A',
                notoSansBold, notoSansRegular),
            pw.SizedBox(height: 8),
            _buildInfoRow('Date:', dateFormat.format(invoice.date),
                notoSansBold, notoSansRegular),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            _buildInfoRow('Status:', invoice.status.getName().toUpperCase(),
                notoSansBold, notoSansRegular),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRow(
      String label, String value, pw.Font boldFont, pw.Font regularFont) {
    return pw.Row(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          value,
          style: pw.TextStyle(font: regularFont, fontSize: 12),
        ),
      ],
    );
  }

  static pw.Widget _buildProductsTable(
    IncomingInvoice invoice,
    Map<String, Product> products,
    pw.Font notoSansRegular,
    pw.Font notoSansBold,
  ) {
    final tableHeaders = [
      'Product',
      'Product ID',
      'Quantity',
      'Unit Price',
      'Subtotal'
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
      columnWidths: {
        0: const pw.FlexColumnWidth(3), // Product
        1: const pw.FlexColumnWidth(2), // Product ID
        2: const pw.FlexColumnWidth(1), // Quantity
        3: const pw.FlexColumnWidth(2), // Unit Price
        4: const pw.FlexColumnWidth(2), // Subtotal
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue700),
          children: tableHeaders.map((header) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                header,
                style: pw.TextStyle(
                  font: notoSansBold,
                  color: PdfColors.white,
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
        // Data rows
        ...invoice.details.map((detail) {
          final product = products[detail.productID];
          final unitPrice = detail.importPrice;
          final subtotal = unitPrice * detail.quantity;

          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  product?.productName ?? 'N/A',
                  style: pw.TextStyle(font: notoSansRegular, fontSize: 10),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  detail.productID,
                  style: pw.TextStyle(font: notoSansRegular, fontSize: 10),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '${detail.quantity}',
                  style: pw.TextStyle(font: notoSansRegular, fontSize: 10),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  Helper.toCurrencyFormat(unitPrice),
                  style: pw.TextStyle(font: notoSansRegular, fontSize: 10),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  Helper.toCurrencyFormat(subtotal),
                  style: pw.TextStyle(font: notoSansRegular, fontSize: 10),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildFooter(
    IncomingInvoice invoice,
    pw.Font notoSansRegular,
    pw.Font notoSansBold,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.blue300, width: 2),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'TOTAL AMOUNT:',
            style: pw.TextStyle(
              font: notoSansBold,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.Text(
            Helper.toCurrencyFormat(invoice.totalPrice),
            style: pw.TextStyle(
              font: notoSansBold,
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
        ],
      ),
    );
  }
}
