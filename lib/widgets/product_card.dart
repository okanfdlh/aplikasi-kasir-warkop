import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPesan; // Callback for "Pesan" button

  ProductCard({
    required this.product,
    this.onEdit,
    this.onDelete,
    this.onPesan,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _quantity = 0; // Track the quantity of the product being ordered

  String formatRupiah(double price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(price);
  }

  void _showDeleteConfirmationDialog(BuildContext context, int productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Penghapusan"),
          content: const Text("Apakah Anda yakin ingin menghapus produk ini?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                if (widget.onDelete != null) widget.onDelete!();
                Navigator.of(context).pop(); // Close dialog after deleting
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    widget.product.image.startsWith('http')
                        ? widget.product.image
                        : 'https://seduh.dev-web2.babelprov.go.id/storage/${widget.product.image}',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: widget.onEdit,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, widget.product.id);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.name,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(formatRupiah(widget.product.price),
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 0),
                Text("Kategori: ${widget.product.category}",
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
                SizedBox(height: 0),
                // Quantity Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: Colors.red),
                      onPressed: () {
                        if (_quantity > 0) {
                          setState(() {
                            _quantity--;
                          });
                        }
                      },
                    ),
                    Text("$_quantity", style: TextStyle(fontSize: 13)),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (widget.onPesan != null) widget.onPesan!();
                      // Pass the quantity to the order function
                      print("Pesan ${widget.product.name}, Quantity: $_quantity");
                    },
                    icon: Icon(Icons.shopping_cart),
                    label: Text("Pesan"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
