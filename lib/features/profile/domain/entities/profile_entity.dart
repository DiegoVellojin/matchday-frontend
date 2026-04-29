class UserProfileEntity {
  final int id;
  final String name;
  final String email;
  final String role;
  final double rating;
  final String? photoUrl;
  final String? phone;

  const UserProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.rating,
    this.photoUrl,
    this.phone,
  });
}
