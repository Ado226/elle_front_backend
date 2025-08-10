enum PaymentProvider {
  orangeMoney,
  mtnMomo,
  moovMoney,
  visa,
  mastercard,
  wave,
  freeMoneyWallet,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
  expired,
}

enum PaymentType {
  orderPayment,
  subscriptionPayment,
  loyaltyTopup,
  donationPayment,
}

enum TransactionType {
  payment,
  refund,
  reversal,
  cashback,
}

class PaymentMethod {
  final String id;
  final PaymentProvider provider;
  final String displayName;
  final String? maskedNumber;
  final String? holderName;
  final DateTime? expiryDate;
  final bool isDefault;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? lastUsed;
  final bool isActive;

  const PaymentMethod({
    required this.id,
    required this.provider,
    required this.displayName,
    this.maskedNumber,
    this.holderName,
    this.expiryDate,
    this.isDefault = false,
    this.metadata = const {},
    required this.createdAt,
    this.lastUsed,
    this.isActive = true,
  });

  PaymentMethod copyWith({
    String? id,
    PaymentProvider? provider,
    String? displayName,
    String? maskedNumber,
    String? holderName,
    DateTime? expiryDate,
    bool? isDefault,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? lastUsed,
    bool? isActive,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      displayName: displayName ?? this.displayName,
      maskedNumber: maskedNumber ?? this.maskedNumber,
      holderName: holderName ?? this.holderName,
      expiryDate: expiryDate ?? this.expiryDate,
      isDefault: isDefault ?? this.isDefault,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isMobileMoney => [
    PaymentProvider.orangeMoney,
    PaymentProvider.mtnMomo,
    PaymentProvider.moovMoney,
    PaymentProvider.wave,
    PaymentProvider.freeMoneyWallet,
  ].contains(provider);

  bool get isCreditCard => [
    PaymentProvider.visa,
    PaymentProvider.mastercard,
  ].contains(provider);

  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());

  String get providerDisplayName {
    switch (provider) {
      case PaymentProvider.orangeMoney:
        return 'Orange Money';
      case PaymentProvider.mtnMomo:
        return 'MTN Mobile Money';
      case PaymentProvider.moovMoney:
        return 'Moov Money';
      case PaymentProvider.visa:
        return 'Visa';
      case PaymentProvider.mastercard:
        return 'Mastercard';
      case PaymentProvider.wave:
        return 'Wave';
      case PaymentProvider.freeMoneyWallet:
        return 'Free Money Wallet';
    }
  }

  String get providerIcon {
    switch (provider) {
      case PaymentProvider.orangeMoney:
        return 'assets/icons/orange_money.png';
      case PaymentProvider.mtnMomo:
        return 'assets/icons/mtn_momo.png';
      case PaymentProvider.moovMoney:
        return 'assets/icons/moov_money.png';
      case PaymentProvider.visa:
        return 'assets/icons/visa.png';
      case PaymentProvider.mastercard:
        return 'assets/icons/mastercard.png';
      case PaymentProvider.wave:
        return 'assets/icons/wave.png';
      case PaymentProvider.freeMoneyWallet:
        return 'assets/icons/free_money.png';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider.name,
      'displayName': displayName,
      'maskedNumber': maskedNumber,
      'holderName': holderName,
      'expiryDate': expiryDate?.toIso8601String(),
      'isDefault': isDefault,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      provider: PaymentProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => PaymentProvider.orangeMoney,
      ),
      displayName: json['displayName'] as String,
      maskedNumber: json['maskedNumber'] as String?,
      holderName: json['holderName'] as String?,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      isDefault: json['isDefault'] as bool? ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsed: json['lastUsed'] != null
          ? DateTime.parse(json['lastUsed'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class PaymentTransaction {
  final String id;
  final String? orderId;
  final double amount;
  final String currency;
  final PaymentProvider provider;
  final PaymentStatus status;
  final PaymentType type;
  final TransactionType transactionType;
  final String? description;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? processedAt;
  final DateTime? completedAt;
  final String? failureReason;
  final String? externalTransactionId;
  final String? receiptUrl;
  final double? fees;
  final Map<String, dynamic> providerResponse;

  const PaymentTransaction({
    required this.id,
    this.orderId,
    required this.amount,
    this.currency = 'XOF',
    required this.provider,
    required this.status,
    required this.type,
    this.transactionType = TransactionType.payment,
    this.description,
    this.metadata = const {},
    required this.createdAt,
    this.processedAt,
    this.completedAt,
    this.failureReason,
    this.externalTransactionId,
    this.receiptUrl,
    this.fees,
    this.providerResponse = const {},
  });

  PaymentTransaction copyWith({
    String? id,
    String? orderId,
    double? amount,
    String? currency,
    PaymentProvider? provider,
    PaymentStatus? status,
    PaymentType? type,
    TransactionType? transactionType,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? processedAt,
    DateTime? completedAt,
    String? failureReason,
    String? externalTransactionId,
    String? receiptUrl,
    double? fees,
    Map<String, dynamic>? providerResponse,
  }) {
    return PaymentTransaction(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      provider: provider ?? this.provider,
      status: status ?? this.status,
      type: type ?? this.type,
      transactionType: transactionType ?? this.transactionType,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
      externalTransactionId: externalTransactionId ?? this.externalTransactionId,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      fees: fees ?? this.fees,
      providerResponse: providerResponse ?? this.providerResponse,
    );
  }

  bool get isCompleted => status == PaymentStatus.completed;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isPending => status == PaymentStatus.pending;
  bool get isProcessing => status == PaymentStatus.processing;
  bool get canBeRefunded => isCompleted && transactionType == TransactionType.payment;

  double get totalAmount => amount + (fees ?? 0.0);

  String get statusDisplayName {
    switch (status) {
      case PaymentStatus.pending:
        return 'En attente';
      case PaymentStatus.processing:
        return 'En cours';
      case PaymentStatus.completed:
        return 'Terminé';
      case PaymentStatus.failed:
        return 'Échoué';
      case PaymentStatus.cancelled:
        return 'Annulé';
      case PaymentStatus.refunded:
        return 'Remboursé';
      case PaymentStatus.expired:
        return 'Expiré';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case PaymentType.orderPayment:
        return 'Paiement commande';
      case PaymentType.subscriptionPayment:
        return 'Abonnement';
      case PaymentType.loyaltyTopup:
        return 'Recharge points';
      case PaymentType.donationPayment:
        return 'Don';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      'provider': provider.name,
      'status': status.name,
      'type': type.name,
      'transactionType': transactionType.name,
      'description': description,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'failureReason': failureReason,
      'externalTransactionId': externalTransactionId,
      'receiptUrl': receiptUrl,
      'fees': fees,
      'providerResponse': providerResponse,
    };
  }

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] as String,
      orderId: json['orderId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'XOF',
      provider: PaymentProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => PaymentProvider.orangeMoney,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      type: PaymentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentType.orderPayment,
      ),
      transactionType: TransactionType.values.firstWhere(
        (e) => e.name == json['transactionType'],
        orElse: () => TransactionType.payment,
      ),
      description: json['description'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      failureReason: json['failureReason'] as String?,
      externalTransactionId: json['externalTransactionId'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      fees: json['fees'] != null ? (json['fees'] as num).toDouble() : null,
      providerResponse: Map<String, dynamic>.from(json['providerResponse'] as Map? ?? {}),
    );
  }
}

class PaymentRequest {
  final String id;
  final double amount;
  final String currency;
  final PaymentProvider provider;
  final PaymentType type;
  final String? description;
  final String? orderId;
  final String? customerPhone;
  final String? customerEmail;
  final Map<String, dynamic> metadata;
  final DateTime expiresAt;

  const PaymentRequest({
    required this.id,
    required this.amount,
    this.currency = 'XOF',
    required this.provider,
    required this.type,
    this.description,
    this.orderId,
    this.customerPhone,
    this.customerEmail,
    this.metadata = const {},
    required this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'provider': provider.name,
      'type': type.name,
      'description': description,
      'orderId': orderId,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'metadata': metadata,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'XOF',
      provider: PaymentProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => PaymentProvider.orangeMoney,
      ),
      type: PaymentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentType.orderPayment,
      ),
      description: json['description'] as String?,
      orderId: json['orderId'] as String?,
      customerPhone: json['customerPhone'] as String?,
      customerEmail: json['customerEmail'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}

class PaymentSettings {
  final bool enabled;
  final List<PaymentProvider> enabledProviders;
  final Map<PaymentProvider, double> providerFees;
  final double minAmount;
  final double maxAmount;
  final String defaultCurrency;
  final int transactionTimeoutMinutes;
  final bool requirePhoneVerification;
  final bool enableInstallments;
  final Map<String, dynamic> providerSettings;

  const PaymentSettings({
    this.enabled = true,
    this.enabledProviders = const [
      PaymentProvider.orangeMoney,
      PaymentProvider.mtnMomo,
      PaymentProvider.moovMoney,
      PaymentProvider.visa,
      PaymentProvider.mastercard,
    ],
    this.providerFees = const {},
    this.minAmount = 100.0,
    this.maxAmount = 1000000.0,
    this.defaultCurrency = 'XOF',
    this.transactionTimeoutMinutes = 10,
    this.requirePhoneVerification = false,
    this.enableInstallments = false,
    this.providerSettings = const {},
  });

  PaymentSettings copyWith({
    bool? enabled,
    List<PaymentProvider>? enabledProviders,
    Map<PaymentProvider, double>? providerFees,
    double? minAmount,
    double? maxAmount,
    String? defaultCurrency,
    int? transactionTimeoutMinutes,
    bool? requirePhoneVerification,
    bool? enableInstallments,
    Map<String, dynamic>? providerSettings,
  }) {
    return PaymentSettings(
      enabled: enabled ?? this.enabled,
      enabledProviders: enabledProviders ?? this.enabledProviders,
      providerFees: providerFees ?? this.providerFees,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      transactionTimeoutMinutes: transactionTimeoutMinutes ?? this.transactionTimeoutMinutes,
      requirePhoneVerification: requirePhoneVerification ?? this.requirePhoneVerification,
      enableInstallments: enableInstallments ?? this.enableInstallments,
      providerSettings: providerSettings ?? this.providerSettings,
    );
  }

  bool isProviderEnabled(PaymentProvider provider) {
    return enabled && enabledProviders.contains(provider);
  }

  double getProviderFee(PaymentProvider provider, double amount) {
    final feeRate = providerFees[provider] ?? 0.0;
    return amount * feeRate;
  }

  bool isAmountValid(double amount) {
    return amount >= minAmount && amount <= maxAmount;
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'enabledProviders': enabledProviders.map((p) => p.name).toList(),
      'providerFees': providerFees.map((k, v) => MapEntry(k.name, v)),
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'defaultCurrency': defaultCurrency,
      'transactionTimeoutMinutes': transactionTimeoutMinutes,
      'requirePhoneVerification': requirePhoneVerification,
      'enableInstallments': enableInstallments,
      'providerSettings': providerSettings,
    };
  }

  factory PaymentSettings.fromJson(Map<String, dynamic> json) {
    return PaymentSettings(
      enabled: json['enabled'] as bool? ?? true,
      enabledProviders: (json['enabledProviders'] as List? ?? [])
          .map((name) => PaymentProvider.values.firstWhere(
                (e) => e.name == name,
                orElse: () => PaymentProvider.orangeMoney,
              ))
          .toList(),
      providerFees: (json['providerFees'] as Map? ?? {}).map(
        (k, v) => MapEntry(
          PaymentProvider.values.firstWhere(
            (e) => e.name == k,
            orElse: () => PaymentProvider.orangeMoney,
          ),
          (v as num).toDouble(),
        ),
      ),
      minAmount: (json['minAmount'] as num?)?.toDouble() ?? 100.0,
      maxAmount: (json['maxAmount'] as num?)?.toDouble() ?? 1000000.0,
      defaultCurrency: json['defaultCurrency'] as String? ?? 'XOF',
      transactionTimeoutMinutes: json['transactionTimeoutMinutes'] as int? ?? 10,
      requirePhoneVerification: json['requirePhoneVerification'] as bool? ?? false,
      enableInstallments: json['enableInstallments'] as bool? ?? false,
      providerSettings: Map<String, dynamic>.from(json['providerSettings'] as Map? ?? {}),
    );
  }
}