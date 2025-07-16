import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final void Function(int quantity)? onPesan;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onPesan,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _quantity = 0;

  String formatRupiah(double price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(price);
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
          // Gambar dan tombol edit/delete
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    widget.product.image.startsWith('http')
                        ? widget.product.image
                        : 'https://rumahseduh.shbhosting999.my.id/storage/${widget.product.image}',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: Row(
                    children: [
                      if (widget.onEdit != null)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                            onPressed: widget.onEdit,
                          ),
                        ),
                      const SizedBox(width: 4),
                      if (widget.onDelete != null)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                            onPressed: widget.onDelete, // langsung panggil onDelete
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Konten bawah
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(formatRupiah(widget.product.price),
                    style: const TextStyle(
                        color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                Text("Kategori: ${widget.product.category}",
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 8),
                // Quantity
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.red),
                      onPressed: () {
                        if (_quantity > 0) setState(() => _quantity--);
                      },
                      iconSize: 18,
                    ),
                    Text('$_quantity', style: const TextStyle(fontSize: 13)),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.green),
                      onPressed: () => setState(() => _quantity++),
                      iconSize: 18,
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (widget.onPesan != null && _quantity > 0) {
                        widget.onPesan!(_quantity);
                      }
                    },
                    icon: const Icon(Icons.shopping_cart, size: 14),
                    label: const Text("Pesan", style: TextStyle(fontSize: 12)),
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
