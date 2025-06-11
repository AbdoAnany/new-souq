import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:souq/constants/app_constants.dart';
import 'package:souq/models/cart.dart';
import 'package:souq/models/user.dart';
import 'package:souq/providers/auth_provider.dart';
import 'package:souq/providers/cart_provider.dart';
import 'package:souq/providers/order_provider.dart';
import 'package:souq/screens/order_confirmation_screen.dart';
import 'package:souq/utils/formatter_util.dart';
import 'package:souq/utils/responsive_util.dart';
import 'package:souq/utils/validator.dart';
import 'package:souq/widgets/custom_button.dart';
import 'package:souq/widgets/custom_text_field.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  final ScrollController _scrollController = ScrollController();
  String _selectedPaymentMethod = AppConstants.cashOnDelivery;
  bool _sameAsBillingAddress = true;
  bool _isPlacingOrder = false;

  // Address form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();

  // Shipping address controllers (if different from billing)
  final _shippingFirstNameController = TextEditingController();
  final _shippingLastNameController = TextEditingController();
  final _shippingPhoneController = TextEditingController();
  final _shippingAddressLine1Controller = TextEditingController();
  final _shippingAddressLine2Controller = TextEditingController();
  final _shippingCityController = TextEditingController();
  final _shippingStateController = TextEditingController();
  final _shippingPostalCodeController = TextEditingController();
  final _shippingCountryController = TextEditingController();

  // Payment details
  final _cardNumberController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill user information if available
    _prefillUserInfo();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();

    _shippingFirstNameController.dispose();
    _shippingLastNameController.dispose();
    _shippingPhoneController.dispose();
    _shippingAddressLine1Controller.dispose();
    _shippingAddressLine2Controller.dispose();
    _shippingCityController.dispose();
    _shippingStateController.dispose();
    _shippingPostalCodeController.dispose();
    _shippingCountryController.dispose();

    _cardNumberController.dispose();
    _cardHolderNameController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();

    super.dispose();
  }

  void _prefillUserInfo() {
    final user = ref.read(authProvider).value;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
      // Pre-fill address if available
      if (user.addresses.isNotEmpty) {
        final defaultAddress = user.addresses.first;
        _addressLine1Controller.text = defaultAddress.street;
        _addressLine2Controller.text = '';
        _cityController.text = defaultAddress.city;
        _stateController.text = defaultAddress.state ?? '';
        _postalCodeController.text = defaultAddress.postalCode ?? '';
        _countryController.text = defaultAddress.country;
      }
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Billing Address
        return _formKey.currentState?.validate() ?? false;
      case 1: // Shipping Address
        if (_sameAsBillingAddress) return true;
        return _formKey.currentState?.validate() ?? false;
      case 2: // Payment Method
        if (_selectedPaymentMethod == AppConstants.cashOnDelivery) return true;
        return _formKey.currentState?.validate() ?? false;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 2) {
        setState(() {
          _currentStep++;
        });
        _scrollToTop();
      } else {
        // Place order
        _placeOrder();
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _scrollToTop();
    } else {
      Navigator.pop(context);
    }
  }

  void _scrollToTop() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _placeOrder() async {
    setState(() {
      _isPlacingOrder = true;
    });

    try {
      // Get user ID
      final user = ref.read(authProvider).value;
      if (user == null) {
        throw Exception('You must be logged in to place an order');
      }

      // Get cart from provider
      final cart = ref.read(cartProvider).value;
      if (cart == null || cart.isEmpty) {
        throw Exception('Your cart is empty');
      } // Create shipping address
      final shippingAddress = _sameAsBillingAddress
          ? Address(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              title: 'Billing Address',
              street: _addressLine1Controller.text +
                  (_addressLine2Controller.text.isNotEmpty
                      ? ', ${_addressLine2Controller.text}'
                      : ''),
              addressLine1: _addressLine1Controller.text,
              addressLine2: _addressLine2Controller.text.isNotEmpty
                  ? _addressLine2Controller.text
                  : null,
              city: _cityController.text,
              state: _stateController.text,
              postalCode: _postalCodeController.text,
              country: _countryController.text,
            )
          : Address(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              firstName: _shippingFirstNameController.text,
              lastName: _shippingLastNameController.text,
              title: 'Shipping Address',
              street: _shippingAddressLine1Controller.text +
                  (_shippingAddressLine2Controller.text.isNotEmpty
                      ? ', ${_shippingAddressLine2Controller.text}'
                      : ''),
              addressLine1: _shippingAddressLine1Controller.text,
              addressLine2: _shippingAddressLine2Controller.text.isNotEmpty
                  ? _shippingAddressLine2Controller.text
                  : null,
              city: _shippingCityController.text,
              state: _shippingStateController.text,
              postalCode: _shippingPostalCodeController.text,
              country: _shippingCountryController.text,
            );
      // Create billing address
      final billingAddress = Address(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        title: 'Billing Address',
        street: _addressLine1Controller.text +
            (_addressLine2Controller.text.isNotEmpty
                ? ', ${_addressLine2Controller.text}'
                : ''),
        addressLine1: _addressLine1Controller.text,
        addressLine2: _addressLine2Controller.text.isNotEmpty
            ? _addressLine2Controller.text
            : null,
        city: _cityController.text,
        state: _stateController.text,
        postalCode: _postalCodeController.text,
        country: _countryController.text,
      );

      // Convert payment method string to enum
      PaymentMethod paymentMethod;
      String? paymentId;

      switch (_selectedPaymentMethod) {
        case AppConstants.cashOnDelivery:
          paymentMethod = PaymentMethod.cashOnDelivery;
          break;
        case AppConstants.creditCard:
          paymentMethod = PaymentMethod.creditCard;
          paymentId = _generatePaymentId();
          break;
        default:
          paymentMethod = PaymentMethod.cashOnDelivery;
      }

      // Place order using order provider
      final order = await ref.read(ordersProvider.notifier).placeOrder(
            userId: user.id,
            cart: cart,
            shippingAddress: shippingAddress,
            billingAddress: billingAddress,
            paymentMethod: paymentMethod,
            paymentId: paymentId,
          );

      if (!mounted) return;

      // Navigate to order confirmation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(
            orderId: order.id,
          ),
        ),
      );
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error placing order: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  // Generate a fake payment ID for credit card payments
  String _generatePaymentId() {
    // This would be replaced with a real payment gateway integration
    return 'PAY${DateTime.now().millisecondsSinceEpoch}';
  }

  Widget _buildBillingAddressForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Billing Address",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtil.fontSize(
                      mobile: 20, tablet: 22, desktop: 24),
                ),
          ),
          SizedBox(height: 16.h),

          // Name fields
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _firstNameController,
                  label: AppStrings.firstName,
                  validator: AppValidator.validateName,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomTextField(
                  controller: _lastNameController,
                  label: AppStrings.lastName,
                  validator: AppValidator.validateName,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Contact fields
          CustomTextField(
            controller: _phoneController,
            label: AppStrings.phoneNumber,
            keyboardType: TextInputType.phone,
            validator: AppValidator.validatePhoneNumber,
          ),
          SizedBox(height: 16.h),

          CustomTextField(
            controller: _emailController,
            label: AppStrings.email,
            keyboardType: TextInputType.emailAddress,
            validator: AppValidator.validateEmail,
          ),
          SizedBox(height: 16.h),

          // Address fields
          CustomTextField(
            controller: _addressLine1Controller,
            label: "Address Line 1",
            validator: (value) =>
                AppValidator.validateRequired(value, "Address"),
          ),
          SizedBox(height: 16.h),

          CustomTextField(
            controller: _addressLine2Controller,
            label: "Address Line 2 (Optional)",
          ),
          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _cityController,
                  label: AppStrings.city,
                  validator: AppValidator.validateCity,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomTextField(
                  controller: _stateController,
                  label: "State/Province",
                  validator: (value) =>
                      AppValidator.validateRequired(value, "State"),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _postalCodeController,
                  label: AppStrings.postalCode,
                  keyboardType: TextInputType.number,
                  validator: AppValidator.validatePostalCode,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomTextField(
                  controller: _countryController,
                  label: AppStrings.country,
                  validator: (value) =>
                      AppValidator.validateRequired(value, "Country"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddressForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Shipping Address",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtil.fontSize(
                    mobile: 20, tablet: 22, desktop: 24),
              ),
        ),
        SizedBox(height: 16.h),

        // Same as billing checkbox
        Row(
          children: [
            Checkbox(
              value: _sameAsBillingAddress,
              onChanged: (value) {
                setState(() {
                  _sameAsBillingAddress = value ?? true;
                });
              },
            ),
            const Text("Same as billing address"),
          ],
        ),
        SizedBox(height: 16.h),

        if (!_sameAsBillingAddress)
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Name fields
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _shippingFirstNameController,
                        label: AppStrings.firstName,
                        validator: AppValidator.validateName,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CustomTextField(
                        controller: _shippingLastNameController,
                        label: AppStrings.lastName,
                        validator: AppValidator.validateName,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Contact field
                CustomTextField(
                  controller: _shippingPhoneController,
                  label: AppStrings.phoneNumber,
                  keyboardType: TextInputType.phone,
                  validator: AppValidator.validatePhoneNumber,
                ),
                SizedBox(height: 16.h),

                // Address fields
                CustomTextField(
                  controller: _shippingAddressLine1Controller,
                  label: "Address Line 1",
                  validator: (value) =>
                      AppValidator.validateRequired(value, "Address"),
                ),
                SizedBox(height: 16.h),

                CustomTextField(
                  controller: _shippingAddressLine2Controller,
                  label: "Address Line 2 (Optional)",
                ),
                SizedBox(height: 16.h),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _shippingCityController,
                        label: AppStrings.city,
                        validator: AppValidator.validateCity,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CustomTextField(
                        controller: _shippingStateController,
                        label: "State/Province",
                        validator: (value) =>
                            AppValidator.validateRequired(value, "State"),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _shippingPostalCodeController,
                        label: AppStrings.postalCode,
                        keyboardType: TextInputType.number,
                        validator: AppValidator.validatePostalCode,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CustomTextField(
                        controller: _shippingCountryController,
                        label: AppStrings.country,
                        validator: (value) =>
                            AppValidator.validateRequired(value, "Country"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentMethodForm() {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Method",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize:
                  ResponsiveUtil.fontSize(mobile: 20, tablet: 22, desktop: 24),
            ),
          ),
          SizedBox(height: 16.h),

          // Payment method selection
          _buildPaymentOption(
            AppConstants.cashOnDelivery,
            "Cash on Delivery",
            Icons.payments_outlined,
          ),
          _buildPaymentOption(
            AppConstants.creditCard,
            "Credit Card",
            Icons.credit_card,
          ),

          // Credit card form
          if (_selectedPaymentMethod == AppConstants.creditCard) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(
                  ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _cardNumberController,
                    label: "Card Number",
                    keyboardType: TextInputType.number,
                    validator: AppValidator.validateCreditCard,
                    prefixIcon: const Icon(Icons.credit_card),
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    controller: _cardHolderNameController,
                    label: "Card Holder Name",
                    validator: (value) => AppValidator.validateRequired(
                        value, "Card holder name"),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _expiryDateController,
                          label: "Expiry Date (MM/YY)",
                          keyboardType: TextInputType.number,
                          validator: AppValidator.validateExpiryDate,
                          prefixIcon: const Icon(Icons.date_range),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: CustomTextField(
                          controller: _cvvController,
                          label: "CVV",
                          keyboardType: TextInputType.number,
                          validator: AppValidator.validateCVV,
                          prefixIcon: const Icon(Icons.security),
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = _selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(
            ResponsiveUtil.spacing(mobile: 16, tablet: 18, desktop: 20)),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.primaryColor : theme.iconTheme.color,
              size:
                  ResponsiveUtil.iconSize(mobile: 24, tablet: 28, desktop: 32),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? theme.primaryColor : null,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
              activeColor: theme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final theme = Theme.of(context);
    final cartAsyncValue = ref.watch(cartProvider);

    return cartAsyncValue.when(
      data: (cart) {
        if (cart == null) {
          return const Text("No items in cart");
        }

        return Container(
          padding: EdgeInsets.all(
              ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius:
                BorderRadius.circular(AppConstants.borderRadiusMedium),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.orderSummary,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtil.fontSize(
                          mobile: 18, tablet: 20, desktop: 22),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Edit Cart",
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: ResponsiveUtil.fontSize(
                            mobile: 14, tablet: 15, desktop: 16),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(height: 24.h),

              // Item count
              Text(
                "${cart.items.length} ${cart.items.length == 1 ? 'item' : 'items'} in cart",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: ResponsiveUtil.fontSize(
                      mobile: 14, tablet: 15, desktop: 16),
                ),
              ),
              SizedBox(height: 8.h),
              // Price breakdown
              _buildPriceLine(
                  "Subtotal", FormatterUtil.formatCurrency(cart.subtotal)),
              _buildPriceLine(
                  AppStrings.shipping,
                  cart.shipping > 0
                      ? FormatterUtil.formatCurrency(cart.shipping)
                      : "Free",
                  isFree: cart.shipping == 0),
              _buildPriceLine(
                  AppStrings.tax, FormatterUtil.formatCurrency(cart.tax)),

              Divider(height: 24.h),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.total,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtil.fontSize(
                          mobile: 18, tablet: 20, desktop: 22),
                    ),
                  ),
                  Text(
                    FormatterUtil.formatCurrency(cart.total),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                      fontSize: ResponsiveUtil.fontSize(
                          mobile: 18, tablet: 20, desktop: 22),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          "Error loading cart: $error",
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildPriceLine(String label, String value,
      {bool isDiscount = false, bool isFree = false}) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize:
                  ResponsiveUtil.fontSize(mobile: 14, tablet: 15, desktop: 16),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDiscount || isFree ? Colors.green : null,
              fontSize:
                  ResponsiveUtil.fontSize(mobile: 14, tablet: 15, desktop: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBillingAddressForm();
      case 1:
        return _buildShippingAddressForm();
      case 2:
        return _buildPaymentMethodForm();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.checkout),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _prevStep,
        ),
      ),
      body: Column(
        children: [
          // Stepper indicator
          Container(
            padding: EdgeInsets.symmetric(
                vertical: ResponsiveUtil.spacing(
                    mobile: 16, tablet: 20, desktop: 24)),
            child: Row(
              children: [
                _buildStepIndicator(0, "Billing"),
                _buildStepConnector(0),
                _buildStepIndicator(1, "Shipping"),
                _buildStepConnector(1),
                _buildStepIndicator(2, "Payment"),
              ],
            ),
          ),

          // Step content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(
                  ResponsiveUtil.spacing(mobile: 16, tablet: 20, desktop: 24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current step content
                  _buildStepContent(),

                  SizedBox(height: 24.h),

                  // OrderModel summary
                  _buildOrderSummary(),

                  SizedBox(height: 24.h),

                  // Navigation buttons
                  Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          flex: 1,
                          child: CustomButton(
                            text: "Back",
                            onPressed: _prevStep,
                            isOutlined: true,
                          ),
                        ),
                      if (_currentStep > 0) SizedBox(width: 16.w),
                      Expanded(
                        flex: 2,
                        child: CustomButton(
                          text: _currentStep < 2
                              ? "Continue"
                              : AppStrings.placeOrder,
                          onPressed: _nextStep,
                          isLoading: _isPlacingOrder,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final theme = Theme.of(context);
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: ResponsiveUtil.spacing(mobile: 30, tablet: 36, desktop: 42),
            height: ResponsiveUtil.spacing(mobile: 30, tablet: 36, desktop: 42),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? theme.primaryColor
                  : isActive
                      ? theme.primaryColor.withOpacity(0.8)
                      : Colors.grey[300],
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: ResponsiveUtil.iconSize(
                          mobile: 18, tablet: 20, desktop: 22),
                    )
                  : Text(
                      (step + 1).toString(),
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtil.fontSize(
                            mobile: 14, tablet: 16, desktop: 18),
                      ),
                    ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: isActive || isCompleted
                  ? theme.primaryColor
                  : Colors.grey[600],
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize:
                  ResponsiveUtil.fontSize(mobile: 12, tablet: 13, desktop: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final theme = Theme.of(context);
    final isCompleted = _currentStep > step;

    return Container(
      width: ResponsiveUtil.spacing(mobile: 40, tablet: 50, desktop: 60),
      height: 2.h,
      color: isCompleted ? theme.primaryColor : Colors.grey[300],
    );
  }
}
