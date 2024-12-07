import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:layout_basics1/pages/shop_page.dart';
import 'dart:convert';
import 'dart:io' show Platform;

import 'product_details_page.dart'; // Import ProductDetailsPage
import 'app_bar.dart'; // Import buildAppBar function

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  List<dynamic> products = [];
  List<dynamic> categories = [];
  // ignore: non_constant_identifier_names
  String mapping_string =
      'http://localhost:5000'; // the web mapping string is by default

  @override
  void initState() {
    super.initState();

    if (isAndroid()) {
      mapping_string = 'http://10.0.2.2:5000';
    }

    _loadProductData();
    _loadCatalogData();
  }

  // Checks for the platform if its on Android
  bool isAndroid() {
    if (kIsWeb) {
      return false;
    } else {
      return Platform.isAndroid;
    }
  }

  // Load product data from JSON
  Future<void> _loadProductData() async {
    final response =
        await http.get(Uri.parse('$mapping_string/api/products/featured'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        products = data['products'];
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Load category data from JSON
  Future<void> _loadCatalogData() async {
    // Catalog == Category
    try {
      // Perform the GET request to fetch catalog data from the API
      final response =
          await http.get(Uri.parse('$mapping_string/api/products/catalog'));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final data = json.decode(response.body);
        setState(() {
          categories = data[
              'categories']; // Assuming the API response has a 'categories' key
        });
      } else {
        // Handle non-200 status codes
        throw Exception('Failed to load catalog data: ${response.statusCode}');
      }
    } catch (error) {
      // Fallback: Load data from a local JSON file if API fails
      try {
        final String fallbackResponse =
            await rootBundle.loadString('assets/data-ctlg.json');
        final fallbackData = json.decode(fallbackResponse);
        setState(() {
          categories = fallbackData['categories'];
        });
      } catch (fallbackError) {
        // Log or rethrow if fallback also fails
        print('Error loading fallback catalog data: $fallbackError');
        throw Exception('Failed to load catalog data from API and fallback.');
      }
    }
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 300,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 300,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildCategoryCard(String category, String imageAsset) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ShopPage(
                      appBarBuilder: buildAppBar,
                      category: category,
                    )));
      },
      child: Card(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 15),
              Image.network(
                imageAsset,
                width: 30,
                height: 30,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons
                      .error); // Show an error icon in case image fails to load
                },
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {},
                child: Text(category,
                    style: TextStyle(fontSize: 16.0, color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double cardHeight = screenHeight * 0.4;
    double cardWidth = screenWidth * 0.45;

    var isSmallScreen = screenWidth < 750;

    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250.0,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      'https://i.ibb.co/L6h1vcq/Database-VS-File-System-Copy.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Shop Latest Apparel',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: cardHeight,
              child: Stack(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 50),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            var product = products[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsPage(
                                      productName: product['name'],
                                      productDescription:
                                          product['description'],
                                      productImage: product['image'],
                                      productPrice: product['price'],
                                      productId: product['id'],
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Container(
                                  width: cardWidth,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.network(
                                            product['image'],
                                            fit: BoxFit.contain,
                                            width: double.infinity,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(Icons
                                                  .error); // Show an error icon in case image fails to load
                                            },
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              product['name'],
                                              style: const TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              '\$${product['price']}',
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 50),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    top: cardHeight / 2 - 25,
                    child: FloatingActionButton(
                      backgroundColor: Colors.black,
                      mini: true,
                      onPressed: _scrollLeft,
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: cardHeight / 2 - 25,
                    child: FloatingActionButton(
                      backgroundColor: Colors.black,
                      mini: true,
                      onPressed: _scrollRight,
                      child:
                          const Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Shop by Category',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isSmallScreen ? 2.5 : 6.5,
                //children: List.generate(categories.length - 12, (index) {
                children: List.generate(4, (index) {
                  var category = categories[index];
                  return _buildCategoryCard(
                      category['name'], category['image']);
                }),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              color: Colors.grey[900],
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'About Us',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'StyleHiveeeeeee is your go-to destination for the latest trends in fashion. We are dedicated to bringing you the most stylish, sustainable, and affordable apparel.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Contact Us',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.facebook,
                            color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.twitter,
                            color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.instagram,
                            color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// End of Main Landing Page class
