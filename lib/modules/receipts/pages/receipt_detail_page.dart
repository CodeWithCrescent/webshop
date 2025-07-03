
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
  // Load the typewriter font
  late Future<pw.Font> _pdfFont;
  late Future<Uint8List> _logoBytes;
  late Future<Uint8List> _qrCodeBytes;

  @override
  void initState() {
    super.initState();
    _pdfFont = _loadPdfFont();
    _logoBytes = _loadLogoImage();
    _qrCodeBytes = _generateQrCodeImage();
  }

  Future<pw.Font> _loadPdfFont() async {
    final fontData = await rootBundle.load('assets/fonts/CourierPrime-Regular.ttf');
    return pw.Font.ttf(fontData);
  }

  Future<Uint8List> _loadLogoImage() async {
    final byteData = await rootBundle.load('assets/images/tra.png');
    return byteData.buffer.asUint8List();
  }

  Future<Uint8List> _generateQrCodeImage() async {
    final qrImage = await QrPainter(
      data: widget.receipt.verificationLink,
      version: QrVersions.auto,
      gapless: true,
    ).toImageData(200);
    return qrImage!.buffer.asUint8List();
  }

  Future<void> _shareToWhatsApp(WhatsApp type) async {
    final pdfFile = await _generatePdf();
    if (pdfFile != null) {
      await shareWhatsapp.share(type: type, file: XFile(pdfFile.path));
    }
  }

  Future<void> _shareToOtherApps() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final pdfFile = await _generatePdf();
      if (pdfFile != null) {
        await Share.shareXFiles(
          [XFile(pdfFile.path)],
          text: 'Here is your receipt',
        );
      }
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

  Future<File?> _generatePdf() async {
    try {
      final pdf = pw.Document();
      final font = await _pdfFont;
      final logo = await _logoBytes;
      final qrCode = await _qrCodeBytes;

      // Add receipt content to PDF
      pdf.addPage(
        pw.Page(
          theme: pw.ThemeData.withFont(base: font),
          build: (pw.Context context) {
            return _buildPdfReceipt(widget.receipt, widget.company, logo, qrCode);
          },
        ),
      );

      // Get directory
      final directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      if (directory == null) return null;

      // Create file
      final file = File(
          '${directory.path}/receipt_${widget.receipt.receiptNumber}.pdf');
      
      // Save PDF
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      return null;
    }
  }

  pw.Widget _buildPdfReceipt(
      ReceiptData receipt, CompanyProfile company, Uint8List logo, Uint8List qrCode) {
    return pw.Container(
      width: 400,
      padding: const pw.EdgeInsets.all(5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(
            child: pw.Text('*** START OF LEGAL RECEIPT ***',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
          ),
          pw.SizedBox(height: 10),
          
          // Company Info
          pw.Center(
            child: pw.Column(
              children: [
                pw.Image(pw.MemoryImage(logo), width: 65),
                pw.Text(company.name,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                pw.Text(company.address1),
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(text: 'MOBILE: ', 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.TextSpan(text: company.mobile),
                    ],
                  ),
                ),
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(text: 'TIN: ', 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.TextSpan(text: company.tin),
                    ],
                  ),
                ),
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(text: 'VRN: ', 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.TextSpan(text: company.vrn),
                    ],
                  ),
                ),
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(text: 'SERIAL NO: ', 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.TextSpan(text: company.serial),
                    ],
                  ),
                ),
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(text: 'TAX OFFICE: ', 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.TextSpan(text: company.taxoffice),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          pw.Divider(thickness: 1, height: 20),
          
          // Customer Info
          pw.Text('CUSTOMER NAME: ${receipt.customerName}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Row(
            children: [
              pw.Expanded(
                flex: 60,
                child: pw.Text('CUSTOMER ID TYPE:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Expanded(
                flex: 40,
                child: pw.Text(receipt.customerIdType,
                    textAlign: pw.TextAlign.right),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(
                flex: 60,
                child: pw.Text('CUSTOMER ID:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Expanded(
                flex: 40,
                child: pw.Text(receipt.customerIdNumber,
                    textAlign: pw.TextAlign.right),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(
                flex: 60,
                child: pw.Text('CUSTOMER MOBILE:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Expanded(
                flex: 40,
                child: pw.Text(receipt.customerMobile,
                    textAlign: pw.TextAlign.right),
              ),
            ],
          ),
          
          pw.Divider(thickness: 1, height: 20),
          
          // Receipt Info
          pw.Row(
            children: [
              pw.Expanded(
                flex: 60,
                child: pw.Text('RECEIPT NUMBER:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Expanded(
                flex: 40,
                child: pw.Text(receipt.receiptNumber,
                    textAlign: pw.TextAlign.right),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(
                flex: 60,
                child: pw.Text('Z NUMBER:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Expanded(
                flex: 40,
                child: pw.Text(receipt.zNumber,
                    textAlign: pw.TextAlign.right),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(
                flex: 60,
                child: pw.Text('RECEIPT DATE:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Expanded(
                flex: 40,
                child: pw.Text(receipt.receiptDate,
                    textAlign: pw.TextAlign.right),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(
                flex: 60,
                child: pw.Text('RECEIPT TIME:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Expanded(
                flex: 40,
                child: pw.Text(receipt.receiptTime,
                    textAlign: pw.TextAlign.right),
              ),
            ],
          ),
          
          pw.Divider(thickness: 1, height: 20),
          
          // Items
          pw.Center(
            child: pw.Text('PURCHASED ITEMS',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 5),
          
          ...receipt.items.map((item) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(item.itemDescription),
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 60,
                    child: pw.Text('Qty: ${item.itemQuantity}'),
                  ),
                  pw.Expanded(
                    flex: 40,
                    child: pw.Text(FormatUtils.formatCurrency(item.amount),
                        textAlign: pw.TextAlign.right),
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
            ],
          )).toList(),
          
          pw.Divider(thickness: 1, height: 20),
          
          // Totals
          pw.Row(
            children: [
              pw.Expanded(
                flex: 60,
                child: pw.Text('TOTAL EXCL OF TAX:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Expanded(
                flex: 40,
                child: pw.Text(FormatUtils.formatCurrency(receipt.totalExclOfTax),
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(
                flex: 60,
                child: pw.Text('DISCOUNT:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Expanded(
                flex: 40,
                child: pw.Text(FormatUtils.formatCurrency(receipt.discount),
                    textAlign: pw.TextAlign.right),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(
                flex: 60,
                child: pw.Text('TOTAL TAX:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Expanded(
                flex: 40,
                child: pw.Text(FormatUtils.formatCurrency(receipt.totalTax),
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(
                flex: 60,
                child: pw.Text('TOTAL INCL OF TAX:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Expanded(
                flex: 40,
                child: pw.Text(FormatUtils.formatCurrency(receipt.totalInclOfTax),
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
            ],
          ),
          
          pw.Divider(thickness: 1, height: 20),
          
          // Verification
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text('RECEIPT VERIFICATION CODE:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text(receipt.verificationCode,
                    style: const pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 10),
                pw.Container(
                  width: 120,
                  height: 120,
                  child: pw.Image(pw.MemoryImage(qrCode)),
                ),
                pw.SizedBox(height: 10),
                pw.Text('*** END OF LEGAL RECEIPT ***',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptWidget(ReceiptData receipt, CompanyProfile company) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(5),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: 'CourierPrime', // Use your typewriter font
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text('*** START OF LEGAL RECEIPT ***',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            
            // Company Info
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/tra.png',
                    width: 65,
                  ),
                  Text(company.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(company.address1),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(text: 'MOBILE: ', 
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: company.mobile),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(text: 'TIN: ', 
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: company.tin),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(text: 'VRN: ', 
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: company.vrn),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(text: 'SERIAL NO: ', 
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: company.serial),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(text: 'TAX OFFICE: ', 
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: company.taxoffice),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(thickness: 1, height: 20),
            
            // Customer Info
            Text('CUSTOMER NAME: ${receipt.customerName}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                const Expanded(
                  flex: 60,
                  child: Text('CUSTOMER ID TYPE:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 40,
                  child: Text(receipt.customerIdType,
                      textAlign: TextAlign.right),
                ),
              ],
            ),
            Row(
              children: [
                const Expanded(
                  flex: 60,
                  child: Text('CUSTOMER ID:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 40,
                  child: Text(receipt.customerIdNumber,
                      textAlign: TextAlign.right),
                ),
              ],
            ),
            Row(
              children: [
                const Expanded(
                  flex: 60,
                  child: Text('CUSTOMER MOBILE:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 40,
                  child: Text(receipt.customerMobile,
                      textAlign: TextAlign.right),
                ),
              ],
            ),
            
            const Divider(thickness: 1, height: 20),
            
            // Receipt Info
            Row(
              children: [
                const Expanded(
                  flex: 60,
                  child: Text('RECEIPT NUMBER:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 40,
                  child: Text(receipt.receiptNumber,
                      textAlign: TextAlign.right),
                ),
              ],
            ),
            Row(
              children: [
                const Expanded(
                  flex: 60,
                  child: Text('Z NUMBER:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 40,
                  child: Text(receipt.zNumber,
                      textAlign: TextAlign.right),
                ),
              ],
            ),
            Row(
              children: [
                const Expanded(
                  flex: 60,
                  child: Text('RECEIPT DATE:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 40,
                  child: Text(receipt.receiptDate,
                      textAlign: TextAlign.right),
                ),
              ],
            ),
            Row(
              children: [
                const Expanded(
                  flex: 60,
                  child: Text('RECEIPT TIME:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 40,
                  child: Text(receipt.receiptTime,
                      textAlign: TextAlign.right),
                ),
              ],
            ),
            
            const Divider(thickness: 1, height: 20),
            
            // Items
            const Center(
              child: Text('PURCHASED ITEMS',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 5),
            
            ...receipt.items.map((item) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.itemDescription),
                Row(
                  children: [
                    const Expanded(
                      flex: 60,
                      child: Text('Qty:'),
                    ),
                    Expanded(
                      flex: 40,
                      child: Text(FormatUtils.formatCurrency(item.amount),
                          textAlign: TextAlign.right),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
              ],
            )).toList(),
            
            const Divider(thickness: 1, height: 20),
            
            // Totals
            Row(
              children: [
                const Expanded(
                  flex: 60,
                  child: Text('TOTAL EXCL OF TAX:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 40,
                  child: Text(FormatUtils.formatCurrency(receipt.totalExclOfTax),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Row(
              children: [
                const Expanded(
                  flex: 60,
                  child: Text('DISCOUNT:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 40,
                  child: Text(FormatUtils.formatCurrency(receipt.discount),
                      textAlign: TextAlign.right),
                ),
              ],
            ),
            Row(
              children: [
                const Expanded(
                  flex: 60,
                  child: Text('TOTAL TAX:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 40,
                  child: Text(FormatUtils.formatCurrency(receipt.totalTax),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Row(
              children: [
                const Expanded(
                  flex: 60,
                  child: Text('TOTAL INCL OF TAX:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 40,
                  child: Text(FormatUtils.formatCurrency(receipt.totalInclOfTax),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            
            const Divider(thickness: 1, height: 20),
            
            // Verification
            Center(
              child: Column(
                children: [
                  const Text('RECEIPT VERIFICATION CODE:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(receipt.verificationCode,
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 10),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(border: Border.all()),
                    child: QrImageView(
                      data: receipt.verificationLink,
                      size: 100,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('*** END OF LEGAL RECEIPT ***',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
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
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _showShareOptions,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              final pdfFile = await _generatePdf();
              if (pdfFile != null) {
                await Printing.layoutPdf(
                  onLayout: (format) => pdfFile.readAsBytes(),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildReceiptWidget(widget.receipt, widget.company),
          ),
        ),
      ),
    );
  }
}