import 'package:equatable/equatable.dart';
import 'package:taal/core/app_config/app_urls.dart';

class UserProfileModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final int role;
  final String? imageUrl;
  final bool? providerStatus;
  final bool profileComplete;
  final int orderCount;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    this.imageUrl,
    this.providerStatus,
    this.profileComplete = true,
    this.orderCount = 0,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final response = json['response'] as Map<String, dynamic>? ?? json;
    return UserProfileModel(
      id: response['id']?.toString() ?? '',
      name: response['name']?.toString() ?? '',
      email: response['email']?.toString() ?? '',
      phone: response['phone']?.toString() ?? '',
      address: response['address']?.toString() ?? '',
      role: response['role'] is int
          ? response['role'] as int
          : int.tryParse(response['role']?.toString() ?? '') ?? 0,
      imageUrl: response['imageUrl']?.toString(),
      providerStatus: response['providerStatus'] as bool?,
      profileComplete: response['profileComplete'] == false ? false : true,
      orderCount: response['orderCount'] is int
          ? response['orderCount'] as int
          : int.tryParse(response['orderCount']?.toString() ?? '') ?? 0,
    );
  }

  String get imageLink {
    if (imageUrl == null || imageUrl!.isEmpty) return '';
    if (imageUrl!.startsWith('http')) return imageUrl!;
    return AppUrls.imageLink(imageUrl!);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        address,
        role,
        imageUrl,
        providerStatus,
        profileComplete,
        orderCount,
      ];

  bool get needsProfileCompletion => orderCount >= 1 && !profileComplete;
}
