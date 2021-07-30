class ServerError {
  String message;

  ServerError(
    this.message,
  );

  factory ServerError.parse(Map<String, dynamic> map) {
    return ServerError(
      map['message'] ?? "Unknown",
    );
  }

  @override
  String toString() {
    return "Error Occured: $message";
  }
}
