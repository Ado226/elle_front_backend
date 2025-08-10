import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/order.dart';
import '../../services/shop_service.dart';

class ShippingAddressForm extends StatefulWidget {
  final ShippingAddress? initialAddress;
  final Function(ShippingAddress) onAddressChanged;

  const ShippingAddressForm({
    Key? key,
    required this.initialAddress,
    required this.onAddressChanged,
  }) : super(key: key);

  @override
  State<ShippingAddressForm> createState() => _ShippingAddressFormState();
}

class _ShippingAddressFormState extends State<ShippingAddressForm>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();

  List<ShippingAddress> _savedAddresses = [];
  ShippingAddress? _selectedAddress;
  bool _useNewAddress = false;
  bool _isLoadingAddresses = true;

  final List<String> _burkinaRegions = [
    'Centre',
    'Boucle du Mouhoun',
    'Cascades',
    'Centre-Est',
    'Centre-Nord',
    'Centre-Ouest',
    'Centre-Sud',
    'Est',
    'Hauts-Bassins',
    'Nord',
    'Plateau-Central',
    'Sahel',
    'Sud-Ouest',
  ];

  final List<String> _majorCities = [
    'Ouagadougou',
    'Bobo-Dioulasso',
    'Koudougou',
    'Banfora',
    'Ouahigouya',
    'Pouytenga',
    'Kaya',
    'Tenkodogo',
    'Orodara',
    'Gaoua',
    'Dédougou',
    'Fada N\'Gourma',
    'Ziniaré',
    'Manga',
    'Réo',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSavedAddresses();
    _initializeForm();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
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

  Future<void> _loadSavedAddresses() async {
    final addresses = await ShopService.getShippingAddresses();
    setState(() {
      _savedAddresses = addresses;
      _isLoadingAddresses = false;
      
      if (addresses.isNotEmpty && widget.initialAddress == null) {
        _selectedAddress = addresses.first;
        widget.onAddressChanged(_selectedAddress!);
      }
    });
  }

  void _initializeForm() {
    if (widget.initialAddress != null) {
      _selectedAddress = widget.initialAddress;
      _fillFormWithAddress(widget.initialAddress!);
    }
  }

  void _fillFormWithAddress(ShippingAddress address) {
    _fullNameController.text = address.fullName;
    _phoneController.text = address.phoneNumber;
    _addressController.text = address.address;
    _cityController.text = address.city;
    _regionController.text = address.region;
  }

  void _clearForm() {
    _fullNameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _cityController.clear();
    _regionController.clear();
  }

  void _validateAndSaveAddress() {
    if (_formKey.currentState!.validate()) {
      final newAddress = ShippingAddress(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        region: _regionController.text.trim(),
        isDefault: _savedAddresses.isEmpty,
      );

      setState(() => _selectedAddress = newAddress);
      widget.onAddressChanged(newAddress);

      // Save to local storage
      ShopService.saveShippingAddress(newAddress);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slideController, _fadeController]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildContent(),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adresse de livraison',
            style: AppTheme.subHeaderStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Choisissez une adresse existante ou ajoutez-en une nouvelle',
            style: AppTheme.captionStyle.copyWith(
              color: AppTheme.lightGray,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Expanded(
            child: _isLoadingAddresses
                ? const Center(child: CircularProgressIndicator())
                : _buildAddressSelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSelector() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saved addresses
          if (_savedAddresses.isNotEmpty) ...[
            Text(
              'Adresses enregistrées',
              style: AppTheme.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ..._savedAddresses.map((address) => _buildAddressCard(address)),
            const SizedBox(height: 16),
          ],

          // New address toggle
          Row(
            children: [
              Checkbox(
                value: _useNewAddress,
                onChanged: (value) {
                  setState(() {
                    _useNewAddress = value ?? false;
                    if (!_useNewAddress && _savedAddresses.isNotEmpty) {
                      _selectedAddress = _savedAddresses.first;
                      widget.onAddressChanged(_selectedAddress!);
                    } else {
                      _clearForm();
                    }
                  });
                },
                activeColor: AppTheme.primaryPink,
              ),
              Text(
                'Utiliser une nouvelle adresse',
                style: AppTheme.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          // New address form
          if (_useNewAddress || _savedAddresses.isEmpty) ...[
            const SizedBox(height: 16),
            _buildAddressForm(),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressCard(ShippingAddress address) {
    final isSelected = _selectedAddress == address && !_useNewAddress;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAddress = address;
          _useNewAddress = false;
        });
        widget.onAddressChanged(address);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPink : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primaryPink.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.fullName,
                    style: AppTheme.bodyTextStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.formattedAddress,
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.lightGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.phoneNumber,
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.lightGray,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryPink : AppTheme.lightGray,
                  width: 2,
                ),
                color: isSelected ? AppTheme.primaryPink : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _fullNameController,
            label: 'Nom complet',
            hint: 'Entrez votre nom complet',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le nom complet est requis';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _phoneController,
            label: 'Numéro de téléphone',
            hint: '+226 XX XX XX XX',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le numéro de téléphone est requis';
              }
              if (value.trim().length < 8) {
                return 'Numéro de téléphone invalide';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _addressController,
            label: 'Adresse',
            hint: 'Rue, quartier, secteur',
            icon: Icons.location_on_outlined,
            maxLines: 2,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'L\'adresse est requise';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          _buildDropdownField(
            value: _cityController.text.isEmpty ? null : _cityController.text,
            label: 'Ville',
            hint: 'Sélectionnez votre ville',
            icon: Icons.location_city_outlined,
            items: _majorCities,
            onChanged: (value) {
              _cityController.text = value ?? '';
              _validateAndSaveAddress();
            },
          ),

          const SizedBox(height: 16),

          _buildDropdownField(
            value: _regionController.text.isEmpty ? null : _regionController.text,
            label: 'Région',
            hint: 'Sélectionnez votre région',
            icon: Icons.map_outlined,
            items: _burkinaRegions,
            onChanged: (value) {
              _regionController.text = value ?? '';
              _validateAndSaveAddress();
            },
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _validateAndSaveAddress,
              style: AppTheme.primaryButtonStyle,
              child: Text(
                'Confirmer l\'adresse',
                style: AppTheme.bodyStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          onChanged: (_) => _validateAndSaveAddress(),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.primaryPink),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.lightGray.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.lightGray.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryPink),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.primaryPink),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.lightGray.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.lightGray.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryPink),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ],
    );
  }
}