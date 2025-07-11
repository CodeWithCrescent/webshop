import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html_to_pdf_updated/flutter_html_to_pdf.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
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

  Future<void> _generatePdf() async {
    final htmlContent = _buildHtml(widget.receipt, widget.business);

    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    final targetFile = await FlutterHtmlToPdf.convertFromHtmlContent(
      htmlContent,
      directory!.path,
      'receipt_${widget.receipt.receiptNumber}',
    );

    setState(() {
      _pdfPath = targetFile.path;
    });
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
  void initState() {
    super.initState();
    _generatePdf();
  }

  @override
  Widget build(BuildContext context) {
    final htmlContent = _buildHtml(widget.receipt, widget.business);
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            child: SingleChildScrollView(
              child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor),
                  child: HtmlWidget(htmlContent)),
            ),
          ),
        ));
  }

  /// HTML BUILDER (injects receipt + business data)
  String _buildHtml(ReceiptData receipt, BusinessProfile business) {
    final qrCode = QrImageView(data: parseString(receipt.verificationLink), size: 280,);
    return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
</head>
<body style="">
<div style="max-width: 400px; background: white; padding: 5px; font-family: 'Courier New', monospace; margin: 0; font-size: 18px; font-weight: bold;">
  <div style="text-align: center; font-weight: 900;">*** START OF LEGAL RECEIPT ***</div><br>
  <div style="text-align: center;">
    <img src="assets/images/tra.png" alt="TRA logo" style="max-width:65px;" />
    <div style="font-weight: 900;">${business.name}</div>
    <div>${business.address1}</div>
    <div><span style="font-weight: 900;">MOBILE:</span> ${business.mobile}</div>
    <div><span style="font-weight: 900;">TIN:</span> ${business.tin}</div>
    <div><span style="font-weight: 900;">VRN:</span> ${business.vrn}</div>
    <div><span style="font-weight: 900;">SERIAL NO:</span> ${business.serial}</div>
    <div><span style="font-weight: 900;">TAX OFFICE:</span> ${business.taxoffice}</div>
  </div>
  <div style="border-top: 1px dotted #000; margin: 10px 0;"></div>
  <div style="text-align: left; font-weight: 900;">CUSTOMER NAME: ${receipt.customerName}</div>
  <div style="display: table; width: 100%;"><div style="display: table-cell; width: 60%; text-align: left; font-weight: 900;">CUSTOMER ID TYPE:</div><div style="display: table-cell; width: 40%; text-align: right;">${receipt.customerIdType}</div></div>
  <div style="display: table; width: 100%;"><div style="display: table-cell; width: 60%; text-align: left; font-weight: 900;">CUSTOMER ID:</div><div style="display: table-cell; width: 40%; text-align: right;">${receipt.customerIdNumber}</div></div>
  <div style="display: table; width: 100%;"><div style="display: table-cell; width: 60%; text-align: left; font-weight: 900;">CUSTOMER MOBILE:</div><div style="display: table-cell; width: 40%; text-align: right;">${receipt.customerMobile}</div></div>
  <div style="border-top: 1px dotted #000; margin: 10px 0;"></div>
  <div style="display: table; width: 100%;"><div style="display: table-cell; width: 60%; text-align: left; font-weight: 900;">RECEIPT NUMBER:</div><div style="display: table-cell; width: 40%; text-align: right;">${receipt.receiptNumber}</div></div>
  <div style="display: table; width: 100%;"><div style="display: table-cell; width: 60%; text-align: left; font-weight: 900;">Z NUMBER:</div><div style="display: table-cell; width: 40%; text-align: right;">${receipt.zNumber}</div></div>
  <div style="display: table; width: 100%;"><div style="display: table-cell; width: 60%; text-align: left; font-weight: 900;">RECEIPT DATE:</div><div style="display: table-cell; width: 40%; text-align: right;">${receipt.receiptDate}</div></div>
  <div style="display: table; width: 100%;"><div style="display: table-cell; width: 60%; text-align: left; font-weight: 900;">RECEIPT TIME:</div><div style="display: table-cell; width: 40%; text-align: right;">${receipt.receiptTime}</div></div>
  <div style="border-top: 1px dotted #000; margin: 10px 0;"></div>
  <div style="text-align: center; font-weight: 900; border-bottom: 1px solid #000; padding-bottom: 3px; margin-bottom: 5px;">PURCHASED ITEMS</div>
  ${receipt.items.map((item) => '''
    <div style="margin: 3px 0; overflow: hidden;">
      <div>${item.itemDescription}</div>
      <div style="display: table; width: 100%;">
        <div style="display: table-cell; width: 60%; text-align: left;">Qty: ${item.itemQuantity}</div>
        <div style="display: table-cell; width: 40%; text-align: right;">${FormatUtils.formatCurrency(item.amount)}</div>
      </div>
    </div>
  ''').join()}
  <div style="border-top: 1px dotted #000; margin: 10px 0;"></div>
  <div style="display: table; width: 100%; font-weight: 900;"><div style="display: table-cell; width: 60%; text-align: left;">TOTAL EXCL OF TAX:</div><div style="display: table-cell; width: 40%; text-align: right;">${FormatUtils.formatCurrency(receipt.totalExclOfTax)}</div></div>
  <div style="display: table; width: 100%;"><div style="display: table-cell; width: 60%; text-align: left; font-weight: 900;">DISCOUNT:</div><div style="display: table-cell; width: 40%; text-align: right;">${FormatUtils.formatCurrency(receipt.discount)}</div></div>
  <div style="display: table; width: 100%; font-weight: 900;"><div style="display: table-cell; width: 60%; text-align: left;">TOTAL TAX:</div><div style="display: table-cell; width: 40%; text-align: right;">${FormatUtils.formatCurrency(receipt.totalTax)}</div></div>
  <div style="display: table; width: 100%; font-weight: 900;"><div style="display: table-cell; width: 60%; text-align: left;">TOTAL INCL OF TAX:</div><div style="display: table-cell; width: 40%; text-align: right;">${FormatUtils.formatCurrency(receipt.totalInclOfTax)}</div></div>
  <div style="border-top: 1px dotted #000; margin: 10px 0;"></div>
  <div style="text-align: center;">
    <div style="font-weight: 900;">RECEIPT VERIFICATION CODE:</div>
    <div style="margin: 10px 0; word-break: break-word; font-size: 14px;">
      ${receipt.verificationCode}
    </div>
    <div style="border: 1px solid #000; padding: 20px; margin: 10px 0;">$qrCode</div>
    <div style="font-weight: 900;">*** END OF LEGAL RECEIPT ***</div>
  </div>
</div>
</body>
</html>
''';
  }
}
