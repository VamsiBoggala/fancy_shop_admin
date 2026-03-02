/// Application-wide constant strings.
class AppConstants {
  AppConstants._();

  static const String appName = 'Fancy Shop Admin';
  static const String appVersion = '1.0.0';

  // ── Route Paths ───────────────────────────────────────────────────────────
  static const String routeLogin = '/login';
  static const String routeDashboard = '/dashboard';
  static const String routeOrders = '/orders';
  static const String routeInventory = '/inventory';
  static const String routeSupport = '/support';
  static const String routeChat = '/chat';
  static const String routeCoupons = '/coupons';
  static const String routeBanners = '/banners';
  static const String routeOffers = '/offers';
  static const String routePopularItems = '/popular-items';

  // ── Firestore Collections ─────────────────────────────────────────────────
  static const String colBrands = 'brands';
  static const String colOrders = 'orders';
  static const String colProducts = 'products';
  static const String colCategories = 'categories';
  static const String colUsers = 'users';
  static const String colCoupons = 'coupons';
  static const String colBanners = 'banners';
  static const String colOffers = 'offers';
  static const String colSupportTickets = 'support_tickets';
  static const String colChats = 'chats';

  // ── Shared Preferences Keys ───────────────────────────────────────────────
  static const String prefThemeMode = 'theme_mode';
  static const String prefAdminUid = 'admin_uid';
}
