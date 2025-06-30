import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:webshop/modules/receipts/models/receipt.dart';
import 'package:webshop/modules/settings/providers/company_profile_provider.dart';

class ReceiptHtmlView extends StatelessWidget {
  final Receipt receipt;

  const ReceiptHtmlView({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final company = context.watch<CompanyProfileProvider>().companyProfile;
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS');

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Receipt HTML content would be rendered here
          // For now we'll use a simplified version
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      '*** START OF LEGAL RECEIPT ***',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(Icons.receipt, color: Colors.white, size: 30),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      company?.name ?? 'Company Name',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '${company?.address1 ?? ''}\n${company?.address2 ?? ''}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'TIN: ${company?.tin ?? 'N/A'} | VRN: ${company?.vrn ?? 'N/A'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const Divider(height: 24),
                  const Text(
                    'CUSTOMER INFORMATION',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Name: ${receipt.customer_name}'),
                  Text('Mobile: ${receipt.customer_mobile}'),
                  Text('ID Type: ${receipt.customer_id_type}'),
                  Text('ID Number: ${receipt.customer_id_number}'),
                  const Divider(height: 24),
                  const Text(
                    'RECEIPT DETAILS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Receipt #: ${receipt.receipt_number}'),
                  Text('Date: ${receipt.formattedDate}'),
                  Text('Time: ${receipt.receipt_time}'),
                  Text('Verification Code: ${receipt.verificationcode}'),
                  const Divider(height: 24),
                  const Text(
                    'ITEMS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...receipt.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(item.itemdesc),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(item.itemqty.toString()),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            currencyFormat.format(item.amount),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                  const Divider(height: 24),
                  const Text(
                    'TOTALS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:'),
                      Text(currencyFormat.format(receipt.total_excl_of_tax)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tax (18%):'),
                      Text(currencyFormat.format(receipt.total_tax)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Discount:'),
                      Text(currencyFormat.format(receipt.discount)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        currencyFormat.format(receipt.total_incl_of_tax),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      '*** END OF LEGAL RECEIPT ***',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<Uint8List> generatePdf(Receipt receipt) async {
    final pdf = pw.Document();
    final logo = await rootBundle.load('assets/images/tra.png');
    final logoImage = pw.MemoryImage(logo.buffer.asUint8List());
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS');

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  '*** START OF LEGAL RECEIPT ***',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Image(logoImage, width: 40, height: 40),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'TECHNO GADGETS LIMITED',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  'Uhuru Street, Dar es Salaam\n'
                  'MOBILE: +255784313200\n'
                  'EMAIL: info@technogadgets.co.tz\n'
                  'TIN: 123-456-789\n'
                  'VRN: 40-123456-X',
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Divider(),
              pw.Text(
                'CUSTOMER INFORMATION',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text('Name: ${receipt.customer_name}'),
              pw.Text('Mobile: ${receipt.customer_mobile}'),
              pw.Text('ID Type: ${receipt.customer_id_type}'),
              pw.Text('ID Number: ${receipt.customer_id_number}'),
              pw.Divider(),
              pw.Text(
                'RECEIPT DETAILS',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text('Receipt #: ${receipt.receipt_number}'),
              pw.Text('Date: ${receipt.formattedDate}'),
              pw.Text('Time: ${receipt.receipt_time}'),
              pw.Text('Verification Code: ${receipt.verificationcode}'),
              pw.Divider(),
              pw.Text(
                'ITEMS',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Description'),
                      pw.Text('Qty'),
                      pw.Text('Price'),
                    ],
                  ),
                  ...receipt.items.map((item) => pw.TableRow(
                    children: [
                      pw.Text(item.itemdesc),
                      pw.Text(item.itemqty.toString()),
                      pw.Text(currencyFormat.format(item.amount)),
                    ],
                  )).toList(),
                ],
              ),
              pw.Divider(),
              pw.Text(
                'TOTALS',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:'),
                  pw.Text(currencyFormat.format(receipt.total_excl_of_tax)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Tax (18%):'),
                  pw.Text(currencyFormat.format(receipt.total_tax)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Discount:'),
                  pw.Text(currencyFormat.format(receipt.discount)),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    currencyFormat.format(receipt.total_incl_of_tax),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  '*** END OF LEGAL RECEIPT ***',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}