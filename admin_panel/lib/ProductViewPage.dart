import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:async/async.dart'; // Add async package to your pubspec.yaml

class ProductViewPage extends StatefulWidget {
  @override
  _ProductViewPageState createState() => _ProductViewPageState();
}

class _ProductViewPageState extends State<ProductViewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedDocument = 'YE'; // Default document

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('View Products'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Column(
          children: [
            // Dropdown for selecting document
            DropdownButtonFormField<String>(
              value: _selectedDocument,
              onChanged: (value) {
                setState(() {
                  _selectedDocument = value!;
                });
              },
              items: ['YE', 'KSA', 'UEA', 'BH','Yemen'].map((document) {
                return DropdownMenuItem(
                  value: document,
                  child: Text(document, style: TextStyle(color: Colors.black)),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Select Document',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color(0xFF333333),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getCombinedProductStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('An error occurred!'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No products found.'));
                  }

                  final products = snapshot.data!;

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product = products[index];
                      var imageUrl = product['imageUrl'] ?? '';
                      var category = product['category'] ?? '';
                      var productId = product['id']; // Ensure that the product has an ID
                      var isNew = product['isNew'] ?? false;
                      var isOnOffer = product['isOnOffer'] ?? false;
                      var discount = product['discount'] ?? 'N/A';

                      return Card(
                        color: Color(0xFF333333),
                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (imageUrl.isNotEmpty)
                                CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              SizedBox(height: 16),
                              Text(
                                'Category: $category',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Name: ${product['name'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Description: ${product['description'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Price: ${product['price'] ?? 'N/A'} ${product['unit'] ?? ''}',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                              if (isNew)
                                Text(
                                  'New Product!',
                                  style: TextStyle(fontSize: 16, color: Colors.yellow),
                                ),
                              if (isOnOffer)
                                Text(
                                  'Discount: $discount%',
                                  style: TextStyle(fontSize: 16, color: Colors.red),
                                ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.yellow),
                                    onPressed: () {
                                      _showUpdateDialog(productId, category, product);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _deleteProduct(productId, category);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> _getCombinedProductStream() async* {
    final oilStream = _firestore
        .collection('Product')
        .doc(_selectedDocument)
        .collection('Oil')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['category'] = 'Oil';
      data['id'] = doc.id; // Add document ID
      return data;
    }).toList());

    final honeyStream = _firestore
        .collection('Product')
        .doc(_selectedDocument)
        .collection('Honey')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['category'] = 'Honey';
      data['id'] = doc.id; // Add document ID
      return data;
    }).toList());

    yield* StreamZip([oilStream, honeyStream]).map((List<List<Map<String, dynamic>>> lists) {
      final combinedProducts = <Map<String, dynamic>>[];
      for (var list in lists) {
        combinedProducts.addAll(list);
      }
      return combinedProducts;
    });
  }

  void _deleteProduct(String productId, String category) async {
    try {
      await _firestore
          .collection('Product')
          .doc(_selectedDocument)
          .collection(category)
          .doc(productId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product deleted successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete product.')));
    }
  }

  void _showUpdateDialog(String productId, String category, Map<String, dynamic> product) {
    TextEditingController _nameController = TextEditingController(text: product['name']);
    TextEditingController _priceController = TextEditingController(text: product['price'].toString());
    TextEditingController _descriptionController = TextEditingController(text: product['description']);
    String _unit = product['unit'] ?? 'mil';
    bool _isNew = product['isNew'] ?? false;
    bool _isOnOffer = product['isOnOffer'] ?? false;
    TextEditingController _discountController = TextEditingController(text: product['discount'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Product'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                DropdownButtonFormField<String>(
                  value: _unit,
                  onChanged: (value) {
                    setState(() {
                      _unit = value!;
                    });
                  },
                  items: ['mil', 'kilo'].map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Unit',
                  ),
                ),
                SwitchListTile(
                  title: Text('Is New?'),
                  value: _isNew,
                  onChanged: (value) {
                    setState(() {
                      _isNew = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: Text('Is on Offer?'),
                  value: _isOnOffer,
                  onChanged: (value) {
                    setState(() {
                      _isOnOffer = value;
                    });
                  },
                ),
                if (_isOnOffer)
                  TextField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Discount Percentage (e.g., 25)'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await _firestore
                      .collection('Product')
                      .doc(_selectedDocument)
                      .collection(category)
                      .doc(productId)
                      .update({
                    'name': _nameController.text,
                    'price': double.tryParse(_priceController.text) ?? 0,
                    'description': _descriptionController.text,
                    'unit': _unit,
                    'isNew': _isNew,
                    'isOnOffer': _isOnOffer,
                    'discount': _isOnOffer ? _discountController.text : 'N/A',
                    'newTimestamp': _isNew ? Timestamp.now() : null,
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product updated successfully!')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update product.')));
                }
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
