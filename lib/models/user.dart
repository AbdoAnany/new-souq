// User roles enum
enum UserRole { customer, admin, employee, staff }

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final List<Address> addresses;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String? fcmToken;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profileImageUrl,
    this.addresses = const [],
    this.role = UserRole.customer,
    required this.createdAt,
    required this.updatedAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.fcmToken,
  });

  // Helper methods for role checking
  bool get isAdmin => role == UserRole.admin;
  bool get isEmployee => role == UserRole.employee || role == UserRole.staff;
  bool get isAdminOrEmployee => isAdmin || isEmployee;
  bool get isCustomer => role == UserRole.customer;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((address) => Address.fromJson(address))
              .toList() ??
          [],
      role: _parseUserRole(json['role']),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      fcmToken: json['fcmToken'],
    );
  }

  static UserRole _parseUserRole(dynamic roleValue) {
    if (roleValue == null) return UserRole.customer;

    if (roleValue is String) {
      switch (roleValue.toLowerCase()) {
        case 'admin':
          return UserRole.admin;
        case 'employee':
        case 'staff':
          return UserRole.employee;
        case 'customer':
        default:
          return UserRole.customer;
      }
    }

    return UserRole.customer;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'addresses': addresses.map((address) => address.toJson()).toList(),
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'fcmToken': fcmToken,
    };
  }

  String get fullName => '$firstName $lastName';

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
    List<Address>? addresses,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? fcmToken,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      addresses: addresses ?? this.addresses,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}

class Address {
  final String id;
  final String title;
  final String street;
  final String city;
  final String? state;
  final String country;
  final String? postalCode;

  final String firstName;
  final String lastName;
  final String addressLine1;
  final String? addressLine2;

  final bool isDefault;
  final double? latitude;
  final double? longitude;

  Address({
    required this.id,
    required this.title,
    required this.street,
    required this.city,
    this.state,
    required this.firstName,
    required this.lastName,
    required this.addressLine1,
    this.addressLine2,
    this.country = "",
    this.postalCode,
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'],
      title: json['title'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postalCode'] ?? '',
      isDefault: json['isDefault'] ?? false,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'firstName': firstName,
      'lastName': lastName,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'isDefault': isDefault,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get fullAddress => '$street, $city, $state, $country $postalCode';

  Address copyWith({
    String? id,
    String? title,
    String? street,
    String? addressLine1,
    String? addressLine2,
    String? firstName,
    String? lastName,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    bool? isDefault,
    double? latitude,
    double? longitude,
  }) {
    return Address(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      title: title ?? this.title,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
