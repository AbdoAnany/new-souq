import 'package:equatable/equatable.dart';

// User roles enum
enum UserRole { customer, admin, staff }

// User entity - represents the business logic model
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final bool isEmailVerified;

  const UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profileImageUrl,
    this.role = UserRole.customer,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.isEmailVerified = false,
  });

  // Get full name
  String get fullName => '$firstName $lastName';

  // Check if user is admin
  bool get isAdmin => role == UserRole.admin;

  // Check if user is customer
  bool get isCustomer => role == UserRole.customer;

  // Check if user is staff
  bool get isStaff => role == UserRole.staff;

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phoneNumber,
        profileImageUrl,
        role,
        createdAt,
        updatedAt,
        isActive,
        isEmailVerified,
      ];
}
