import 'package:taal/core/app_config/api_base_config.dart';
import 'package:taal/core/app_config/service_types_audience.dart';

class AppUrls {
  const AppUrls._();

  static String get base => ApiBaseConfig.activeBase;
  static String get baseApi => ApiBaseConfig.activeBase;

  static String imageLink(String image) {
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }
    final path = image.startsWith('/') ? image : '/$image';
    return '$base$path';
  }

  static String get clientLogin => '$base/auth/client/login';
  static String get clientLoginPhone => '$base/auth/client/login-phone';
  static String get clientSendOtp => '$base/auth/client/send-otp';
  static String get clientVerifyOtp => '$base/auth/client/verify-otp';
  static String get providerLogin => '$base/auth/provider/login';
  static String get login => clientLogin;
  static String get registerClient => '$base/auth/register';
  static String get registerCompany => '$base/auth/company-register';
  static String get logout => '$base/logout';
  static String get emailVerify => '$base/email/verify';
  static String get forgetPassword => '$base/auth/forget-password';
  static String get passwordReset => '$base/auth/update-password';
  static String get changePassword => '$base/auth/change-password';
  static String get updatePassword => '$base/updatePassword';
  static String get countries => '$base/countries';
  static String get sendCode => '$base/auth/verify-email';
  static String get resendCode => '$base/email/verify-sent-code';
  static String get verify => '$base/auth/validate-otp';
  static String get verifyRegister => '$base/auth/validate-email-otp';
  static String get profile => '$base/profile';
  static String get authMe => '$base/auth/me';
  static String get deleteAccount => '$base/auth/me/account';
  static String get notificationsMe => '$base/notifications/me';
  static String get notificationsUnreadCount =>
      '$base/notifications/me/unread-count';
  static String get notificationsReadAll => '$base/notifications/me/read-all';
  static String get notificationsFcmToken => '$base/notifications/me/fcm-token';
  static String notificationRead(String id) => '$base/notifications/$id/read';
  static String notificationDelete(String id) => '$base/notifications/$id';
  static String get supportTickets => '$base/support-tickets';
  static const String appPublicInfo = '/app/public-info';
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
  static const String guestProviders = '/home/guest/providers';
  static const String guestSendOtp = '/home/guest/send-otp';
  static const String guestHelpRequest = '/home/guest/help-request';
  static const String offlineMapsManifest = '/maps/offline/manifest';
  static String emergencyProviderCallSession(String providerId) =>
      '/emergency/providers/$providerId/call-session';
  static const String supportTicketsMe = '/support-tickets/me';
  static String supportTicketById(String id) => '/support-tickets/$id';
  static String supportTicketMessages(String id) =>
      '/support-tickets/$id/messages';
  static String supportTicketDelete(String id) => '/support-tickets/$id';
  static const String serviceTypesList = '/service-types/list';
  static const String serviceTypesCatalog = '/service-types/catalog';

  static String serviceTypesListFor(ServiceTypesAudience audience) =>
      '$serviceTypesList?audience=${audience.queryValue}';

  static String serviceTypesCatalogFor(ServiceTypesAudience audience) =>
      '$serviceTypesCatalog?audience=${audience.queryValue}';
  static const String serviceOrders = '/service-orders';
  static const String serviceOrdersMe = '/service-orders/me';
  static const String serviceOrdersMeActive = '/service-orders/me/active';
  static String serviceOrderTracking(String id) =>
      '/service-orders/$id/tracking';
  static String serviceOrderMessages(String id) =>
      '/service-orders/$id/messages';
  static String serviceOrderStatus(String id) => '/service-orders/$id/status';
  static String serviceOrderPrice(String id) => '/service-orders/$id/price';
  static String clientUpdateProfile(String id) => '$base/clients/$id';
  static String get providerUpdateProfile => '$base/providers/profile';
  static const String providerLiveLocation = '/providers/live-location';
  static String providerProfile(String id) => '/providers/$id/profile';
  static String providerRate(String id) => '/providers/$id/ratings';
  static const String rateApp = '/ratings/app';
  static const String providerRatingsMe = '/providers/ratings/me';
  static const String subscriptionsMe = '/subscriptions/me';
  static const String subscriptionsPlans = '/subscriptions/plans';
  static const String subscriptionsCheckout = '/subscriptions/checkout';
  static String subscriptionsPaymentStatus(String referenceId) =>
      '/subscriptions/payments/$referenceId/status';
  static const String providerPortfolioCreate = '/providers/portofolio';
  static const String providerPortfolioVideoCreate =
      '/providers/portofolio/video';
  static String providerPortfolioUpdate(String id) =>
      '/providers/portofolio/$id';
  static String providerPortfolioDelete(String id) =>
      '/providers/portofolio/$id';
  static String get refreshToken => '$base/auth/refresh-token';
  static String get auctionCategories => '$base/auction/categories';
  static String get locations => '$base/locations';
  static String get banners => '$base/banners';

  static String get auctions => '$base/auction';
  static String get addBid => '$auctions/add-bid';
  static String get myAuctions => '$auctions/contributed';
  static String exitAuction(String id) => '$auctions/$id/exit';
}
