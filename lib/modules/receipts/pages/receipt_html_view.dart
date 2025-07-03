import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_whatsapp/share_whatsapp.dart';
import 'package:webshop/core/localization/app_localizations.dart';
import 'package:webshop/core/utils/format_utils.dart';
import 'package:webshop/modules/receipts/models/receipt_data.dart';
import 'package:webshop/modules/settings/models/company_profile.dart';
import 'package:webshop/shared/widgets/app_bar.dart';

class ReceiptHtmlView extends StatefulWidget {
  final ReceiptData receipt;
  final CompanyProfile company;

  const ReceiptHtmlView({
    super.key,
    required this.receipt,
    required this.company,
  });

  @override
  State<ReceiptHtmlView> createState() => _ReceiptHtmlViewState();
}

class _ReceiptHtmlViewState extends State<ReceiptHtmlView> {
  String? _pdfPath;

  @override
  void initState() {
    super.initState();
    _generatePdfFile();
  }

  Future<void> _generatePdfFile() async {
    final bytes = await _buildPdf(widget.receipt, widget.company);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/receipt_${widget.receipt.receiptNumber}.pdf');
    await file.writeAsBytes(bytes);
    setState(() => _pdfPath = file.path);
  }

  Future<Uint8List> _buildPdf(ReceiptData receipt, CompanyProfile company) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.courierPrimeBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(5),
            child: pw.DefaultTextStyle(
              style: pw.TextStyle(font: font, fontSize: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(child: pw.Text('*** START OF LEGAL RECEIPT ***', style: const pw.TextStyle(fontSize: 10))),
                  pw.SizedBox(height: 5),
                  pw.Center(
                    child: pw.Column(children: [
                      pw.Text(company.name, style: const pw.TextStyle(fontSize: 12)),
                      pw.Text(company.address1),
                      pw.Text('MOBILE: ${company.mobile}'),
                      pw.Text('TIN: ${company.tin}'),
                      pw.Text('VRN: ${company.vrn}'),
                      pw.Text('SERIAL NO: ${company.serial}'),
                      pw.Text('TAX OFFICE: ${company.taxoffice}'),
                    ]),
                  ),
                  pw.Divider(),
                  pw.Text('CUSTOMER NAME: ${receipt.customerName}'),
                  _row('CUSTOMER ID TYPE:', receipt.customerIdType),
                  _row('CUSTOMER ID:', receipt.customerIdNumber),
                  _row('CUSTOMER MOBILE:', receipt.customerMobile),
                  pw.Divider(),
                  _row('RECEIPT NUMBER:', receipt.receiptNumber),
                  _row('Z NUMBER:', receipt.zNumber),
                  _row('RECEIPT DATE:', receipt.receiptDate),
                  _row('RECEIPT TIME:', receipt.receiptTime),
                  pw.Divider(),
                  pw.Center(child: pw.Text('PURCHASED ITEMS')),
                  pw.SizedBox(height: 4),
                  pw.Column(
                    children: receipt.items.map((item) {
                      return pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(item.itemDescription),
                          _row('Qty: ${item.itemQuantity}', FormatUtils.formatCurrency(item.amount)),
                          pw.SizedBox(height: 2),
                        ],
                      );
                    }).toList(),
                  ),
                  pw.Divider(),
                  _row('TOTAL EXCL OF TAX:', FormatUtils.formatCurrency(receipt.totalExclOfTax)),
                  _row('DISCOUNT:', FormatUtils.formatCurrency(receipt.discount)),
                  _row('TOTAL TAX:', FormatUtils.formatCurrency(receipt.totalTax)),
                  _row('TOTAL INCL OF TAX:', FormatUtils.formatCurrency(receipt.totalInclOfTax)),
                  pw.Divider(),
                  pw.Center(child: pw.Text('RECEIPT VERIFICATION CODE:')),
                  pw.Center(child: pw.Text(receipt.verificationCode, style: const pw.TextStyle(fontSize: 8))),
                  pw.SizedBox(height: 8),
                  pw.Center(
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: receipt.verificationLink,
                      width: 100,
                      height: 100,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Center(child: pw.Text('*** END OF LEGAL RECEIPT ***')),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _row(String left, String right) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(left),
        pw.Text(right),
      ],
    );
  }

  Future<void> _shareToWhatsApp(WhatsApp type) async {
    if (_pdfPath != null) {
      final file = XFile(_pdfPath!);
      await shareWhatsapp.share(type: type, file: file);
    }
  }

  Future<void> _shareToOtherApps() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = File(_pdfPath!);
      final bytes = await file.readAsBytes();

      final tempDir = await getTemporaryDirectory();
      final tempFile =
          File('${tempDir.path}/Receipt_${widget.receipt.receiptNumber}.pdf');
      await tempFile.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'Here is your receipt',
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error sharing file: ${e.toString()}')),
      );
    }
  }

  Future<void> _showShareOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LineAwesomeIcons.minus_solid, color: Colors.grey[600]),
              const SizedBox(height: 8),
              Text('Share Receipt',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              ListTile(
                leading: SvgPicture.asset('assets/images/whatsapp-icon.svg',
                    width: 32),
                title: const Text('WhatsApp'),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareToWhatsApp(WhatsApp.standard);
                },
              ),
              ListTile(
                leading: SvgPicture.asset('assets/images/whatsapp-business.svg',
                    width: 32),
                title: const Text('WhatsApp Business'),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareToWhatsApp(WhatsApp.business);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Other Apps'),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareToOtherApps();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: WebshopAppBar(
        title: loc?.translate('receipts.preview_title') ?? 'Receipt Preview',
        onRefresh: () {},
        actions: [
          if (_pdfPath != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _showShareOptions,
            ),
        ],
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.print),
          label: const Text("Print or Preview Receipt"),
          onPressed: () async {
            final pdfBytes = await _buildPdf(widget.receipt, widget.company);
            await Printing.layoutPdf(
              onLayout: (format) async => pdfBytes,
            );
          },
        ),
      ),
    );
  }
}










