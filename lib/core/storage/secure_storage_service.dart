import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Secure hardware-encrypted local storage service wrapping FlutterSecureStorage.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions:
                  IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: AppConstants.storageAuthToken, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: AppConstants.storageAuthToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.storageRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.storageRefreshToken);
  }

  Future<void> saveWorkspaceId(String workspaceId) async {
    await _storage.write(
        key: AppConstants.storageWorkspaceId, value: workspaceId);
  }

  Future<String?> getWorkspaceId() async {
    return await _storage.read(key: AppConstants.storageWorkspaceId);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: AppConstants.storageUserId, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: AppConstants.storageUserId);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
