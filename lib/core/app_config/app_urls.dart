class AppUrls {
  const AppUrls._();
  static const String base = 'https://test.com';
  static String imageLink(String image) => '$base$image';
  static const String baseApi = '$base/api';
  static const String _baseApi = base;
  static const String login = '$_baseApi/auth/login';
  static const String registerClient = '$_baseApi/auth/client-register';
  static const String registerCompany = '$_baseApi/auth/company-register';
  static const String logout = '$_baseApi/logout';
  static const String emailVerify = '$_baseApi/email/verify';
  static const String forgetPassword = '$_baseApi/auth/forget-password';
  static const String passwordReset = '$_baseApi/auth/update-password';
  static const String updatePassword = '$_baseApi/updatePassword';
  static const String countries = '$_baseApi/countries';
  static const String sendCode = '$_baseApi/auth/verify-email';
  static const String resendCode = '$_baseApi/email/verify-sent-code';
  static const String verify = '$_baseApi/auth/validate-otp';
  static const String verifyRegister = '$_baseApi/auth/validate-email-otp';
  static const String profile = '$_baseApi/profile';
  static const String refreshToken = '$_baseApi/refresh-token';
  static const String auctionCategories = '$_baseApi/auction/categories';
  static const String locations = '$_baseApi/locations';
  static const String sendSupportTicket = '$_baseApi/support-ticket';
  static const String banners = '$_baseApi/banners';

  //*Auctions
  static const String auctions = '$_baseApi/auction';
  static const String addBid = '$auctions/add-bid';
  static const String myAuctions = '$auctions/contributed';
  static String exitAuction(String id) => '$auctions/$id/exit';
}
