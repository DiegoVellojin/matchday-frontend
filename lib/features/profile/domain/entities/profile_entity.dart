class UserProfileEntity {
  final int id;
  final String name;
  final String email;
  final String role;
  final double rating;
  final String? photoUrl;
  final String? phone;
  final int partidosJugados;
  final int partidosOrganizados;

  const UserProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.rating,
    required this.partidosJugados,
    required this.partidosOrganizados,
    this.photoUrl,
    this.phone,
  });
}
