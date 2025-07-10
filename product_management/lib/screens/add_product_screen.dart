import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:hive/hive.dart';
import '../models/product.dart';
import 'package:uuid/uuid.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>(); // For form validation
  final _nameController = TextEditingController();
  final uuid = Uuid();
  String? qrString;
  bool _isSaving = false; // To show loading indicator

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form is not valid
    }

    setState(() {
      _isSaving = true;
    });

    final id = uuid.v4();
    final product = Product(
      id: id,
      name: _nameController.text.trim(), // Trim whitespace
      location: 'Unassigned', // Default location, can be a dropdown later
      qrCode: id,
    );

    try {
      final box = Hive.box<Product>('products');
      await box.put(id, product);

      setState(() {
        qrString = id;
        _nameController.clear(); // Clear input after successful save
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product "${product.name}" added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving product: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Product')),
      body: SingleChildScrollView( // To prevent overflow on small screens
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'e.g., Laptop, Projector, Chair',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.label_important),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Product name cannot be empty.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _isSaving
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _saveProduct,
                      icon: Icon(Icons.qr_code),
                      label: Text('Generate QR Code & Save Product'),
                    ),
              if (qrString != null) ...[
                SizedBox(height: 30),
                Center(
                  child: Text(
                    'Scan this QR code to identify the product:',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrString!,
                    size: 250, // Slightly larger QR code
                    version: QrVersions.auto,
                    gapless: false, // Recommended for better scanning
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Product ID: $qrString',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}