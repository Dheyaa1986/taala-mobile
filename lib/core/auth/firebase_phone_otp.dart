import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:taal/core/helpers/phone_helper.dart';

class FirebasePhoneOtpClient {
  String? _verificationId;
  int? _forceResendingToken;

  Future<void> sendSms(String phone) {
    final e164 = PhoneFormatterHelper.normalizeForApi(phone.trim());
    final done = Completer<void>();

    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: e164,
      timeout: const Duration(seconds: 90),
      forceResendingToken: _forceResendingToken,
      verificationCompleted: (_) {
        if (!done.isCompleted) {
          done.complete();
        }
      },
      verificationFailed: (error) {
        if (!done.isCompleted) {
          done.completeError(error);
        }
      },
      codeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _forceResendingToken = resendToken;
        if (!done.isCompleted) {
          done.complete();
        }
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );

    return done.future;
  }

  Future<String> confirmSms(String smsCode) async {
    final verificationId = _verificationId;
    if (verificationId == null || verificationId.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-verification-id',
        message: 'أرسل رمز التحقق أولاً',
      );
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode.trim(),
    );
    final result = await FirebaseAuth.instance.signInWithCredential(credential);
    final token = await result.user?.getIdToken();
    await FirebaseAuth.instance.signOut();
    if (token == null || token.trim().isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-id-token',
        message: 'تعذر تأكيد رمز التحقق',
      );
    }
    return token;
  }
}
