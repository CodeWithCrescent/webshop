import 'dart:io';
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
import 'package:webshop/core/utils/helpers.dart';
import 'package:webshop/modules/receipts/models/receipt_data.dart';
import 'package:webshop/modules/settings/models/business_profile.dart';
import 'package:webshop/shared/widgets/app_bar.dart';

class ReceiptHtmlView extends StatefulWidget {
  final ReceiptData receipt;
  final BusinessProfile business;
  const ReceiptHtmlView({
    super.key,
    required this.receipt,
    required this.business,
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
    final bytes = await _buildPdf(widget.receipt, widget.business);
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/receipt_${parseString(widget.receipt.receiptNumber)}.pdf');
    await file.writeAsBytes(bytes);
    if (mounted) {
      setState(() => _pdfPath = file.path);
    }
  }

  Future<Uint8List> _buildPdf(
      ReceiptData receipt, BusinessProfile business) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.courierPrimeBold();
    final ByteData imageData = await rootBundle.load('assets/images/tra.png');
    final Uint8List imageBytes = imageData.buffer.asUint8List();
    final pw.ImageProvider imageProvider = pw.MemoryImage(imageBytes);
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) {
          return pw.Stack(
            children: [
              // Background watermark
              pw.Positioned.fill(
                child: pw.Transform.rotate(
                  angle: 0.5,
                  child: pw.Opacity(
                    opacity: 0.6,
                    child: pw.Center(
                      // alignment: const pw.Alignment(-5, 5),
                      child: pw.Text(
                        'WebSHOP DEMO',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 40,
                          color: PdfColors.grey400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.DefaultTextStyle(
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Center(
                          child: pw.Text('*** START OF LEGAL RECEIPT ***',
                              style: const pw.TextStyle(fontSize: 10))),
                      pw.SizedBox(height: 5),
                      pw.Center(
                        child: pw.Column(children: [
                          pw.SizedBox(height: 10),
                          pw.Image(imageProvider, width: 40),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            business.name,
                            style: const pw.TextStyle(fontSize: 14),
                            overflow: pw.TextOverflow.span,
                          ),
                          pw.Text(
                            business.address2,
                            overflow: pw.TextOverflow.span,
                          ),
                          pw.Text('MOBILE: ${business.mobile}'),
                          pw.Text('TIN: ${business.tin}'),
                          pw.Text('VRN: ${business.vrn}'),
                          pw.Text('SERIAL NUMBER: ${business.serial}'),
                          pw.Text('VIN: ${business.vin}',
                              overflow: pw.TextOverflow.span),
                          pw.Text(
                            'TAX OFFICE: ${business.taxoffice}',
                            overflow: pw.TextOverflow.span,
                          ),
                        ]),
                      ),
                      pw.Divider(borderStyle: pw.BorderStyle.dotted),
                      pw.Text(
                          'CUSTOMER NAME: ${parseString(receipt.customerName)}'),
                      _row('CUSTOMER ID TYPE:',
                          parseString(receipt.customerIdType)),
                      _row('CUSTOMER ID:',
                          parseString(receipt.customerIdNumber)),
                      _row('CUSTOMER MOBILE:',
                          parseString(receipt.customerMobile)),
                      pw.Divider(borderStyle: pw.BorderStyle.dotted),
                      _row('RECEIPT NUMBER:',
                          parseString(receipt.receiptNumber)),
                      _row('Z NUMBER:', parseString(receipt.zNumber)),
                      _row('RECEIPT DATE:', parseString(receipt.receiptDate)),
                      _row('RECEIPT TIME:', parseString(receipt.receiptTime)),
                      pw.SizedBox(height: 8),
                      pw.Divider(thickness: 0.1),
                      pw.Center(child: pw.Text('PURCHASED ITEMS')),
                      pw.SizedBox(height: 4),
                      pw.Table(
                        border: const pw.TableBorder(
                          top: pw.BorderSide(width: 0.5),
                          bottom: pw.BorderSide(width: 0.5),
                          horizontalInside: pw.BorderSide(width: 0.3),
                          left: pw.BorderSide.none,
                          right: pw.BorderSide.none,
                          verticalInside: pw.BorderSide.none,
                        ),
                        defaultVerticalAlignment:
                            pw.TableCellVerticalAlignment.middle,
                        columnWidths: {
                          0: const pw.FlexColumnWidth(4),
                          1: const pw.FlexColumnWidth(2),
                          2: const pw.FlexColumnWidth(3),
                        },
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(2),
                                child: pw.Text('DESCRIPTION'),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(2),
                                child: pw.Text('QTY'),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(2),
                                child: pw.Text('AMOUNT'),
                              ),
                            ],
                          ),
                          ...receipt.items.map((item) {
                            return pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(2),
                                  child: pw.Text(item.itemDescription),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(2),
                                  child: pw.Text(item.itemQuantity.toString()),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(2),
                                  child: pw.Text(
                                      FormatUtils.formatCurrency(item.amount)),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      _row(
                          'TOTAL EXC. TAX:',
                          FormatUtils.formatCurrency(
                              parseString(receipt.totalExclOfTax))),
                      _row(
                          'DISCOUNT:',
                          FormatUtils.formatCurrency(
                              parseString(receipt.discount))),
                      _row(
                          'TOTAL TAX:',
                          FormatUtils.formatCurrency(
                              parseString(receipt.totalTax))),
                      _row(
                          'TOTAL INC. TAX:',
                          FormatUtils.formatCurrency(
                              parseString(receipt.totalInclOfTax))),
                      pw.Divider(borderStyle: pw.BorderStyle.dotted),
                      pw.Center(child: pw.Text('RECEIPT VERIFICATION CODE')),
                      pw.Center(
                          child: pw.Text(parseString(receipt.verificationCode),
                              style: const pw.TextStyle(fontSize: 8))),
                      pw.SizedBox(height: 8),
                      pw.Center(
                        child: pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: parseString(receipt.verificationLink),
                          width: 80,
                          height: 80,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Center(
                          child: pw.Text('*** END OF LEGAL RECEIPT ***',
                              style: const pw.TextStyle(fontSize: 10))),
                    ],
                  ),
                ),
              ),
            ],
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
        pw.Text(
          right,
          overflow: pw.TextOverflow.span,
        ),
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
      final tempFile = File(
          '${tempDir.path}/Receipt_${parseString(widget.receipt.receiptNumber)}.pdf');
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
            final pdfBytes = await _buildPdf(widget.receipt, widget.business);
            await Printing.layoutPdf(
              onLayout: (format) async => pdfBytes,
            );
          },
        ),
      ),
    );
  }
}
