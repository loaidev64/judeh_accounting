import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CryptoHelper {
  static late final Encrypter _encrypter;

  static void initialize() {
    final keyString = dotenv.get('ENCRYPTION_KEY');

    final aesKey = Key.fromUtf8(keyString);
    _encrypter = Encrypter(AES(aesKey, mode: AESMode.cbc));
  }

  static String encrypt(String plainText) {
    final iv = IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(plainText, iv: iv);
    return "${iv.base64}:${encrypted.base64}";
  }

  static String decrypt(String encryptedText) {
    final parts = encryptedText.split(':');
    final iv = IV.fromBase64(parts[0]);
    return _encrypter.decrypt(Encrypted.fromBase64(parts[1]), iv: iv);
  }
}
