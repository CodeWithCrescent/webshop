// import 'package:flutter/material.dart';
// import 'package:printing/printing.dart';
// import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:webshop/core/localization/app_localizations.dart';
// import 'package:webshop/modules/receipts/models/receipt_data.dart';
// import 'package:webshop/modules/receipts/providers/receipt_provider.dart';
// import 'package:webshop/modules/receipts/widgets/receipt_html_view.dart';
// import 'package:webshop/shared/widgets/app_bar.dart';

// class ReceiptDetailPage extends StatefulWidget {
//   final String receiptNumber;

//   const ReceiptDetailPage({super.key, required this.receiptNumber});

//   @override
//   State<ReceiptDetailPage> createState() => _ReceiptDetailPageState();
// }

// class _ReceiptDetailPageState extends State<ReceiptDetailPage> {
//   late Future<ReceiptData> _receiptFuture;

//   @override
//   void initState() {
//     super.initState();
//     _receiptFuture = context.read<ReceiptProvider>().fetchReceiptDetails(widget.receiptNumber);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final loc = AppLocalizations.of(context);

//     return Scaffold(
//       appBar: WebshopAppBar(
//         title: loc?.translate('receipts.receipt_details') ?? 'Receipt Details',
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.print),
//             onPressed: () => _printReceipt(),
//           ),
//           IconButton(
//             icon: const Icon(Icons.share),
//             onPressed: () => _shareReceipt(),
//           ),
//         ], onRefresh: () {},
//       ),
//       body: FutureBuilder<ReceiptData>(
//         future: _receiptFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (!snapshot.hasData) {
//             return Center(child: Text(loc?.translate('receipts.no_receipt_found') ?? 'No receipt found'));
//           }

//           final receipt = snapshot.data!;
//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 ReceiptHtmlView(receipt: receipt),
//                 const SizedBox(height: 16),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       ElevatedButton.icon(
//                         icon: const Icon(Icons.print, size: 18),
//                         label: Text(loc?.translate('receipts.print') ?? 'Print'),
//                         onPressed: () => _printReceipt(),
//                       ),
//                       ElevatedButton.icon(
//                         icon: const Icon(Icons.share, size: 18),
//                         label: Text(loc?.translate('receipts.share') ?? 'Share'),
//                         onPressed: () => _shareReceipt(),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Future<void> _printReceipt() async {
//     final messenger = ScaffoldMessenger.of(context);
//     try {
//       final receipt = await _receiptFuture;
//       await Printing.layoutPdf(
//         onLayout: (format) => ReceiptHtmlView.generatePdf(receipt),
//       );
//     } catch (e) {
//       messenger.showSnackBar(
//         SnackBar(content: Text('Printing failed: $e')),
//       );
//     }
//   }

//   Future<void> _shareReceipt() async {
//     final messenger = ScaffoldMessenger.of(context);
//     try {
//       final receipt = await _receiptFuture;
//       final pdfBytes = await ReceiptHtmlView.generatePdf(receipt);
      
//       await Share.shareXFiles(
//         [XFile.fromData(pdfBytes, mimeType: 'application/pdf', name: 'Receipt_${receipt.receiptNumber}.pdf')],
//         text: 'Receipt ${receipt.receiptNumber}',
//       );
      
//       messenger.showSnackBar(
//         const SnackBar(content: Text('Share functionality coming soon')),
//       );
//     } catch (e) {
//       messenger.showSnackBar(
//         SnackBar(content: Text('Sharing failed: $e')),
//       );
//     }
//   }
// }