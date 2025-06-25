import '../../domain/entities/order_entity.dart';

class ShippingAddressModel extends ShippingAddressEntity {
  const ShippingAddressModel({
    required super.fullName,
    required super.address,
    required super.city,
    required super.state,
    required super.country,
    required super.postalCode,
    super.phoneNumber,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle different field name formats between legacy and new data
      final firstName = json['firstName']?.toString() ?? '';
      final lastName = json['lastName']?.toString() ?? '';
      final fullName = json['fullName']?.toString() ??
          (firstName.isNotEmpty || lastName.isNotEmpty
              ? '$firstName $lastName'.trim()
              : 'Customer Name');

      final address = json['address']?.toString() ??
          json['street']?.toString() ??
          json['addressLine1']?.toString() ??
          'Address not provided';

      final city = json['city']?.toString() ?? 'City not provided';
      final state = json['state']?.toString() ?? 'State not provided';
      final country = json['country']?.toString() ?? 'Country not provided';
      final postalCode = json['postalCode']?.toString() ??
          json['zipCode']?.toString() ??
          'Postal code not provided';
      final phoneNumber = json['phoneNumber']?.toString();

      return ShippingAddressModel(
        fullName: fullName,
        address: address,
        city: city,
        state: state,
        country: country,
        postalCode: postalCode,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      // Return a default shipping address if parsing fails
      return const ShippingAddressModel(
        fullName: 'Customer Name',
        address: 'Address not available',
        city: 'City not available',
        state: 'State not available',
        country: 'Country not available',
        postalCode: 'Postal code not available',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'phoneNumber': phoneNumber,
    };
  }

  factory ShippingAddressModel.fromEntity(ShippingAddressEntity entity) {
    return ShippingAddressModel(
      fullName: entity.fullName,
      address: entity.address,
      city: entity.city,
      state: entity.state,
      country: entity.country,
      postalCode: entity.postalCode,
      phoneNumber: entity.phoneNumber,
    );
  }
}
