import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../core/models/payment.dart';
import '../../services/payment_service.dart';

class AddPaymentMethodWidget extends StatefulWidget {
  final ScrollController scrollController;
  final Function(PaymentMethod) onMethodAdded;

  const AddPaymentMethodWidget({
    Key? key,
    required this.scrollController,
    required this.onMethodAdded,
  }) : super(key: key);

  @override
  State<AddPaymentMethodWidget> createState() => _AddPaymentMethodWidgetState();
}

class _AddPaymentMethodWidgetState extends State<AddPaymentMethodWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  PaymentProvider? _selectedProvider;
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _holderNameController = TextEditingController();
  bool _isLoading = false;
  bool _setAsDefault = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _displayNameController.dispose();
    _phoneController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _holderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_slideController, _fadeController]),
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Handle bar
                  _buildHandleBar(),

                  // Header
                  _buildHeader(),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: widget.scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Provider selection
                            _buildProviderSelection(),

                            const SizedBox(height: 24),

                            // Method details form
                            if (_selectedProvider != null) ...[ 
                              _buildMethodDetailsForm(),

                              const SizedBox(height: 24),

                              // Options
                              _buildOptions(),

                              const SizedBox(height: 32),

                              // Add button
                              _buildAddButton(),
                            ],

                            const SizedBox(height: 20),
                          ],
                        ),
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

  Widget _buildHandleBar() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightGray.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryPink,
                  AppTheme.primaryPink.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add_card,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajouter un moyen de paiement',
                  style: AppTheme.headerStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Choisissez votre fournisseur préféré',
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.lightGray,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: AppTheme.lightGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisir un fournisseur',
          style: AppTheme.subHeaderStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sélectionnez le type de moyen de paiement que vous souhaitez ajouter',
          style: AppTheme.captionStyle.copyWith(
            color: AppTheme.lightGray,
          ),
        ),

        const SizedBox(height: 16),

        // Mobile Money section
        _buildProviderCategory(
          title: 'Mobile Money',
          subtitle: 'Paiements via téléphone mobile',
          icon: Icons.phone_android,
          providers: [
            PaymentProvider.orangeMoney,
            PaymentProvider.mtnMomo,
            PaymentProvider.moovMoney,
            PaymentProvider.wave,
            PaymentProvider.freeMoneyWallet,
          ],
        ),

        const SizedBox(height: 16),

        // Credit Cards section
        _buildProviderCategory(
          title: 'Cartes bancaires',
          subtitle: 'Cartes de crédit et de débit',
          icon: Icons.credit_card,
          providers: [
            PaymentProvider.visa,
            PaymentProvider.mastercard,
          ],
        ),
      ],
    );
  }

  Widget _buildProviderCategory({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<PaymentProvider> providers,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightGray.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.primaryPink,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyTextStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.lightGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: providers.map((provider) {
              final isSelected = _selectedProvider == provider;
              final providerColor = _getProviderColor(provider);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedProvider = provider;
                    _displayNameController.text = provider.name;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? providerColor 
                        : providerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: providerColor.withOpacity(isSelected ? 1.0 : 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getProviderIcon(provider),
                        color: isSelected ? Colors.white : providerColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getProviderDisplayName(provider),
                        style: AppTheme.captionStyle.copyWith(
                          color: isSelected ? Colors.white : providerColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodDetailsForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightGray.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getProviderColor(_selectedProvider!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getProviderIcon(_selectedProvider!),
                  color: _getProviderColor(_selectedProvider!),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Détails ${_getProviderDisplayName(_selectedProvider!)}',
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Display name field
          TextFormField(
            controller: _displayNameController,
            decoration: InputDecoration(
              labelText: 'Nom d\'affichage',
              hintText: 'Mon ${_getProviderDisplayName(_selectedProvider!)}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.label),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez saisir un nom d\'affichage';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Provider-specific fields
          if (_selectedProvider!.name.contains('Money') || 
              _selectedProvider == PaymentProvider.wave ||
              _selectedProvider == PaymentProvider.freeMoneyWallet) ...[ 
            _buildMobileMoneyFields(),
          ] else ...[ 
            _buildCreditCardFields(),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileMoneyFields() {
    return Column(
      children: [
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Numéro de téléphone',
            hintText: _getPhoneHint(_selectedProvider!),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir votre numéro de téléphone';
            }
            if (!PaymentService.validatePhoneNumber(value, _selectedProvider!)) {
              return 'Numéro de téléphone invalide pour ${_getProviderDisplayName(_selectedProvider!)}';
            }
            return null;
          },
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryPink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.primaryPink,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Assurez-vous que ce numéro est associé à votre compte ${_getProviderDisplayName(_selectedProvider!)}',
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.primaryPink,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreditCardFields() {
    return Column(
      children: [
        TextFormField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: 'Numéro de carte',
            hintText: '1234 5678 9012 3456',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.credit_card),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            CardNumberInputFormatter(),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir le numéro de carte';
            }
            final cleaned = value.replaceAll(' ', '');
            if (cleaned.length < 13 || cleaned.length > 16) {
              return 'Numéro de carte invalide';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                decoration: InputDecoration(
                  labelText: 'Expiration',
                  hintText: 'MM/AA',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.calendar_month),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  ExpiryDateInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Exp. requise';
                  }
                  if (value.length < 5) {
                    return 'Format MM/AA';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: _holderNameController,
          decoration: InputDecoration(
            labelText: 'Nom du titulaire',
            hintText: 'Nom comme sur la carte',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.person),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir le nom du titulaire';
            }
            return null;
          },
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.security,
                color: Colors.green,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Vos informations de carte sont sécurisées et cryptées',
                  style: AppTheme.captionStyle.copyWith(
                    color: Colors.green,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightGray.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Options',
            style: AppTheme.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          SwitchListTile(
            title: Text(
              'Définir comme méthode par défaut',
              style: AppTheme.bodyTextStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Utiliser automatiquement pour les futurs paiements',
              style: AppTheme.captionStyle.copyWith(
                color: AppTheme.lightGray,
              ),
            ),
            value: _setAsDefault,
            onChanged: (value) {
              setState(() {
                _setAsDefault = value;
              });
            },
            activeColor: AppTheme.primaryPink,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _addPaymentMethod,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryPink,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Ajouter cette méthode',
                style: AppTheme.bodyTextStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _addPaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final method = PaymentMethod(
        id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
        provider: _selectedProvider!,
        displayName: _displayNameController.text.trim(),
        maskedNumber: _selectedProvider!.name.contains('Money') || 
                      _selectedProvider == PaymentProvider.wave ||
                      _selectedProvider == PaymentProvider.freeMoneyWallet
            ? '****${_phoneController.text.substring(_phoneController.text.length - 4)}'
            : '****${_cardNumberController.text.replaceAll(' ', '').substring(_cardNumberController.text.replaceAll(' ', '').length - 4)}',
        holderName: _holderNameController.text.trim().isNotEmpty 
            ? _holderNameController.text.trim() 
            : null,
        expiryDate: _expiryController.text.isNotEmpty 
            ? _parseExpiryDate(_expiryController.text)
            : null,
        isDefault: _setAsDefault,
        createdAt: DateTime.now(),
        metadata: _selectedProvider!.name.contains('Money') || 
                   _selectedProvider == PaymentProvider.wave ||
                   _selectedProvider == PaymentProvider.freeMoneyWallet
            ? {'phone': _phoneController.text.trim()}
            : {
                'last_four': _cardNumberController.text.replaceAll(' ', '').substring(_cardNumberController.text.replaceAll(' ', '').length - 4),
                'card_type': _selectedProvider == PaymentProvider.visa ? 'visa' : 'mastercard',
              },
      );

      await PaymentService.addPaymentMethod(method);
      widget.onMethodAdded(method);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getProviderDisplayName(_selectedProvider!)} ajouté avec succès'),
            backgroundColor: AppTheme.primaryPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erreur lors de l\'ajout de la méthode'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  DateTime? _parseExpiryDate(String expiry) {
    try {
      final parts = expiry.split('/');
      if (parts.length != 2) return null;
      
      final month = int.parse(parts[0]);
      final year = 2000 + int.parse(parts[1]);
      
      return DateTime(year, month, 1);
    } catch (e) {
      return null;
    }
  }

  String _getPhoneHint(PaymentProvider provider) {
    switch (provider) {
      case PaymentProvider.orangeMoney:
        return '07 12 34 56 78';
      case PaymentProvider.mtnMomo:
        return '06 12 34 56 78';
      case PaymentProvider.moovMoney:
        return '01 12 34 56 78';
      default:
        return '01 23 45 67 89';
    }
  }

  Color _getProviderColor(PaymentProvider provider) {
    switch (provider) {
      case PaymentProvider.orangeMoney:
        return Colors.orange;
      case PaymentProvider.mtnMomo:
        return Colors.yellow.shade700;
      case PaymentProvider.moovMoney:
        return Colors.blue;
      case PaymentProvider.visa:
        return Colors.blue.shade800;
      case PaymentProvider.mastercard:
        return Colors.red;
      case PaymentProvider.wave:
        return Colors.purple;
      case PaymentProvider.freeMoneyWallet:
        return Colors.green;
    }
  }

  IconData _getProviderIcon(PaymentProvider provider) {
    switch (provider) {
      case PaymentProvider.orangeMoney:
        return Icons.phone_android;
      case PaymentProvider.mtnMomo:
        return Icons.phone_android;
      case PaymentProvider.moovMoney:
        return Icons.phone_android;
      case PaymentProvider.visa:
        return Icons.credit_card;
      case PaymentProvider.mastercard:
        return Icons.credit_card;
      case PaymentProvider.wave:
        return Icons.waves;
      case PaymentProvider.freeMoneyWallet:
        return Icons.account_balance_wallet;
    }
  }

  String _getProviderDisplayName(PaymentProvider provider) {
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
}

// Input formatters for card number and expiry date
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.length == 2 && oldValue.text.length == 1) {
      return TextEditingValue(
        text: '$text/',
        selection: const TextSelection.collapsed(offset: 3),
      );
    }
    
    return newValue;
  }
}