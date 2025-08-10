enum ProductCategory {
  contraception,
  hygiene,
  supplements,
  intimacy,
  education,
  comfort,
}

enum ProductType {
  physical,
  digital,
  subscription,
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final List<String> imageUrls;
  final ProductCategory category;
  final ProductType type;
  final bool isInStock;
  final int stockQuantity;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final Map<String, dynamic> specifications;
  final bool isDiscrete;
  final String brand;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'XOF',
    required this.imageUrls,
    required this.category,
    required this.type,
    this.isInStock = true,
    this.stockQuantity = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.tags = const [],
    this.specifications = const {},
    this.isDiscrete = true,
    required this.brand,
    required this.createdAt,
    this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? currency,
    List<String>? imageUrls,
    ProductCategory? category,
    ProductType? type,
    bool? isInStock,
    int? stockQuantity,
    double? rating,
    int? reviewCount,
    List<String>? tags,
    Map<String, dynamic>? specifications,
    bool? isDiscrete,
    String? brand,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      type: type ?? this.type,
      isInStock: isInStock ?? this.isInStock,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      tags: tags ?? this.tags,
      specifications: specifications ?? this.specifications,
      isDiscrete: isDiscrete ?? this.isDiscrete,
      brand: brand ?? this.brand,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get categoryDisplayName {
    switch (category) {
      case ProductCategory.contraception:
        return 'Contraception';
      case ProductCategory.hygiene:
        return 'Hygiène';
      case ProductCategory.supplements:
        return 'Compléments';
      case ProductCategory.intimacy:
        return 'Intimité';
      case ProductCategory.education:
        return 'Éducation';
      case ProductCategory.comfort:
        return 'Confort';
    }
  }

  String get categoryEmoji {
    switch (category) {
      case ProductCategory.contraception:
        return '🛡️';
      case ProductCategory.hygiene:
        return '🧼';
      case ProductCategory.supplements:
        return '💊';
      case ProductCategory.intimacy:
        return '💕';
      case ProductCategory.education:
        return '📚';
      case ProductCategory.comfort:
        return '🌸';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case ProductType.physical:
        return 'Produit physique';
      case ProductType.digital:
        return 'Produit numérique';
      case ProductType.subscription:
        return 'Abonnement';
    }
  }

  String get formattedPrice {
    return '${price.toStringAsFixed(0)} $currency';
  }

  bool get isAvailable => isInStock && stockQuantity > 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'imageUrls': imageUrls,
      'category': category.name,
      'type': type.name,
      'isInStock': isInStock,
      'stockQuantity': stockQuantity,
      'rating': rating,
      'reviewCount': reviewCount,
      'tags': tags,
      'specifications': specifications,
      'isDiscrete': isDiscrete,
      'brand': brand,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'XOF',
      imageUrls: List<String>.from(json['imageUrls'] as List),
      category: ProductCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ProductCategory.hygiene,
      ),
      type: ProductType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProductType.physical,
      ),
      isInStock: json['isInStock'] as bool? ?? true,
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      tags: List<String>.from(json['tags'] as List? ?? []),
      specifications: Map<String, dynamic>.from(json['specifications'] as Map? ?? {}),
      isDiscrete: json['isDiscrete'] as bool? ?? true,
      brand: json['brand'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

class CartItem {
  final Product product;
  final int quantity;
  final Map<String, dynamic> selectedOptions;
  final DateTime addedAt;

  const CartItem({
    required this.product,
    required this.quantity,
    this.selectedOptions = const {},
    required this.addedAt,
  });

  CartItem copyWith({
    Product? product,
    int? quantity,
    Map<String, dynamic>? selectedOptions,
    DateTime? addedAt,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  double get totalPrice => product.price * quantity;

  String get formattedTotalPrice => '${totalPrice.toStringAsFixed(0)} ${product.currency}';

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'selectedOptions': selectedOptions,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      selectedOptions: Map<String, dynamic>.from(json['selectedOptions'] as Map? ?? {}),
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }
}

class ProductReview {
  final String id;
  final String userId;
  final String userName;
  final String productId;
  final double rating;
  final String? comment;
  final List<String> imageUrls;
  final bool isVerifiedPurchase;
  final DateTime createdAt;

  const ProductReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.productId,
    required this.rating,
    this.comment,
    this.imageUrls = const [],
    this.isVerifiedPurchase = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'productId': productId,
      'rating': rating,
      'comment': comment,
      'imageUrls': imageUrls,
      'isVerifiedPurchase': isVerifiedPurchase,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      productId: json['productId'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
      isVerifiedPurchase: json['isVerifiedPurchase'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}