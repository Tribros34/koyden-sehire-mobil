enum AuthStatus { unknown, loggedOut, farmerActive, farmerSuspended, admin }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? displayName;
  final String? errorMessage;
  final bool isSubmitting;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.userId,
    this.displayName,
    this.errorMessage,
    this.isSubmitting = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? displayName,
    String? errorMessage,
    bool? isSubmitting,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
