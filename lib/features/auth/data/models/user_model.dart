import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? profileImageUrl,
    @JsonKey(unknownEnumValue: UserRole.customer) UserRole role = UserRole.customer,
    required DateTime createdAt,
    DateTime? updatedAt,
    bool isActive = true,
    bool isEmailVerified = false,
  }) : super(
          id: id,
          email: email,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          profileImageUrl: profileImageUrl,
          role: role,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isActive: isActive,
          isEmailVerified: isEmailVerified,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phoneNumber: entity.phoneNumber,
      profileImageUrl: entity.profileImageUrl,
      role: entity.role,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      isEmailVerified: entity.isEmailVerified,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      profileImageUrl: profileImageUrl,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      isEmailVerified: isEmailVerified,
    );
  }
  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isEmailVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
