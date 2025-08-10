import 'product.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

enum OrderPaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}

enum OrderPaymentMethod {
  orangeMoney,
  moovMoney,
  mtnMoney,
  visa,
  mastercard,
  cashOnDelivery,
}

class ShippingAddress {
  final String fullName;
  final String phoneNumber;
  final String address;
  final String city;
  final String region;
  final String postalCode;
  final String country;
  final bool isDefault;

  const ShippingAddress({
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.region,
    this.postalCode = '',
    this.country = 'Burkina Faso',
    this.isDefault = false,
  });

  ShippingAddress copyWith({
    String? fullName,
    String? phoneNumber,
    String? address,
    String? city,
    String? region,
    String? postalCode,
    String? country,
    bool? isDefault,
  }) {
    return ShippingAddress(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      region: region ?? this.region,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get formattedAddress {
    return '$address, $city, $region${postalCode.isNotEmpty ? ', $postalCode' : ''}, $country';
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'region': region,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
    };
  }

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      region: json['region'] as String,
      postalCode: json['postalCode'] as String? ?? '',
      country: json['country'] as String? ?? 'Burkina Faso',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

class OrderItem {
  final Product product;
  final int quantity;
  final double unitPrice;
  final Map<String, dynamic> selectedOptions;

  const OrderItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
    this.selectedOptions = const {},
  });

  double get totalPrice => unitPrice * quantity;

  String get formattedTotalPrice => '${totalPrice.toStringAsFixed(0)} ${product.currency}';

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'selectedOptions': selectedOptions,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      selectedOptions: Map<String, dynamic>.from(json['selectedOptions'] as Map? ?? {}),
    );
  }
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double shippingCost;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String currency;
  final OrderStatus status;
  final OrderPaymentStatus paymentStatus;
  final OrderPaymentMethod paymentMethod;
  final ShippingAddress shippingAddress;
  final String? notes;
  final String? trackingNumber;
  final bool isDiscretePackaging;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? estimatedDelivery;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    this.shippingCost = 0.0,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    required this.totalAmount,
    this.currency = 'XOF',
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.shippingAddress,
    this.notes,
    this.trackingNumber,
    this.isDiscretePackaging = true,
    required this.createdAt,
    this.updatedAt,
    this.estimatedDelivery,
  });

  Order copyWith({
    String? id,
    String? userId,
    List<OrderItem>? items,
    double? subtotal,
    double? shippingCost,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    String? currency,
    OrderStatus? status,
    OrderPaymentStatus? paymentStatus,
    OrderPaymentMethod? paymentMethod,
    ShippingAddress? shippingAddress,
    String? notes,
    String? trackingNumber,
    bool? isDiscretePackaging,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? estimatedDelivery,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      notes: notes ?? this.notes,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      isDiscretePackaging: isDiscretePackaging ?? this.isDiscretePackaging,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
    );
  }

  String get statusDisplayName {
    switch (status) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.confirmed:
        return 'Confirmée';
      case OrderStatus.processing:
        return 'En traitement';
      case OrderStatus.shipped:
        return 'Expédiée';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
      case OrderStatus.refunded:
        return 'Remboursée';
    }
  }

  String get paymentStatusDisplayName {
    switch (paymentStatus) {
      case OrderPaymentStatus.pending:
        return 'En attente';
      case OrderPaymentStatus.completed:
        return 'Payé';
      case OrderPaymentStatus.failed:
        return 'Échec';
      case OrderPaymentStatus.refunded:
        return 'Remboursé';
    }
  }

  String get paymentMethodDisplayName {
    switch (paymentMethod) {
      case OrderPaymentMethod.orangeMoney:
        return 'Orange Money';
      case OrderPaymentMethod.moovMoney:
        return 'Moov Money';
      case OrderPaymentMethod.mtnMoney:
        return 'MTN Money';
      case OrderPaymentMethod.visa:
        return 'Visa';
      case OrderPaymentMethod.mastercard:
        return 'Mastercard';
      case OrderPaymentMethod.cashOnDelivery:
        return 'Paiement à la livraison';
    }
  }

  String get formattedTotalAmount => '${totalAmount.toStringAsFixed(0)} $currency';

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get canBeCancelled => status == OrderStatus.pending || status == OrderStatus.confirmed;

  bool get isCompleted => status == OrderStatus.delivered;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'currency': currency,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'paymentMethod': paymentMethod.name,
      'shippingAddress': shippingAddress.toJson(),
      'notes': notes,
      'trackingNumber': trackingNumber,
      'isDiscretePackaging': isDiscretePackaging,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['userId'] as String,
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      shippingCost: (json['shippingCost'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'XOF',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: OrderPaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => OrderPaymentStatus.pending,
      ),
      paymentMethod: OrderPaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => OrderPaymentMethod.orangeMoney,
      ),
      shippingAddress: ShippingAddress.fromJson(json['shippingAddress'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
      trackingNumber: json['trackingNumber'] as String?,
      isDiscretePackaging: json['isDiscretePackaging'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      estimatedDelivery: json['estimatedDelivery'] != null 
          ? DateTime.parse(json['estimatedDelivery'] as String)
          : null,
    );
  }
}