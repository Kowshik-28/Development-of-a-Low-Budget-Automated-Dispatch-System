import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart'; // To display QR in detail
import '../models/product.dart';

class ProductListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Product>('products');

    return Scaffold(
      appBar: AppBar(title: Text('All Products')),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Product> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 20),
                  Text(
                    'No products added yet!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Tap "Add Product" to get started.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final product = box.getAt(index)!; // Get product by index
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
                  title: Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        'Location: ${product.location}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ID: ${product.id.substring(0, 8)}...', // Show truncated ID
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.secondary),
                    onPressed: () {
                      // Navigate to a product detail screen or show a dialog
                      _showProductDetails(context, product);
                    },
                  ),
                  onLongPress: () {
                    // Option to delete
                    _confirmDeleteProduct(context, product, box);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${product.id}'),
              SizedBox(height: 8),
              Text('Location: ${product.location}'),
              SizedBox(height: 20),
              Center(
                child: QrImageView(
                  data: product.qrCode,
                  size: 150,
                  version: QrVersions.auto,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteProduct(BuildContext context, Product product, Box<Product> box) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text('Are you sure you want to delete "${product.name}"?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await product.delete(); // HiveObject has a delete method
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Product "${product.name}" deleted.')),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}