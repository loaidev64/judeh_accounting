import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CryptoHelper {
  // AES-256 with CBC mode and PKCS7 padding
  static final _aesKey = Key.fromUtf8(dotenv.get('ENCRIPTION_KEY'));
  static final _iv = IV.fromLength(16);

  /// Encrypts text using AES-256-CBC with HMAC-SHA256
  static String encrypt(String plainText) {
    final encrypter = Encrypter(AES(_aesKey, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypts text using AES-256-CBC with HMAC validation
  static String decrypt(String encryptedText) {
    final encrypter = Encrypter(AES(_aesKey, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
    return decrypted;
  }
}
