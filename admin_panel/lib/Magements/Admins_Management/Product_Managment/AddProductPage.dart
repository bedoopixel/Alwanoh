import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  String _selectedCategory = 'Oil';
  String _selectedDocument = 'YE';
  String _selectedUnit = 'mil';
  bool _isOnOffer = false;
  bool _isNew = false;
  File? _image1, _image2, _image3, _image4;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Quantity selection state
  Map<int, bool> _selectedQuantities = {};
  Map<int, TextEditingController> _quantityPriceControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeQuantitySelection();
  }

  void _initializeQuantitySelection() {
    // Initialize quantity options and controllers for the selected category
    List<int> quantities = _selectedCategory == 'Honey' ? [175, 250, 500, 1000, 7000] : [50, 100, 180];
    _selectedQuantities = {for (var quantity in quantities) quantity: false};
    _quantityPriceControllers = {for (var quantity in quantities) quantity: TextEditingController()};
  }

  Future<void> _pickImage(int imageIndex) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        switch (imageIndex) {
          case 1:
            _image1 = File(pickedFile.path);
            break;
          case 2:
            _image2 = File(pickedFile.path);
            break;
          case 3:
            _image3 = File(pickedFile.path);
            break;
          case 4:
            _image4 = File(pickedFile.path);
            break;
        }
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = _storage.ref().child('product_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload image.')));
      return null;
    }
  }

  Future<void> _addProduct() async {
    if (_image1 == null && _image2 == null && _image3 == null && _image4 == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select at least one image.')));
      return;
    }

    String name = _nameController.text.trim();
    double price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    String description = _descriptionController.text.trim();
    String rating = _ratingController.text.trim();
    String category = _selectedCategory;
    String unit = _selectedUnit;
    double? discount = _isOnOffer ? double.tryParse(_discountController.text.trim()) : null;
    DateTime? now = _isNew ? DateTime.now() : null;

    double? discountedPrice = discount != null && discount > 0
        ? price - (price * (discount / 100))
        : null;

    // Get selected quantities and their prices
    Map<String, double> selectedQuantities = {};
    _selectedQuantities.forEach((quantity, isSelected) {
      if (isSelected) {
        double quantityPrice = double.tryParse(_quantityPriceControllers[quantity]!.text.trim()) ?? 0.0;
        double finalPrice = discountedPrice ?? price;
        selectedQuantities[quantity.toString()] = finalPrice * quantity;
      }
    });

    if (selectedQuantities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select at least one quantity.')));
      return;
    }

    try {
      // Upload selected images to Firebase Storage
      String? imageUrl1 = _image1 != null ? await _uploadImage(_image1!) : null;
      String? imageUrl2 = _image2 != null ? await _uploadImage(_image2!) : null;
      String? imageUrl3 = _image3 != null ? await _uploadImage(_image3!) : null;
      String? imageUrl4 = _image4 != null ? await _uploadImage(_image4!) : null;

      // Build the product data map
      Map<String, dynamic> productData = {
        'name': name,
        'price': price,
        'description': description,
        'rating': rating,
        'unit': unit,
        'isOnOffer': _isOnOffer,
        'isNew': _isNew,
        'newTimestamp': now != null ? Timestamp.fromDate(now) : null,
        'quantities': selectedQuantities,
      };

      if (discountedPrice != null) {
        productData['discountedPrice'] = discountedPrice;
      }

      if (discount != null && discount > 0) {
        productData['discount'] = discount;
      }

      if (imageUrl1 != null) productData['image1'] = imageUrl1;
      if (imageUrl2 != null) productData['image2'] = imageUrl2;
      if (imageUrl3 != null) productData['image3'] = imageUrl3;
      if (imageUrl4 != null) productData['image4'] = imageUrl4;

      // Add product details to Firestore under the selected document and category
      await _firestore
          .collection('Product')
          .doc(_selectedDocument)
          .collection(category)
          .add(productData);

      // Clear text fields and images
      _clearForm();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product added successfully!')));
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add product.')));
    }
  }

  Widget _buildQuantitySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _selectedQuantities.keys.map((quantity) {
        return CheckboxListTile(
          title: Text(
            '$quantity ${_selectedCategory == 'Honey' ? 'grams' : 'ml'}',
            style: TextStyle(color: Colors.white),
          ),
          value: _selectedQuantities[quantity],
          onChanged: (bool? value) {
            setState(() {
              _selectedQuantities[quantity] = value!;
              _updateQuantityPrice(quantity); // Update price when quantity selection changes
            });
          },
          activeColor: Colors.white,
          checkColor: Colors.black,
          tileColor: Colors.transparent,
        );
      }).toList(),
    );
  }


  void _updateQuantityPrice(int quantity) {
    double price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    double? discountedPrice = _isOnOffer
        ? price - (price * (double.tryParse(_discountController.text.trim()) ?? 0.0 / 100))
        : null;
    double finalPrice = discountedPrice ?? price;

    // Only update the quantity price map, not the TextEditingController
    _quantityPriceControllers[quantity]?.text = (finalPrice * quantity).toString();
  }




  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _ratingController.clear();
    _discountController.clear();
    setState(() {
      _image1 = null;
      _image2 = null;
      _image3 = null;
      _image4 = null;
      _selectedCategory = 'Oil';
      _selectedDocument = 'YE';
      _selectedUnit = 'mil';
      _isOnOffer = false;
      _isNew = false;
      _initializeQuantitySelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Add Product'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDropdownField('Select Document', ['YE', 'KSA', 'UEA', 'BH'], _selectedDocument, (value) {
              setState(() {
                _selectedDocument = value!;
              });
            }),
            SizedBox(height: 16),
            _buildDropdownField('Category', ['Oil', 'Honey'], _selectedCategory, (value) {
              setState(() {
                _selectedCategory = value!;
                _initializeQuantitySelection(); // Re-initialize quantities when category changes
              });
            }),
            SizedBox(height: 16),
            _buildTextField(_nameController, 'Product Name'),
            SizedBox(height: 16),
            _buildTextField(_priceController, 'Price', keyboardType: TextInputType.number),
            SizedBox(height: 16),
            _buildTextField(_descriptionController, 'Description'),
            SizedBox(height: 16),
            _buildTextField(_ratingController, 'Rating', keyboardType: TextInputType.numberWithOptions(decimal: true)),
            SizedBox(height: 16),
            _buildTextField(_discountController, 'Discount (%)', keyboardType: TextInputType.number),
            SizedBox(height: 16),
            _buildDropdownField('Unit', ['mil', 'liter', 'kg'], _selectedUnit, (value) {
              setState(() {
                _selectedUnit = value!;
              });
            }),
            SizedBox(height: 16),
            _buildImageUploadButtons(),
            SizedBox(height: 16),
            _buildQuantitySelection(),
            SizedBox(height: 16),
            _buildCheckboxField('On Offer', _isOnOffer, (value) {
              setState(() {
                _isOnOffer = value!;
              });
            }),
            _buildCheckboxField('New Product', _isNew, (value) {
              setState(() {
                _isNew = value!;
              });
            }),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addProduct,
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String selectedItem, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedItem,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      dropdownColor: Colors.black,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCheckboxField(String label, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(label, style: TextStyle(color: Colors.white)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      checkColor: Colors.black,
      tileColor: Colors.transparent,
    );
  }

  Widget _buildImageUploadButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildImageButton(1, _image1),
        _buildImageButton(2, _image2),
        _buildImageButton(3, _image3),
        _buildImageButton(4, _image4),
      ],
    );
  }

  Widget _buildImageButton(int imageIndex, File? imageFile) {
    return GestureDetector(
      onTap: () => _pickImage(imageIndex),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
        ),
        child: imageFile != null
            ? Image.file(imageFile, fit: BoxFit.cover)
            : Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }


}
