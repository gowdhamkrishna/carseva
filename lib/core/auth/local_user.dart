import 'package:equatable/equatable.dart';

/// Local user model that replaces FirebaseAuth.User.
/// Stored in shared_preferences as JSON.
class LocalUser extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const LocalUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  factory LocalUser.fromJson(Map<String, dynamic> json) {
    return LocalUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl];
}
