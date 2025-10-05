import 'package:ecommerce_app/pages/cart_page.dart';
import 'package:ecommerce_app/pages/category_page.dart';
import 'package:ecommerce_app/pages/login_page.dart';
import 'package:ecommerce_app/pages/search_results_page.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/models/category.dart';
import 'package:ecommerce_app/utilities/product_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final String? userName;

  const HomePage({super.key, this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<Product> trendingProducts = [];
  bool isLoading = true;
  String? errorMessage;
  String? userFirstName;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final List<Category> categories = [
    Category(
      id: 1,
      name: 'Groceries',
      apiSlug: 'groceries',
      imageUrl: 'https://img.icons8.com/color/96/shopping-basket.png',
    ),
    Category(
      id: 2,
      name: 'Men’s Shirts',
      apiSlug: 'mens-shirts',
      imageUrl: 'https://img.icons8.com/color/96/t-shirt.png',
    ),
    Category(
      id: 3,
      name: 'Men’s Shoes',
      apiSlug: 'mens-shoes',
      imageUrl: 'https://img.icons8.com/color/96/trainers.png',
    ),
    Category(
      id: 4,
      name: 'Smartphones',
      apiSlug: 'smartphones',
      imageUrl: 'https://img.icons8.com/color/96/smartphone.png',
    ),
    Category(
      id: 5,
      name: 'Laptops',
      apiSlug: 'laptops',
      imageUrl: 'https://img.icons8.com/color/96/laptop--v2.png',
    ),
    Category(
      id: 6,
      name: 'Fragrances',
      apiSlug: 'fragrances',
      imageUrl: 'https://img.icons8.com/color/96/perfume-bottle.png',
    ),
    Category(
      id: 7,
      name: 'Furniture',
      apiSlug: 'furniture',
      imageUrl: 'https://img.icons8.com/color/96/sofa.png',
    ),
    Category(
      id: 8,
      name: 'Kitchen',
      apiSlug: 'kitchen-accessories',
      imageUrl: 'https://img.icons8.com/color/96/kitchen-room.png',
    ),
    Category(
      id: 9,
      name: 'Dresses',
      apiSlug: 'womens-dresses',
      imageUrl:
          'https://img.icons8.com/?size=100&id=ewCXC2Zslhwp&format=png&color=000000',
    ),
    Category(
      id: 10,
      name: 'Women’s Shoes',
      apiSlug: 'womens-shoes',
      imageUrl: 'https://img.icons8.com/color/96/womens-shoe.png',
    ),
    Category(
      id: 11,
      name: 'Bags',
      apiSlug: 'womens-bags',
      imageUrl: 'https://img.icons8.com/color/96/purse.png',
    ),
    Category(
      id: 12,
      name: 'Jewellery',
      apiSlug: 'womens-jewellery',
      imageUrl: 'https://img.icons8.com/color/96/diamond.png',
    ),
    Category(
      id: 13,
      name: 'Sunglasses',
      apiSlug: 'sunglasses',
      imageUrl:
          'https://img.icons8.com/?size=100&id=IYyZyQ9av9Vf&format=png&color=000000',
    ),
    Category(
      id: 14,
      name: 'Sports',
      apiSlug: 'sports-accessories',
      imageUrl: 'https://img.icons8.com/color/96/basketball.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchProducts();
    fetchUserName();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.unfocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _searchFocusNode.unfocus();
    }
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('https://dummyjson.com/products'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productJson = data['products'];
        List<Product> products = productJson
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
        products.shuffle();

        if (!mounted) return;
        setState(() {
          trendingProducts = products.take(40).toList();
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage = 'Failed to load products';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (snapshot.exists && snapshot.data() != null) {
          setState(() {
            userFirstName = snapshot['firstName'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching user name: $e");
    }
  }

  void _openCartPage() {
    _searchFocusNode.unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartPage()),
    ).then((_) => _searchFocusNode.unfocus());
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _openCategoryPage(Category category) {
    _searchFocusNode.unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPage(
          categoryName: category.name,
          apiSlug: category.apiSlug,
        ),
      ),
    ).then((_) => _searchFocusNode.unfocus());
  }

  void _openProductDetail(Product p) {
    _searchFocusNode.unfocus();
    showProductDetailSheet(context, p);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String displayName = userFirstName ?? user?.displayName ?? "User";

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 238, 238, 238),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 238, 238, 238),
          elevation: 0.0,
          titleSpacing: 16.0,
          toolbarHeight: 90.0,
          title: RichText(
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: true,
            ),
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Hello,\n',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                    height: 1.3,
                  ),
                ),
                TextSpan(
                  text: displayName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black87, size: 30),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ],
        ),
        endDrawer: Drawer(
          backgroundColor: const Color.fromARGB(255, 238, 238, 238),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 238, 238, 238),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.black87,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (user?.email != null)
                      Text(
                        user!.email!,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart_checkout_rounded),
                title: const Text("My Cart"),
                onTap: () {
                  Navigator.pop(context);
                  _openCartPage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout"),
                onTap: _logout,
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: fetchProducts,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  _buildCategories(),
                  const SizedBox(height: 10),
                  _buildFeaturedProducts(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            _searchFocusNode.unfocus();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchResultsPage(query: value.trim()),
              ),
            ).then((_) {
              _searchController.clear();
              _searchFocusNode.unfocus();
            });
          }
        },
        decoration: InputDecoration(
          hintText: 'Search for products',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search, size: 30.0),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: InkWell(
                  onTap: () => _openCategoryPage(category),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 40,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.network(
                            category.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, _, __) => const Icon(
                              Icons.category,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProducts() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    } else if (errorMessage != null) {
      return Center(
        child: Column(
          children: [
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: fetchProducts,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        itemCount: trendingProducts.length,
        itemBuilder: (context, index) {
          final p = trendingProducts[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openProductDetail(p),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Image.network(
                      p.imgUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder: (context, _, __) =>
                          const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
                    child: Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      p.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                    child: Text(
                      "\$${p.price.toStringAsFixed(2)}",
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
      );
    }
  }
}
