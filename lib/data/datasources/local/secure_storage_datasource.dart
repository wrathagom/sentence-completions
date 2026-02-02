import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageDatasource {
  static const String _anthropicApiKeyKey = 'anthropic_api_key';

  final FlutterSecureStorage _storage;

  SecureStorageDatasource({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );

  Future<String?> getAnthropicApiKey() async {
    return await _storage.read(key: _anthropicApiKeyKey);
  }

  Future<void> setAnthropicApiKey(String apiKey) async {
    await _storage.write(key: _anthropicApiKeyKey, value: apiKey);
  }

  Future<void> deleteAnthropicApiKey() async {
    await _storage.delete(key: _anthropicApiKeyKey);
  }

  Future<bool> hasAnthropicApiKey() async {
    final key = await _storage.read(key: _anthropicApiKeyKey);
    return key != null && key.isNotEmpty;
  }
}
