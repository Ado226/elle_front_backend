import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/payment.dart';

class PaymentService {
  static const String _paymentMethodsKey = 'payment_methods';
  static const String _transactionsKey = 'payment_transactions';
  static const String _settingsKey = 'payment_settings';

  // Payment Settings
  static Future<PaymentSettings> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson == null) {
        return const PaymentSettings();
      }
      
      return PaymentSettings.fromJson(jsonDecode(settingsJson));
    } catch (e) {
      return const PaymentSettings();
    }
  }

  static Future<bool> updateSettings(PaymentSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(settings.toJson());
      return await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      return false;
    }
  }

  // Payment Methods Management
  static Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final methodsJson = prefs.getString(_paymentMethodsKey);
      
      if (methodsJson == null) return [];
      
      final methodsData = jsonDecode(methodsJson) as List;
      return methodsData
          .map((data) => PaymentMethod.fromJson(data))
          .where((method) => method.isActive)
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addPaymentMethod(PaymentMethod method) async {
    try {
      final methods = await getPaymentMethods();
      
      // If this is the first method or marked as default, set as default
      if (methods.isEmpty || method.isDefault) {
        // Remove default from other methods
        for (int i = 0; i < methods.length; i++) {
          if (methods[i].isDefault) {
            methods[i] = methods[i].copyWith(isDefault: false);
          }
        }
      }
      
      methods.add(method);
      
      final prefs = await SharedPreferences.getInstance();
      final methodsJson = jsonEncode(methods.map((m) => m.toJson()).toList());
      return await prefs.setString(_paymentMethodsKey, methodsJson);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updatePaymentMethod(PaymentMethod method) async {
    try {
      final methods = await getPaymentMethods();
      final index = methods.indexWhere((m) => m.id == method.id);
      
      if (index == -1) return false;
      
      // If setting as default, remove default from others
      if (method.isDefault) {
        for (int i = 0; i < methods.length; i++) {
          if (i != index && methods[i].isDefault) {
            methods[i] = methods[i].copyWith(isDefault: false);
          }
        }
      }
      
      methods[index] = method;
      
      final prefs = await SharedPreferences.getInstance();
      final methodsJson = jsonEncode(methods.map((m) => m.toJson()).toList());
      return await prefs.setString(_paymentMethodsKey, methodsJson);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> removePaymentMethod(String methodId) async {
    try {
      final methods = await getPaymentMethods();
      final removedMethod = methods.firstWhere(
        (m) => m.id == methodId,
        orElse: () => throw Exception('Method not found'),
      );
      
      methods.removeWhere((m) => m.id == methodId);
      
      // If removed method was default, set first remaining as default
      if (removedMethod.isDefault && methods.isNotEmpty) {
        methods[0] = methods[0].copyWith(isDefault: true);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final methodsJson = jsonEncode(methods.map((m) => m.toJson()).toList());
      return await prefs.setString(_paymentMethodsKey, methodsJson);
    } catch (e) {
      return false;
    }
  }

  static Future<PaymentMethod?> getDefaultPaymentMethod() async {
    final methods = await getPaymentMethods();
    return methods.firstWhere(
      (method) => method.isDefault,
      orElse: () => methods.isNotEmpty ? methods.first : throw Exception('No methods'),
    );
  }

  // Transaction Management
  static Future<List<PaymentTransaction>> getTransactions({
    PaymentStatus? status,
    PaymentProvider? provider,
    int? limit,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = prefs.getString(_transactionsKey);
      
      if (transactionsJson == null) return [];
      
      final transactionsData = jsonDecode(transactionsJson) as List;
      var transactions = transactionsData
          .map((data) => PaymentTransaction.fromJson(data))
          .toList();
      
      // Apply filters
      if (status != null) {
        transactions = transactions.where((t) => t.status == status).toList();
      }
      
      if (provider != null) {
        transactions = transactions.where((t) => t.provider == provider).toList();
      }
      
      // Sort by creation date (newest first)
      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      if (limit != null && transactions.length > limit) {
        transactions = transactions.take(limit).toList();
      }
      
      return transactions;
    } catch (e) {
      return [];
    }
  }

  static Future<bool> saveTransaction(PaymentTransaction transaction) async {
    try {
      final transactions = await getTransactions();
      
      // Update existing or add new
      final existingIndex = transactions.indexWhere((t) => t.id == transaction.id);
      if (existingIndex != -1) {
        transactions[existingIndex] = transaction;
      } else {
        transactions.insert(0, transaction);
      }
      
      // Keep only last 200 transactions
      if (transactions.length > 200) {
        transactions.removeRange(200, transactions.length);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = jsonEncode(
        transactions.map((t) => t.toJson()).toList()
      );
      
      return await prefs.setString(_transactionsKey, transactionsJson);
    } catch (e) {
      return false;
    }
  }

  static Future<PaymentTransaction?> getTransaction(String transactionId) async {
    final transactions = await getTransactions();
    try {
      return transactions.firstWhere((t) => t.id == transactionId);
    } catch (e) {
      return null;
    }
  }

  // Payment Processing
  static Future<PaymentTransaction> initiatePayment(PaymentRequest request) async {
    final transaction = PaymentTransaction(
      id: _generateTransactionId(),
      orderId: request.orderId,
      amount: request.amount,
      currency: request.currency,
      provider: request.provider,
      status: PaymentStatus.pending,
      type: request.type,
      description: request.description,
      metadata: Map<String, dynamic>.from(request.metadata),
      createdAt: DateTime.now(),
    );

    await saveTransaction(transaction);
    
    // Simulate provider processing
    _processPaymentAsync(transaction);
    
    return transaction;
  }

  static Future<void> _processPaymentAsync(PaymentTransaction transaction) async {
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Update to processing
    var updatedTransaction = transaction.copyWith(
      status: PaymentStatus.processing,
      processedAt: DateTime.now(),
    );
    await saveTransaction(updatedTransaction);
    
    // Simulate provider response time
    await Future.delayed(Duration(seconds: Random().nextInt(5) + 3));
    
    // Simulate success/failure (90% success rate)
    final isSuccess = Random().nextBool() && Random().nextBool() && Random().nextBool() || Random().nextBool();
    
    if (isSuccess) {
      updatedTransaction = updatedTransaction.copyWith(
        status: PaymentStatus.completed,
        completedAt: DateTime.now(),
        externalTransactionId: _generateExternalId(transaction.provider),
        fees: _calculateFees(transaction.provider, transaction.amount),
        providerResponse: {
          'provider_ref': _generateExternalId(transaction.provider),
          'message': 'Transaction successful',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } else {
      updatedTransaction = updatedTransaction.copyWith(
        status: PaymentStatus.failed,
        completedAt: DateTime.now(),
        failureReason: _getRandomFailureReason(),
        providerResponse: {
          'error_code': 'ERR_${Random().nextInt(999) + 100}',
          'message': 'Transaction failed',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
    
    await saveTransaction(updatedTransaction);
    
    // Update payment method last used if successful
    if (isSuccess) {
      await _updatePaymentMethodLastUsed(transaction.provider);
    }
  }

  static Future<bool> cancelPayment(String transactionId) async {
    final transaction = await getTransaction(transactionId);
    if (transaction == null) return false;
    
    if (transaction.status != PaymentStatus.pending && 
        transaction.status != PaymentStatus.processing) {
      return false;
    }
    
    final cancelledTransaction = transaction.copyWith(
      status: PaymentStatus.cancelled,
      completedAt: DateTime.now(),
    );
    
    return await saveTransaction(cancelledTransaction);
  }

  static Future<PaymentTransaction?> refundPayment(String transactionId, {String? reason}) async {
    final originalTransaction = await getTransaction(transactionId);
    if (originalTransaction == null || !originalTransaction.canBeRefunded) {
      return null;
    }
    
    final refundTransaction = PaymentTransaction(
      id: _generateTransactionId(),
      orderId: originalTransaction.orderId,
      amount: originalTransaction.amount,
      currency: originalTransaction.currency,
      provider: originalTransaction.provider,
      status: PaymentStatus.processing,
      type: originalTransaction.type,
      transactionType: TransactionType.refund,
      description: 'Refund for ${originalTransaction.id}',
      metadata: {
        'original_transaction_id': originalTransaction.id,
        'refund_reason': reason ?? 'Customer request',
        ...originalTransaction.metadata,
      },
      createdAt: DateTime.now(),
      processedAt: DateTime.now(),
    );
    
    await saveTransaction(refundTransaction);
    
    // Simulate refund processing
    await Future.delayed(const Duration(seconds: 3));
    
    final completedRefund = refundTransaction.copyWith(
      status: PaymentStatus.completed,
      completedAt: DateTime.now(),
      externalTransactionId: _generateExternalId(refundTransaction.provider),
    );
    
    await saveTransaction(completedRefund);
    
    // Update original transaction
    final updatedOriginal = originalTransaction.copyWith(
      status: PaymentStatus.refunded,
      metadata: {
        ...originalTransaction.metadata,
        'refund_transaction_id': completedRefund.id,
        'refunded_at': DateTime.now().toIso8601String(),
      },
    );
    
    await saveTransaction(updatedOriginal);
    
    return completedRefund;
  }

  // Utility Methods
  static Future<void> _updatePaymentMethodLastUsed(PaymentProvider provider) async {
    final methods = await getPaymentMethods();
    for (int i = 0; i < methods.length; i++) {
      if (methods[i].provider == provider) {
        methods[i] = methods[i].copyWith(lastUsed: DateTime.now());
        await updatePaymentMethod(methods[i]);
        break;
      }
    }
  }

  static double _calculateFees(PaymentProvider provider, double amount) {
    switch (provider) {
      case PaymentProvider.orangeMoney:
        return amount * 0.02; // 2%
      case PaymentProvider.mtnMomo:
        return amount * 0.015; // 1.5%
      case PaymentProvider.moovMoney:
        return amount * 0.018; // 1.8%
      case PaymentProvider.visa:
        return amount * 0.025; // 2.5%
      case PaymentProvider.mastercard:
        return amount * 0.025; // 2.5%
      case PaymentProvider.wave:
        return amount * 0.01; // 1%
      case PaymentProvider.freeMoneyWallet:
        return amount * 0.005; // 0.5%
    }
  }

  static String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'TXN_${timestamp}_${random.toString().padLeft(6, '0')}';
  }

  static String _generateExternalId(PaymentProvider provider) {
    final random = Random().nextInt(999999999);
    switch (provider) {
      case PaymentProvider.orangeMoney:
        return 'OM${random.toString().padLeft(9, '0')}';
      case PaymentProvider.mtnMomo:
        return 'MT${random.toString().padLeft(9, '0')}';
      case PaymentProvider.moovMoney:
        return 'MV${random.toString().padLeft(9, '0')}';
      case PaymentProvider.visa:
        return 'VS${random.toString().padLeft(9, '0')}';
      case PaymentProvider.mastercard:
        return 'MC${random.toString().padLeft(9, '0')}';
      case PaymentProvider.wave:
        return 'WV${random.toString().padLeft(9, '0')}';
      case PaymentProvider.freeMoneyWallet:
        return 'FM${random.toString().padLeft(9, '0')}';
    }
  }

  static String _getRandomFailureReason() {
    final reasons = [
      'Fonds insuffisants',
      'Compte temporairement bloqué',
      'Numéro de téléphone invalide',
      'Service temporairement indisponible',
      'Limite journalière dépassée',
      'Transaction expirée',
      'Code PIN incorrect',
      'Carte expirée',
      'Erreur de réseau',
      'Transaction rejetée par la banque',
    ];
    return reasons[Random().nextInt(reasons.length)];
  }

  // Validation Methods
  static bool validatePhoneNumber(String phone, PaymentProvider provider) {
    // Remove spaces and special characters
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    switch (provider) {
      case PaymentProvider.orangeMoney:
        // Orange numbers: 07xxxxxxxx, 05xxxxxxxx
        return RegExp(r'^(07|05)\d{8}$').hasMatch(cleanPhone);
      case PaymentProvider.mtnMomo:
        // MTN numbers: 06xxxxxxxx, 05xxxxxxxx
        return RegExp(r'^(06|05)\d{8}$').hasMatch(cleanPhone);
      case PaymentProvider.moovMoney:
        // Moov numbers: 01xxxxxxxx, 02xxxxxxxx
        return RegExp(r'^(01|02)\d{8}$').hasMatch(cleanPhone);
      default:
        return cleanPhone.length >= 8 && cleanPhone.length <= 15;
    }
  }

  static bool validateAmount(double amount) {
    return amount > 0 && amount <= 10000000; // Max 10M XOF
  }

  static String formatAmount(double amount, {String currency = 'XOF'}) {
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: currency == 'XOF' ? 'FCFA' : currency,
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }

  // Sample Data
  static Future<void> createSampleData() async {
    // Sample payment methods
    final sampleMethods = [
      PaymentMethod(
        id: 'pm_orange_001',
        provider: PaymentProvider.orangeMoney,
        displayName: 'Orange Money Principal',
        maskedNumber: '****7890',
        isDefault: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastUsed: DateTime.now().subtract(const Duration(days: 2)),
        metadata: {'phone': '07123457890'},
      ),
      PaymentMethod(
        id: 'pm_mtn_001',
        provider: PaymentProvider.mtnMomo,
        displayName: 'MTN Mobile Money',
        maskedNumber: '****5678',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastUsed: DateTime.now().subtract(const Duration(days: 5)),
        metadata: {'phone': '06123455678'},
      ),
      PaymentMethod(
        id: 'pm_visa_001',
        provider: PaymentProvider.visa,
        displayName: 'Visa ****1234',
        maskedNumber: '****1234',
        holderName: 'Marie Kouassi',
        expiryDate: DateTime(2027, 12, 31),
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        metadata: {'card_type': 'debit'},
      ),
    ];

    for (final method in sampleMethods) {
      await addPaymentMethod(method);
    }

    // Sample transactions
    final sampleTransactions = [
      PaymentTransaction(
        id: 'txn_001',
        orderId: 'ORD_001',
        amount: 15000,
        provider: PaymentProvider.orangeMoney,
        status: PaymentStatus.completed,
        type: PaymentType.orderPayment,
        description: 'Achat produits hygiène',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        processedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 1)),
        completedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 3)),
        externalTransactionId: 'OM123456789',
        fees: 300,
        metadata: {'order_items': 3},
      ),
      PaymentTransaction(
        id: 'txn_002',
        orderId: 'ORD_002',
        amount: 8500,
        provider: PaymentProvider.mtnMomo,
        status: PaymentStatus.failed,
        type: PaymentType.orderPayment,
        description: 'Commande serviettes',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        processedAt: DateTime.now().subtract(const Duration(days: 1, minutes: 1)),
        completedAt: DateTime.now().subtract(const Duration(days: 1, minutes: 2)),
        failureReason: 'Fonds insuffisants',
        metadata: {'order_items': 2},
      ),
      PaymentTransaction(
        id: 'txn_003',
        amount: 25000,
        provider: PaymentProvider.visa,
        status: PaymentStatus.completed,
        type: PaymentType.loyaltyTopup,
        description: 'Recharge points fidélité',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        processedAt: DateTime.now().subtract(const Duration(days: 3, minutes: 1)),
        completedAt: DateTime.now().subtract(const Duration(days: 3, minutes: 4)),
        externalTransactionId: 'VS987654321',
        fees: 625,
        metadata: {'points_added': 250},
      ),
    ];

    for (final transaction in sampleTransactions) {
      await saveTransaction(transaction);
    }
  }

  // Integration with other modules
  static Future<PaymentTransaction?> processOrderPayment({
    required String orderId,
    required double amount,
    required PaymentProvider provider,
    String? customerPhone,
    Map<String, dynamic>? metadata,
  }) async {
    final request = PaymentRequest(
      id: _generateTransactionId(),
      amount: amount,
      provider: provider,
      type: PaymentType.orderPayment,
      description: 'Paiement commande #$orderId',
      orderId: orderId,
      customerPhone: customerPhone,
      metadata: metadata ?? {},
      expiresAt: DateTime.now().add(const Duration(minutes: 15)),
    );

    return await initiatePayment(request);
  }

  static Future<double> calculateTotalWithFees(double amount, PaymentProvider provider) async {
    final fees = _calculateFees(provider, amount);
    return amount + fees;
  }

  static Future<List<PaymentProvider>> getAvailableProviders() async {
    final settings = await getSettings();
    return settings.enabledProviders;
  }
}