import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:hive/hive.dart';
import '../models/product.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  MobileScannerController cameraController = MobileScannerController();
  Product? product;
  bool _isScanning = true; // To control the scanner state

  @override
  void initState() {
    super.initState();
    // Listen for barcode detection
    cameraController.barcodes.listen(_onDetect);
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning) return; // Only process if currently scanning

    final code = capture.barcodes.first.rawValue;
    if (code == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No QR code detected or invalid format.')),
      );
      return;
    }

    final box = Hive.box<Product>('products');
    final p = box.get(code);

    if (p != null) {
      // Pause scanning to avoid multiple detections
      await cameraController.stop();
      setState(() {
        product = p;
        _isScanning = false; // Update state to stop scanning UI
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product with ID "$code" not found.')),
      );
      // Optionally, resume scanning automatically or let user retry
    }
  }

  void _updateRoom(String room) async {
    if (product == null) return;

    setState(() {
      product!.location = room;
    });

    try {
      await product!.save();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product "${product!.name}" moved to $room!')),
      );
      _resetScan(); // Reset after successful update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product location: $e')),
      );
    }
  }

  void _resetScan() {
    setState(() {
      product = null;
      _isScanning = true; // Set to true to allow scanning again
    });
    cameraController.start(); // Restart the camera
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan Product QR Code')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  // Pass the controller
                  onDetect: (capture) {
                    // The listener is already doing the work
                  },
                ),
                // Add a scanner overlay for better UX
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal, width: 3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _isScanning ? 'Position QR code in the box' : 'QR code detected!',
                          style: TextStyle(color: Colors.white, fontSize: 16, backgroundColor: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (product == null && _isScanning)
                    Text(
                      'Waiting for QR scan...',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    )
                  else if (product != null) ...[
                    Card(
                      elevation: 4,
                      margin: EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Product Found:',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Name: ${product!.name}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.teal),
                            ),
                            Text(
                              'Current Location: ${product!.location}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: 15),
                            Text('Move to:'),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _updateRoom('Room A'),
                                  icon: Icon(Icons.room),
                                  label: Text('Room A'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _updateRoom('Room B'),
                                  icon: Icon(Icons.room),
                                  label: Text('Room B'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _resetScan,
                      icon: Icon(Icons.refresh),
                      label: Text('Scan Another Product'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey, // A different color for reset
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ] else
                    // This state is for when a product was not found
                    Column(
                      children: [
                        Text(
                          'Product not found in database.',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _resetScan,
                          icon: Icon(Icons.refresh),
                          label: Text('Try Scanning Again'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}