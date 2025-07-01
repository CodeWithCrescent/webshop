import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:webshop/modules/receipts/models/receipt.dart';
import 'package:webshop/modules/settings/models/company_profile.dart';
import 'package:webshop/modules/settings/providers/company_profile_provider.dart';

class ReceiptHtmlView extends StatelessWidget {
  final Receipt receipt;

  const ReceiptHtmlView({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final company = context.watch<CompanyProfileProvider>().companyProfile;
    final currencyFormat =
        NumberFormat.currency(locale: 'en_US', symbol: 'TZS');

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          HtmlElementView(
            viewType: 'receipt-html',
            onPlatformViewCreated: (id) {
              _loadHtmlContent(id, receipt, company!, currencyFormat);
            },
          ),
        ],
      ),
    );
  }

  static Future<void> _loadHtmlContent(
    int id,
    Receipt receipt,
    CompanyProfile company,
    NumberFormat currencyFormat,
  ) async {
    final htmlContent = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TRA Receipt</title>
    <style>
        body {
            font-family: 'Courier New', monospace;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        
        .receipt {
            width: 300px;
            background: white;
            padding: 15px;
            border: 1px solid #ddd;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            font-size: 11px;
            line-height: 1.3;
        }
        
        .center {
            text-align: center;
        }
        
        .left {
            text-align: left;
        }
        
        .right {
            text-align: right;
        }
        
        .bold {
            font-weight: bold;
        }
        
        .header {
            padding-bottom: 10px;
            margin-bottom: 10px;
        }
        
        .company-info {
            margin-bottom: 15px;
        }
        
        .customer-info {
            padding: 10px 0;
            margin: 10px 0;
        }
        
        .items-section {
            margin: 15px 0;
        }
        
        .item-row {
            display: flex;
            justify-content: space-between;
            margin: 5px 0;
            padding: 3px 0;
        }
        
        .item-row:nth-child(even) {
            background-color: #ffffcc;
        }
        
        .item-desc {
            width: 60%;
        }
        
        .item-qty {
            width: 15%;
            text-align: center;
        }
        
        .item-price {
            width: 25%;
            text-align: right;
        }
        
        .totals {
            padding-top: 10px;
            margin-top: 15px;
        }
        
        .total-row {
            display: flex;
            justify-content: space-between;
            margin: 3px 0;
        }
        
        .footer {
            padding-top: 10px;
            margin-top: 15px;
        }
        
        .qr-code {
            width: 80px;
            height: 80px;
            background: #ddd;
            margin: 10px auto;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 10px;
            color: #666;
        }
        
        .logo {
            width: 40px;
            height: 40px;
            background: #0066cc;
            border-radius: 50%;
            margin: 0 auto 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
        }
        
        .dotted-line {
            border-top: 1px dotted #000;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="receipt">
        <!-- Header -->
        <div class="header center">
            <div class="bold">*** START OF LEGAL RECEIPT ***</div>
        </div>
        
        <!-- Logo -->
        <div class="center">
            <div class="logo">TRA</div>
        </div>
        
        <!-- Company Information -->
        <div class="company-info center">
            <div class="bold">${company.name}</div>
            <div>${company.address1}</div>
            <div><span class="bold">MOBILE:</span> ${company.mobile}</div>
            <div><span class="bold">TIN:</span> ${company.tin}</div>
            <div><span class="bold">VRN:</span> ${company.vrn}</div>
            <div><span class="bold">SERIAL NO:</span> ${company.serial}</div>
            <div><span class="bold">TAX OFFICE:</span> ${company.taxoffice}</div>
        </div>
        
        <!-- Customer Information -->
        <div class="customer-info">
            <div class="dotted-line"></div>
            <div class="left bold">CUSTOMER NAME: ${receipt.customerName}</div>
            <div class="total-row">
                <span class="bold">CUSTOMER ID TYPE:</span>
                <span>${receipt.customerIdType}</span>
            </div>
            <div class="total-row">
                <span class="bold">CUSTOMER ID:</span>
                <span>${receipt.customerIdNumber}</span>
            </div>
            <div class="total-row">
                <span class="bold">CUSTOMER MOBILE:</span>
                <span>${receipt.customerMobile}</span>
            </div>
            <div class="dotted-line"></div>
        </div>
        
        <!-- Receipt Details -->
        <div class="receipt-details">
            <div class="total-row">
                <span class="bold">RECEIPT NUMBER:</span>
                <span>${receipt.receiptNumber}</span>
            </div>
            <div class="total-row">
                <span class="bold">Z NUMBER:</span>
                <span>${receipt.zNumber}</span>
            </div>
            <div class="total-row">
                <span class="bold">RECEIPT DATE:</span>
                <span>${receipt.receiptDate}</span>
            </div>
            <div class="total-row">
                <span class="bold">RECEIPT TIME:</span>
                <span>${receipt.receiptTime}</span>
            </div>
            <div class="dotted-line"></div>
        </div>
        
        <!-- Items Header -->
        <div class="items-section">
            <div class="item-row bold">
                <div class="item-desc">Description</div>
                <div class="item-qty">Qty</div>
                <div class="item-price">Price (TZS)</div>
            </div>
            
            <!-- Items -->
            ${receipt.items.map((item) => '''
            <div class="item-row">
                <div class="item-desc">${item.itemDescription}</div>
                <div class="item-qty">${item.itemQuantity}</div>
                <div class="item-price">${currencyFormat.format(item.amount)}</div>
            </div>
            ''').join()}
        </div>
        
        <!-- Totals Section -->
        <div class="totals">
            <div class="dotted-line"></div>
            <div class="total-row bold">
                <span>TOTAL EXCL OF TAX:</span>
                <span>${currencyFormat.format(receipt.totalExclOfTax)}</span>
            </div>
            <div class="total-row">
                <span class="bold">DISCOUNT:</span>
                <span>${currencyFormat.format(receipt.discount)}</span>
            </div>
            <div class="total-row">
                <span class="bold">TAX RATE:</span>
                <span>${currencyFormat.format(receipt.totalTax)}</span>
            </div>
            <div class="total-row bold">
                <span>TOTAL TAX:</span>
                <span>${currencyFormat.format(receipt.totalTax)}</span>
            </div>
            <div class="total-row bold" style="font-size: 12px;">
                <span>TOTAL INCL OF TAX:</span>
                <span>${currencyFormat.format(receipt.totalInclOfTax)}</span>
            </div>
            <div class="dotted-line"></div>
        </div>
        
        <!-- Footer -->
        <div class="footer center">
            <div class="bold">RECEIPT VERIFICATION CODE:</div>
            <div style="margin: 10px 0; word-break: break-all; font-size: 10px;">
                ${receipt.verificationCode}
            </div>
            
            <div class="qr-code">
                QR CODE<br>
                [Verification]
            </div>
            
            <div class="bold">*** END OF LEGAL RECEIPT ***</div>
        </div>
    </div>
</body>
</html>
''';

    final methodChannel = MethodChannel('receipt_html_$id');
    methodChannel.invokeMethod('loadHtml', htmlContent);
  }

  static Future<Uint8List> generatePdf(Receipt receipt) async {
    final pdf = pw.Document();
    final currencyFormat =
        NumberFormat.currency(locale: 'en_US', symbol: 'TZS');

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('*** START OF LEGAL RECEIPT ***',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Container(
                  width: 40,
                  height: 40,
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF0066CC),
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text('TRA',
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Receipt Number: ${receipt.receiptNumber}'),
              pw.Text('Date: ${receipt.receiptDate}'),
              pw.Text('Time: ${receipt.receiptTime}'),
              pw.Divider(),
              pw.Text('Customer: ${receipt.customerName}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Items:'),
                      pw.Text(receipt.items.length.toString()),
                    ],
                  ),
                  ...receipt.items.map((item) => pw.TableRow(
                        children: [
                          pw.Text(item.itemDescription),
                          pw.Text(
                              '${item.itemQuantity} x ${currencyFormat.format(item.amount)}'),
                        ],
                      )),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total:'),
                  pw.Text(currencyFormat.format(receipt.totalInclOfTax),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text('*** END OF LEGAL RECEIPT ***',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              )
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
