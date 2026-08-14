class StudentModel {
  final String id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String gender;
  final String? birthdate;
  final String address;
  final String contact;
  final String email;
  final String? profilePicture;
  final String username;
  final String role;
  final String accountStatus;
  final String? createdAt;
  final String? updatedAt;
  final String? rawName;
  final String? rawPhone;
  final String? rawStatus;

  const StudentModel({
    required this.id,
    this.firstName = '',
    this.middleName = '',
    this.lastName = '',
    this.gender = '',
    this.birthdate,
    this.address = '',
    this.contact = '',
    required this.email,
    this.profilePicture,
    this.username = '',
    this.role = 'student',
    this.accountStatus = 'active',
    this.createdAt,
    this.updatedAt,
    String? name,
    String? phone,
    String? status,
  })  : rawName = name,
        rawPhone = phone,
        rawStatus = status;

  String get name {
    final explicit = rawName;
    if (explicit != null && explicit.isNotEmpty) return explicit;
    final parts = [firstName, middleName, lastName]
        .where((s) => s.trim().isNotEmpty)
        .toList();
    if (parts.isNotEmpty) return parts.join(' ');
    if (username.isNotEmpty) return username;
    return '';
  }

  String get phone => contact.isNotEmpty ? contact : (rawPhone ?? '');

  String get status {
    final raw =
        accountStatus.isNotEmpty ? accountStatus : (rawStatus ?? 'Active');
    if (raw.isEmpty) return 'Active';
    return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      middleName: json['middleName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      birthdate: json['birthdate']?.toString(),
      address: json['address']?.toString() ?? '',
      contact: json['contact']?.toString() ?? json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profilePicture: json['profilePicture']?.toString(),
      username: json['username']?.toString() ?? '',
      role: json['role']?.toString() ?? 'student',
      accountStatus: json['accountStatus']?.toString() ??
          json['status']?.toString() ??
          'active',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
        'gender': gender,
        'birthdate': birthdate,
        'address': address,
        'contact': contact,
        'email': email,
        'profilePicture': profilePicture,
        'username': username,
        'role': role,
        'accountStatus': accountStatus,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
