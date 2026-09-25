/// Response shape from POST /auth/login -> {"message": "...", "token": "..."}
class LoginResult {
  final String message;
  final String token;

  LoginResult({required this.message, required this.token});

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      message: json["message"] ?? "",
      token: json["token"] ?? "",
    );
  }
}

/// Response shape from POST /auth/register -> {"message": "...", "user_id": "..."}
class RegisterResult {
  final String message;
  final String userId;

  RegisterResult({required this.message, required this.userId});

  factory RegisterResult.fromJson(Map<String, dynamic> json) {
    return RegisterResult(
      message: json["message"] ?? "",
      userId: json["user_id"]?.toString() ?? "",
    );
  }
}
