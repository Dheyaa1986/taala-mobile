class AppUrls {
  const AppUrls._();
  static const String base = 'https://taala-back-production.up.railway.app';
  static String imageLink(String image) => '$base$image';
  static const String baseApi = base;
  static const String _baseApi = baseApi;
  static const String clientLogin = '$_baseApi/auth/client/login';
  static const String providerLogin = '$_baseApi/auth/provider/login';
  static const String login = clientLogin;
  static const String registerClient = '$_baseApi/auth/register';
  static const String registerCompany = '$_baseApi/auth/company-register';
  static const String logout = '$_baseApi/logout';
  static const String emailVerify = '$_baseApi/email/verify';
  static const String forgetPassword = '$_baseApi/auth/forget-password';
  static const String passwordReset = '$_baseApi/auth/update-password';
  static const String changePassword = '$_baseApi/auth/change-password';
  static const String updatePassword = '$_baseApi/updatePassword';
  static const String countries = '$_baseApi/countries';
  static const String sendCode = '$_baseApi/auth/verify-email';
  static const String resendCode = '$_baseApi/email/verify-sent-code';
  static const String verify = '$_baseApi/auth/validate-otp';
  static const String verifyRegister = '$_baseApi/auth/validate-email-otp';
  static const String profile = '$_baseApi/profile';
  static const String authMe = '$_baseApi/auth/me';
  static const String notificationsMe = '$_baseApi/notifications/me';
  static const String notificationsUnreadCount =
      '$_baseApi/notifications/me/unread-count';
  static const String notificationsReadAll =
      '$_baseApi/notifications/me/read-all';
  static String notificationRead(String id) =>
      '$_baseApi/notifications/$id/read';
  static String notificationDelete(String id) =>
      '$_baseApi/notifications/$id';
  static const String supportTickets = '$_baseApi/support-tickets';
  static const String themesActive = '/themes/active';
  static const String countriesList = '/countries/list';
  static String governoratesList(String countryId) =>
      '/governorates/list?countryId=$countryId';
  static String citiesList(String governorateId) =>
      '/cities/list?governorateId=$governorateId';
  static String providerLocations(String providerId) =>
      '/providers/$providerId/locations';
  static const String providerLocationsCreate = '/providers/locations';
  static String providerLocation(String providerId, String locationId) =>
      '/providers/$providerId/locations/$locationId';
  static String clientHome(String clientId) => '/home/clients/$clientId/';
  static const String supportTicketsMe = '/support-tickets/me';
  static String supportTicketById(String id) => '/support-tickets/$id';
  static String supportTicketMessages(String id) =>
      '/support-tickets/$id/messages';
  static String supportTicketDelete(String id) => '/support-tickets/$id';
  static const String serviceTypesList = '/service-types/list';
  static const String serviceOrders = '/service-orders';
  static const String serviceOrdersMe = '/service-orders/me';
  static String serviceOrderTracking(String id) =>
      '/service-orders/$id/tracking';
  static String serviceOrderMessages(String id) =>
      '/service-orders/$id/messages';
  static String serviceOrderStatus(String id) =>
      '/service-orders/$id/status';
  static String clientUpdateProfile(String id) => '$_baseApi/clients/$id';
  static const String providerUpdateProfile = '$_baseApi/providers/profile';
  static const String providerLiveLocation = '/providers/live-location';
  static const String refreshToken = '$_baseApi/auth/refresh-token';
  static const String auctionCategories = '$_baseApi/auction/categories';
  static const String locations = '$_baseApi/locations';
  static const String banners = '$_baseApi/banners';

  static const String auctions = '$_baseApi/auction';
  static const String addBid = '$auctions/add-bid';
  static const String myAuctions = '$auctions/contributed';
  static String exitAuction(String id) => '$auctions/$id/exit';
}
