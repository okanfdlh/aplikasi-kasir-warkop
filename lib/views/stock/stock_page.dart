import 'package:coffeeorder/controllers/stock_controller.dart';
import 'package:coffeeorder/services/api_service.dart';
import 'package:coffeeorder/views/stock/edit_stock_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coffeeorder/models/product_model.dart';

class StokPage extends StatefulWidget {
  const StokPage({Key? key}) : super(key: key);

  @override
  State<StokPage> createState() => _StokPageState();
}

class _StokPageState extends State<StokPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StockController stockController = Get.put(StockController());

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    // preload semua filter biar gak delay pas digeser
    stockController.fetchStock(filter: "all");
    stockController.fetchStock(filter: "today");
    stockController.fetchStock(filter: "empty");

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      switch (_tabController.index) {
        case 0:
          stockController.fetchStock(filter: "all");
          break;
        case 1:
          stockController.fetchStock(filter: "today");
          break;
        case 2:
          stockController.fetchStock(filter: "empty");
          break;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manajemen Stok',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff024924),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Semua Stok"),
            Tab(text: "Berkurang Hari Ini"),
            Tab(text: "Stok Habis"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Obx(() => _buildProductList(stockController.allProducts)),
          Obx(() => _buildProductList(stockController.todayProducts)),
          Obx(() => _buildProductList(stockController.emptyProducts)),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Product> items) {
    if (stockController.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada produk yang tersedia.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final product = items[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xffE8F4E8), // soft border
          width: 1,
        ),
      ),
      elevation: 2,
      shadowColor: const Color(0xff024924).withOpacity(0.08),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

        // Product Image
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            '${ApiService.baseUrl}/storage/${product.image}',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.image_not_supported,
                size: 30,
                color: Colors.grey,
              ),
            ),
          ),
        ),

        // Product Name
        title: Text(
          product.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xff024924),
            letterSpacing: -0.3,
          ),
          overflow: TextOverflow.ellipsis,
        ),

        // Subtitle (opsional: kategori, deskripsi, dll)
        subtitle: Text(
          'Stok: ${product.stock}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: product.stock <= 0
                ? Colors.red.withOpacity(0.8)
                : const Color(0xff024924).withOpacity(0.7),
          ),
        ),

        // Stock badge sebagai trailing
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: product.stock <= 0 ? Colors.red : const Color(0xff024924),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            product.stock <= 0 ? "Habis" : "Ada",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        onTap: () {
          Get.to(EditStockPage(product: product));
        },
      ),
    );
  }
}
