import 'dart:convert';
import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/utilities/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchResultsPage extends StatefulWidget {
  final String query;
  const SearchResultsPage({Key? key, required this.query}) : super(key: key);

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  List<Product> searchProducts = [];
  bool isLoading = true;

  void initState() {
    super.initState();
    fetchSearchProducts();
  }

  Future<void> fetchSearchProducts() async {
    final response = await http.get(
      Uri.parse('https://dummyjson.com/products/search?q=${widget.query}'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        searchProducts = (data['products'] as List)
            .map<Product>((json) => Product.fromJson(json))
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Results for '${widget.query}'")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : searchProducts.isEmpty
          ? Center(child: Text("No products found"))
          : GridView.builder(
              padding: EdgeInsets.all(10),
              itemCount: searchProducts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final product = searchProducts[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      showProductDetailSheet(context, product);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // image
                        Expanded(
                          child: Image.network(
                            product.imgUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            errorBuilder: (context, _, __) =>
                                const Center(child: Icon(Icons.broken_image)),
                          ),
                        ),
                        // name
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
                          child: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            product.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                        ),
                        // price
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                          child: Text(
                            "\$${product.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
