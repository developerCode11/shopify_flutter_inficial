import 'package:flutter/material.dart';
import 'package:shopify_flutter/shopify_flutter.dart';

import 'product_detail_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  List<Product> products = [];
  bool _isLoading = true;

  @override
  void initState() {
    _fetchProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: products.length,
                itemBuilder: (_, int index) =>
                    _buildProductThumbnail(products[index]),
              ),
      ),
    );
  }

  Future<void> _fetchProducts() async {
    final shopifyStore = ShopifyStore.instance;

    final review = await shopifyStore.getCountOfReview(
      apiToken: 'GGXjQo-bjg_t38OdAHbQ3oDbAPQ',
      productId: '8318751768897',
    );
    print(review);

    final bestSellingProducts = await shopifyStore.getNProducts(6,
        sortKey: SortKeyProduct.BEST_SELLING);
    shopifyStore.getCollectionsByIds([
      'gid://shopify/Collection/453095588161',
      'gid://shopify/Collection/453095457089',
      'gid://shopify/Collection/453095620929',
      'gid://shopify/Collection/453095817537',
      'gid://shopify/Collection/453095686465',
      'gid://shopify/Collection/453095752001',
      'gid://shopify/Collection/453096931649',
    ]).then((value) {
      print(value?.length);
    });
    if (mounted) {
      setState(() {
        products = bestSellingProducts ?? [];
        _isLoading = false;
      });
    }
  }

  Widget _buildProductThumbnail(Product product) {
    return InkWell(
      onTap: () => _navigateToProductDetailScreen(product),
      child: Container(
        alignment: Alignment.bottomCenter,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: product.images.isNotEmpty
            ? BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      product.images.first.originalSrc,
                    )))
            : const BoxDecoration(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.bottomCenter,
          child: Text(
            product.title,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _navigateToProductDetailScreen(Product product) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
                  product: product,
                )));
  }
}
