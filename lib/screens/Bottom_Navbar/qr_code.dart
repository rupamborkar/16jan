// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';

// class QRScanPage extends StatefulWidget {
//   @override
//   _QRScanPageState createState() => _QRScanPageState();
// }

// class _QRScanPageState extends State<QRScanPage> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   QRViewController? controller;
//   String? scannedData;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan QR Code'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             flex: 4,
//             child: QRView(
//               key: qrKey,
//               onQRViewCreated: _onQRViewCreated,
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Center(
//               child: scannedData != null
//                   ? Text('Scanned: $scannedData')
//                   : const Text('Scan a QR code'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       setState(() {
//         scannedData = scanData.code;
//       });
//       controller.pauseCamera(); // Pause camera after scanning
//       Navigator.pop(context, scanData.code); // Return scanned data
//     });
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
// }
