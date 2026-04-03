// ============================================================================
// AppResponse — Classe générique pour gérer les retours d'API et les erreurs
// ============================================================================

class AppResponse<T> {
  final T? data;
  final String? error;
  final String? _message;
  final bool isSuccess;

  const AppResponse.success(this.data, {String? message})
      : error = null,
        _message = message,
        isSuccess = true;

  const AppResponse.failure(this.error, {String? message})
      : data = null,
        _message = message,
        isSuccess = false;

  /// Transformation pratique pour la couche UI
  String get message => _message ?? (isSuccess ? 'Opération réussie' : (error ?? 'Une erreur est survenue'));

  @override
  String toString() => isSuccess ? 'Success($data)' : 'Failure($error)';
}
