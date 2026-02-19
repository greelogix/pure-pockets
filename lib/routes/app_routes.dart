abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const ONBOARDING = _Paths.ONBOARDING;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const TRANSACTION_ENTRY = _Paths.TRANSACTION_ENTRY;
  static const GROUP_SPLITTER = _Paths.GROUP_SPLITTER;
  static const REVIEW_EXTRACTION = _Paths.REVIEW_EXTRACTION;
  static const HISTORY = _Paths.HISTORY;
  static const ANALYTICS = _Paths.ANALYTICS;
  static const ALL_MONTHS = _Paths.ALL_MONTH_SUMMARY;
  static const SETTINGS = _Paths.SETTINGS;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const ONBOARDING = '/onboarding';
  static const DASHBOARD = '/dashboard';
  static const TRANSACTION_ENTRY = '/transaction-entry';
  static const GROUP_SPLITTER = '/group-splitter';
  static const REVIEW_EXTRACTION = '/review-extraction';
  static const HISTORY = '/history';
  static const ANALYTICS = '/analytics';
  static const ALL_MONTH_SUMMARY = '/all-month-summary';
  static const SETTINGS = '/settings';
}
