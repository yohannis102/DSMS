class InstructorsModel {
  final String id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String gender;
  final String? birthdate;
  final String address;
  final String contact;
  final String email;
  final String username;
  final String? drivingExperience;
  final String? profilePicture;
  final String role;
  final String accountStatus;
  final String? vehicleType;
  final int totalStudents;
  final String? createdAt;
  final String? updatedAt;
  final String? rawName;
  final String? rawPhone;
  final String? rawStatus;

  const InstructorsModel({
    required this.id,
    this.firstName = '',
    this.middleName = '',
    this.lastName = '',
    this.gender = '',
    this.birthdate,
    this.address = '',
    this.contact = '',
    required this.email,
    this.username = '',
    this.drivingExperience,
    this.profilePicture,
    this.role = 'instructor',
    this.accountStatus = 'active',
    this.vehicleType,
    this.totalStudents = 0,
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
    return 'Unknown';
  }

  String get phone => contact.isNotEmpty ? contact : (rawPhone ?? '');

  String get status {
    final raw =
        accountStatus.isNotEmpty ? accountStatus : (rawStatus ?? 'Active');
    if (raw.isEmpty) return 'Active';
    return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
  }

  String get displayExperience {
    if (drivingExperience == null || drivingExperience!.trim().isEmpty) {
      return 'Not specified';
    }
    if (drivingExperience!.toLowerCase().contains('year') ||
        drivingExperience!.toLowerCase().contains('yr')) {
      return drivingExperience!;
    }
    return '$drivingExperience yrs';
  }

  factory InstructorsModel.fromJson(Map<String, dynamic> json) {
    int parsedStudents = 0;
    if (json['totalStudents'] != null) {
      parsedStudents = int.tryParse(json['totalStudents'].toString()) ?? 0;
    } else if (json['assignedStudents'] != null) {
      parsedStudents = int.tryParse(json['assignedStudents'].toString()) ?? 0;
    }

    return InstructorsModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      middleName: json['middleName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      birthdate: json['birthdate']?.toString(),
      address: json['address']?.toString() ?? '',
      contact: json['contact']?.toString() ?? json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      drivingExperience: json['drivingExperience']?.toString() ??
          json['experience']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
      role: json['role']?.toString() ?? 'instructor',
      accountStatus: json['accountStatus']?.toString() ??
          json['status']?.toString() ??
          'active',
      vehicleType: json['vehicleType']?.toString() ??
          json['vehicle']?.toString() ??
          'Manual / Automatic',
      totalStudents: parsedStudents,
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
        'username': username,
        'drivingExperience': drivingExperience,
        'profilePicture': profilePicture,
        'role': role,
        'accountStatus': accountStatus,
        'vehicleType': vehicleType,
        'totalStudents': totalStudents,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
