import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/product.dart';
import '../core/models/order.dart';

class ShopService {
  static const String _cartKey = 'shopping_cart';
  static const String _favoritesKey = 'favorite_products';
  static const String _ordersKey = 'user_orders';
  static const String _addressesKey = 'shipping_addresses';

  // Sample product data for demonstration
  static List<Product> _sampleProducts = [
    Product(
      id: '1',
      name: 'Serviettes hygiéniques bio',
      description: 'Serviettes hygiéniques 100% coton bio, douces et absorbantes. Pack de 10 unités.',
      price: 2500,
      imageUrls: ['https://example.com/product1.jpg'],
      category: ProductCategory.hygiene,
      type: ProductType.physical,
      isInStock: true,
      stockQuantity: 50,
      rating: 4.5,
      reviewCount: 23,
      tags: ['bio', 'coton', 'hygiène'],
      brand: 'Elles Care',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Product(
      id: '2',
      name: 'Cup menstruelle en silicone',
      description: 'Cup menstruelle en silicone médical, réutilisable jusqu\'à 10 ans. Taille M.',
      price: 15000,
      imageUrls: ['https://example.com/product2.jpg'],
      category: ProductCategory.hygiene,
      type: ProductType.physical,
      isInStock: true,
      stockQuantity: 25,
      rating: 4.8,
      reviewCount: 45,
      tags: ['écologique', 'réutilisable', 'silicone'],
      brand: 'EcoFemme',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    Product(
      id: '3',
      name: 'Préservatifs ultra-fins',
      description: 'Préservatifs ultra-fins pour une sensation naturelle. Boîte de 12.',
      price: 3000,
      imageUrls: ['https://example.com/product3.jpg'],
      category: ProductCategory.contraception,
      type: ProductType.physical,
      isInStock: true,
      stockQuantity: 100,
      rating: 4.2,
      reviewCount: 78,
      tags: ['protection', 'contraception', 'ultra-fin'],
      brand: 'SafeLove',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Product(
      id: '4',
      name: 'Complément fer et vitamines',
      description: 'Complément alimentaire spécialement formulé pour les femmes. Riche en fer et vitamines B.',
      price: 8500,
      imageUrls: ['https://example.com/product4.jpg'],
      category: ProductCategory.supplements,
      type: ProductType.physical,
      isInStock: true,
      stockQuantity: 30,
      rating: 4.6,
      reviewCount: 34,
      tags: ['vitamines', 'fer', 'santé'],
      brand: 'VitaFemme',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Product(
      id: '5',
      name: 'Guide d\'éducation sexuelle',
      description: 'Guide complet sur la santé reproductive et la sexualité féminine. Format PDF.',
      price: 5000,
      imageUrls: ['https://example.com/product5.jpg'],
      category: ProductCategory.education,
      type: ProductType.digital,
      isInStock: true,
      stockQuantity: 999,
      rating: 4.9,
      reviewCount: 156,
      tags: ['éducation', 'numérique', 'santé'],
      brand: 'Elles Academy',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Product(
      id: '6',
      name: 'Lubrifiant naturel',
      description: 'Lubrifiant intime à base d\'ingrédients naturels, compatible avec les préservatifs.',
      price: 4500,
      imageUrls: ['https://example.com/product6.jpg'],
      category: ProductCategory.intimacy,
      type: ProductType.physical,
      isInStock: true,
      stockQuantity: 40,
      rating: 4.4,
      reviewCount: 67,
      tags: ['naturel', 'intimité', 'lubrifiant'],
      brand: 'NaturLove',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  // Cart Management
  static Future<List<CartItem>> getCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      
      if (cartJson == null) return [];
      
      final cartData = jsonDecode(cartJson) as List;
      return cartData.map((item) => CartItem.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addToCart(Product product, {int quantity = 1}) async {
    try {
      final cartItems = await getCartItems();
      
      // Check if product already exists in cart
      final existingItemIndex = cartItems.indexWhere((item) => item.product.id == product.id);
      
      if (existingItemIndex != -1) {
        // Update quantity of existing item
        final existingItem = cartItems[existingItemIndex];
        cartItems[existingItemIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        );
      } else {
        // Add new item to cart
        cartItems.add(CartItem(
          product: product,
          quantity: quantity,
          addedAt: DateTime.now(),
        ));
      }
      
      return await _saveCartItems(cartItems);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateCartItemQuantity(String productId, int quantity) async {
    try {
      final cartItems = await getCartItems();
      final itemIndex = cartItems.indexWhere((item) => item.product.id == productId);
      
      if (itemIndex == -1) return false;
      
      if (quantity <= 0) {
        cartItems.removeAt(itemIndex);
      } else {
        cartItems[itemIndex] = cartItems[itemIndex].copyWith(quantity: quantity);
      }
      
      return await _saveCartItems(cartItems);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> removeFromCart(String productId) async {
    try {
      final cartItems = await getCartItems();
      cartItems.removeWhere((item) => item.product.id == productId);
      return await _saveCartItems(cartItems);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_cartKey);
    } catch (e) {
      return false;
    }
  }

  static Future<double> getCartTotal() async {
    final cartItems = await getCartItems();
    return cartItems.fold<double>(0.0, (double total, CartItem item) => total + item.totalPrice);
  }

  static Future<int> getCartItemCount() async {
    final cartItems = await getCartItems();
    return cartItems.fold<int>(0, (int total, CartItem item) => total + item.quantity);
  }

  static Future<bool> _saveCartItems(List<CartItem> cartItems) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(cartItems.map((item) => item.toJson()).toList());
      return await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      return false;
    }
  }

  // Product Management
  static Future<List<Product>> getAllProducts() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _sampleProducts;
  }

  static Future<List<Product>> getProductsByCategory(ProductCategory category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _sampleProducts.where((product) => product.category == category).toList();
  }

  static Future<List<Product>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lowercaseQuery = query.toLowerCase();
    return _sampleProducts.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
             product.description.toLowerCase().contains(lowercaseQuery) ||
             product.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  static Future<Product?> getProductById(String productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _sampleProducts.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Product>> getFeaturedProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _sampleProducts.where((product) => product.rating >= 4.5).toList();
  }

  // Favorites Management
  static Future<List<String>> getFavoriteProductIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_favoritesKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> toggleFavorite(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavoriteProductIds();
      
      if (favorites.contains(productId)) {
        favorites.remove(productId);
      } else {
        favorites.add(productId);
      }
      
      return await prefs.setStringList(_favoritesKey, favorites);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isFavorite(String productId) async {
    final favorites = await getFavoriteProductIds();
    return favorites.contains(productId);
  }

  static Future<List<Product>> getFavoriteProducts() async {
    final favoriteIds = await getFavoriteProductIds();
    final allProducts = await getAllProducts();
    return allProducts.where((product) => favoriteIds.contains(product.id)).toList();
  }

  // Order Management
  static Future<List<Order>> getUserOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_ordersKey);
      
      if (ordersJson == null) return [];
      
      final ordersData = jsonDecode(ordersJson) as List;
      return ordersData.map((order) => Order.fromJson(order)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> createOrder(Order order) async {
    try {
      final orders = await getUserOrders();
      orders.insert(0, order); // Add to beginning
      
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = jsonEncode(orders.map((order) => order.toJson()).toList());
      await prefs.setString(_ordersKey, ordersJson);
      
      // Clear cart after successful order
      await clearCart();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Order?> getOrderById(String orderId) async {
    final orders = await getUserOrders();
    try {
      return orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Address Management
  static Future<List<ShippingAddress>> getShippingAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = prefs.getString(_addressesKey);
      
      if (addressesJson == null) return [];
      
      final addressesData = jsonDecode(addressesJson) as List;
      return addressesData.map((address) => ShippingAddress.fromJson(address)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> saveShippingAddress(ShippingAddress address) async {
    try {
      final addresses = await getShippingAddresses();
      
      // If this is set as default, remove default from others
      if (address.isDefault) {
        for (int i = 0; i < addresses.length; i++) {
          addresses[i] = addresses[i].copyWith(isDefault: false);
        }
      }
      
      addresses.add(address);
      
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = jsonEncode(addresses.map((addr) => addr.toJson()).toList());
      return await prefs.setString(_addressesKey, addressesJson);
    } catch (e) {
      return false;
    }
  }

  static Future<ShippingAddress?> getDefaultShippingAddress() async {
    final addresses = await getShippingAddresses();
    try {
      return addresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  // Utility Methods
  static String generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ORDER_${timestamp}_${(timestamp % 10000).toString().padLeft(4, '0')}';
  }

  static double calculateShippingCost(double subtotal, String city) {
    // Sample shipping calculation
    if (subtotal >= 20000) return 0.0; // Free shipping for orders over 20,000 XOF
    
    switch (city.toLowerCase()) {
      case 'ouagadougou':
      case 'bobo-dioulasso':
        return 1500.0;
      default:
        return 2500.0;
    }
  }

  static double calculateTax(double subtotal) {
    // Sample tax calculation (18% VAT in Burkina Faso)
    return subtotal * 0.18;
  }
}