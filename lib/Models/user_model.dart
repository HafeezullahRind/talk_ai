class UserModel {
  final String name;
  final String email;
  final String username;
  //final String? imageUrl; // Changed from image_url to imageUrl
  UserModel({
    required this.email,
    required this.name,
    required this.username, //this.imageUrl});
  });
  // Named constructor for creating an instance from a Map (e.g., from JSON)
  UserModel.fromJson(Map<String, Object?> json)
      : this(
          email: json['name'] as String,
          name: json['email'] as String,
          username: json['username'] as String,
        );

  // Method to convert the object to a JSON-compatible Map
  Map<String, Object?> toJson() {
    return {
      'name': name,
      'email': email,
      'username': username,
      // "Image": imageUrl, // Changed from image_url to imageUrl
    };
  }

  // Override toString for better debugging output
  @override
  String toString() {
    return 'UserModel{name: $name, email: $email, username: $username, }';
  }
}
