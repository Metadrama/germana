import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ms'),
    Locale('zh'),
    Locale('ta'),
  ];

  static const delegate = _AppLocalizationsDelegate();

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get languageCode {
    final code = locale.languageCode;
    if (supportedLocales.any((supported) => supported.languageCode == code)) {
      return code;
    }
    return 'en';
  }

  String _t(String key) => _localizedValues[languageCode]?[key] ??
      _localizedValues['en']![key] ??
      key;

  String signInError(String domain) =>
      _t('signInError').replaceAll('{domain}', domain);

  String domainActive(String domain) =>
      _t('domainActive').replaceAll('{domain}', domain);

  String modelsFound(int count) =>
      _t('modelsFound').replaceAll('{count}', '$count');

  String daysAgo(int days) =>
      _t('daysAgo').replaceAll('{days}', '$days');

  String arrivingIn(String timeStr) =>
      _t('arrivingIn').replaceAll('{time}', timeStr);

  String greetingForHour(int hour) {
    if (hour < 12) return _t('greetingMorning');
    if (hour < 17) return _t('greetingAfternoon');
    return _t('greetingEvening');
  }

  String get appName => _t('appName');
  String get navRides => _t('navRides');
  String get navHistory => _t('navHistory');
  String get navProfile => _t('navProfile');

  String get signInSubtitle => _t('signInSubtitle');
  String get signInHint => _t('signInHint');
  String get signInContinue => _t('signInContinue');
  String get signInClosedLoop => _t('signInClosedLoop');

  String get permissionsTitle => _t('permissionsTitle');
  String get permissionsSubtitle => _t('permissionsSubtitle');
  String get locationPermissionTitle => _t('locationPermissionTitle');
  String get locationPermissionSubtitle => _t('locationPermissionSubtitle');
  String get notificationsPermissionTitle =>
      _t('notificationsPermissionTitle');
  String get notificationsPermissionSubtitle =>
      _t('notificationsPermissionSubtitle');
  String get browserDebugMockTitle => _t('browserDebugMockTitle');
  String get browserDebugMockDescription => _t('browserDebugMockDescription');
  String get enableMockPermissions => _t('enableMockPermissions');
  String get mockPermissionsEnabled => _t('mockPermissionsEnabled');
  String get continueLabel => _t('continueLabel');

  String get onboardingTitle => _t('onboardingTitle');
  String get onboardingSubtitle => _t('onboardingSubtitle');
  String get nameLabel => _t('nameLabel');
  String get nameHint => _t('nameHint');
  String get phoneLabel => _t('phoneLabel');
  String get phoneHint => _t('phoneHint');
  String get genderLabel => _t('genderLabel');
  String get maleLabel => _t('maleLabel');
  String get femaleLabel => _t('femaleLabel');
  String get enterHome => _t('enterHome');

  String get driverInfo => _t('driverInfo');
  String get editProfile => _t('editProfile');
  String get trips => _t('trips');
  String get rating => _t('rating');
  String get driver => _t('driver');
  String get yourCar => _t('yourCar');
  String get listRide => _t('listRide');
  String get settings => _t('settings');
  String get darkMode => _t('darkMode');
  String get notifications => _t('notifications');
  String get privacySafety => _t('privacySafety');
  String get helpSupport => _t('helpSupport');
  String get language => _t('language');
  String get languageEnglish => _t('languageEnglish');
  String get languageMalay => _t('languageMalay');
  String get languageChinese => _t('languageChinese');
  String get languageTamil => _t('languageTamil');
  String get save => _t('save');
  String get institutionEmail => _t('institutionEmail');
  String get faculty => _t('faculty');

  String get searchHint => _t('searchHint');
  String get destinations => _t('destinations');
  String get allFilter => _t('allFilter');
  String get nowFilter => _t('nowFilter');
  String get scheduledFilter => _t('scheduledFilter');
  String get underFiveFilter => _t('underFiveFilter');
  String get threePlusSeatsFilter => _t('threePlusSeatsFilter');
  String get availableRides => _t('availableRides');
  String get viewAll => _t('viewAll');
  String get manual => _t('manual');
  String get seats => _t('seats');
  String get sexLabel => _t('sexLabel');

  String get historyTitle => _t('historyTitle');
  String get thisMonth => _t('thisMonth');
  String get totalSpent => _t('totalSpent');
  String get refunded => _t('refunded');
  String get receipts => _t('receipts');
  String get today => _t('today');
  String get receiptRoutes => _t('receiptRoutes');
  String get escrowHold => _t('escrowHold');
  String get platformFee => _t('platformFee');
  String get releasedToDriver => _t('releasedToDriver');
  String get refund => _t('refund');

  String get myRidesTitle => _t('myRidesTitle');
  String get upcoming => _t('upcoming');
  String get past => _t('past');
  String get noRidesYet => _t('noRidesYet');
  String get exploreRidesToStart => _t('exploreRidesToStart');
  String get arrived => _t('arrived');
  String get unknownDriver => _t('unknownDriver');

  String get rideDetailsTitle => _t('rideDetailsTitle');
  String get yourDriver => _t('yourDriver');
  String get verifiedIdentity => _t('verifiedIdentity');
  String get pickupLabel => _t('pickupLabel');
  String get distanceLabel => _t('distanceLabel');
  String get carImage => _t('carImage');
  String get pricePerSeat => _t('pricePerSeat');
  String get chat => _t('chat');
  String get phone => _t('phone');
  String get viewRide => _t('viewRide');
  String get departIn => _t('departIn');

  String get paymentTitle => _t('paymentTitle');
  String get amount => _t('amount');
  String get payWith => _t('payWith');
  String get instantPayment => _t('instantPayment');
  String get bankTransfer => _t('bankTransfer');
  String get fuelContribution => _t('fuelContribution');
  String get tollShare => _t('tollShare');
  String get total => _t('total');
  String get confirmPayment => _t('confirmPayment');

  String get securedTitle => _t('securedTitle');
  String get chatDriver => _t('chatDriver');
  String get callDriver => _t('callDriver');
  String get driverReveal => _t('driverReveal');

  String get chooseCar => _t('chooseCar');
  String get saveCar => _t('saveCar');
  String get plateLabel => _t('plateLabel');
  String get colorLabel => _t('colorLabel');
  String get discontinued => _t('discontinued');
  String get modelsFoundLabel => _t('modelsFoundLabel');
  String get sedan => _t('sedan');
  String get hatchback => _t('hatchback');
  String get suv => _t('suv');
  String get mpv => _t('mpv');
  String get pickup => _t('pickup');

  // List Ride Screen (Driver)
  String get listRideScreenTitle => _t('listRideScreenTitle');
  String get listButton => _t('listButton');
  String get fromWhereHint => _t('fromWhereHint');
  String get fromFieldHint => _t('fromFieldHint');
  String get toWhereHint => _t('toWhereHint');
  String get toFieldHint => _t('toFieldHint');
  String get yourCarLabel => _t('yourCarLabel');
  String get fairRateLabel => _t('fairRateLabel');
  String get fuelContributionRon => _t('fuelContributionRon');
  String get tollShareLabel => _t('tollShareLabel');
  String get seatsLabel => _t('seatsLabel');
  String get recommendedPerSeatLabel => _t('recommendedPerSeatLabel');
  String get priceRangeHint => _t('priceRangeHint');
  String get listedSuccessTitle => _t('listedSuccessTitle');
  String get listedSuccessMessage => _t('listedSuccessMessage');
  String get backLabel => _t('backLabel');

  // Vehicle Chooser - Colors
  String get colorWhite => _t('colorWhite');
  String get colorBlack => _t('colorBlack');
  String get colorSilver => _t('colorSilver');
  String get colorGrey => _t('colorGrey');
  String get colorRed => _t('colorRed');
  String get colorBlue => _t('colorBlue');
  String get colorBrown => _t('colorBrown');
  String get colorGold => _t('colorGold');
  String get colorGreen => _t('colorGreen');
  String get colorOrange => _t('colorOrange');
  String get plateHintExample => _t('plateHintExample');

  // Onboarding - Gender
  String get maleButton => _t('maleButton');
  String get femaleButton => _t('femaleButton');

  // Gender labels (for driver/passenger display)
  String get sexMale => _t('sexMale');
  String get sexFemale => _t('sexFemale');

  // Ride card & details
  String get durationLabel => _t('durationLabel');
  String get departureTimeLabel => _t('departureTimeLabel');
  String get perSeatPriceLabel => _t('perSeatPriceLabel');

  // Price breakdown
  String get priceBreakdownTitle => _t('priceBreakdownTitle');
  String get fuelShareLabel => _t('fuelShareLabel');
  String get platformFeeLabel => _t('platformFeeLabel');
  String get maintenanceFeeDescription => _t('maintenanceFeeDescription');

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'Germana',
      'navRides': 'Rides',
      'navHistory': 'History',
      'navProfile': 'Profile',
      'signInSubtitle': 'Sign in to access rides, receipts, and driver profile.',
      'signInHint': 'name@smail.unikl.edu.my',
      'signInError': 'Use your institutional email (@{domain})',
      'signInContinue': 'Continue',
      'signInClosedLoop': 'Closed-loop access for verified campus users only.',
      'permissionsTitle': 'Permissions',
      'permissionsSubtitle': 'We need basic access for nearby ride ranking and booking notifications.',
      'locationPermissionTitle': 'Location (while in use)',
      'locationPermissionSubtitle': 'For distance (km) and pickup relevance.',
      'notificationsPermissionTitle': 'Notifications',
      'notificationsPermissionSubtitle': 'For payment status and designated-time reminders.',
      'browserDebugMockTitle': 'Browser / debug mock',
      'browserDebugMockDescription': 'Use this to bypass OS prompts while running in Edge, Chrome, or other debug sessions.',
      'enableMockPermissions': 'Enable mock permissions',
      'mockPermissionsEnabled': 'Mock permissions enabled',
      'continueLabel': 'Continue',
      'domainActive': 'Active domain: @{domain}',
      'onboardingTitle': 'Complete Profile',
      'onboardingSubtitle': 'Set basic driver info before entering Home.',
      'nameLabel': 'Name',
      'nameHint': 'Full name',
      'phoneLabel': 'Phone',
      'phoneHint': '+60 1X-XXXX XXXX',
      'genderLabel': 'Gender',
      'maleLabel': 'Male',
      'femaleLabel': 'Female',
      'enterHome': 'Enter Home',
      'driverInfo': 'Driver Info',
      'editProfile': 'Edit Profile',
      'trips': 'Trips',
      'rating': 'Rating',
      'driver': 'Driver',
      'yourCar': 'Your car',
      'listRide': 'List Ride',
      'settings': 'Settings',
      'darkMode': 'Dark mode',
      'notifications': 'Notifications',
      'privacySafety': 'Privacy & Safety',
      'helpSupport': 'Help & Support',
      'language': 'Language',
      'languageEnglish': 'English',
      'languageMalay': 'Bahasa Melayu',
      'languageChinese': '中文',
      'languageTamil': 'தமிழ்',
      'save': 'Save',
      'institutionEmail': 'Institutional Email',
      'faculty': 'Faculty',
      'searchHint': 'Where to?',
      'destinations': 'Destinations',
      'allFilter': 'All',
      'nowFilter': 'Now',
      'scheduledFilter': 'Scheduled',
      'underFiveFilter': '< RM5',
      'threePlusSeatsFilter': '3+ seats',
      'availableRides': 'Available rides',
      'viewAll': 'View all',
      'manual': 'Manual',
      'seats': 'seats',
      'sexLabel': 'Sex',
      'historyTitle': 'History',
      'thisMonth': 'This month',
      'totalSpent': 'Total spent',
      'refunded': 'Refunded',
      'receipts': 'Receipts',
      'today': 'Today',
      'receiptRoutes': 'Receipt routes',
      'escrowHold': 'Escrow hold',
      'platformFee': 'Platform fee',
      'releasedToDriver': 'Released to driver',
      'refund': 'Refund',
      'daysAgo': '{days} days ago',
      'myRidesTitle': 'My Rides',
      'upcoming': 'Upcoming',
      'past': 'Past',
      'noRidesYet': 'No rides yet',
      'exploreRidesToStart': 'Explore available rides to get started',
      'arrivingIn': 'Departing in {time}',
      'arrived': 'Arrived',
      'unknownDriver': 'Unknown',
      'rideDetailsTitle': 'Ride Details',
      'yourDriver': 'Your driver',
      'verifiedIdentity': 'Verified identity',
      'pickupLabel': 'Pickup',
      'distanceLabel': 'Distance',
      'carImage': 'Car image',
      'pricePerSeat': 'Price per seat',
      'chat': 'Chat',
      'phone': 'Phone',
      'viewRide': 'View ride',
      'departIn': 'Depart in',
      'paymentTitle': 'Payment',
      'amount': 'Amount',
      'payWith': 'Pay with',
      'instantPayment': 'Instant payment',
      'bankTransfer': 'Bank transfer',
      'fuelContribution': 'Fuel contribution',
      'tollShare': 'Toll share',
      'total': 'Total',
      'confirmPayment': 'Confirm & Pay',
      'securedTitle': 'Seat secured!',
      'chatDriver': 'Chat',
      'callDriver': 'Call',
      'driverReveal': 'Your driver',
      'chooseCar': 'Choose Car',
      'saveCar': 'Save Car',
      'plateLabel': 'Registration No.',
      'colorLabel': 'Color',
      'discontinued': 'Discontinued',
      'modelsFoundLabel': '{count} models found',
      'sedan': 'Sedan',
      'hatchback': 'Hatchback',
      'suv': 'SUV',
      'mpv': 'MPV',
      'pickup': 'Pickup',
      'greetingMorning': 'Good morning',
      'greetingAfternoon': 'Good afternoon',
      'greetingEvening': 'Good evening',
      'modelsFound': '{count} models found',
      // List Ride Screen
      'listRideScreenTitle': 'List Ride',
      'listButton': 'List',
      'fromWhereHint': 'From where?',
      'fromFieldHint': 'From...',
      'toWhereHint': 'To where?',
      'toFieldHint': 'To...',
      'yourCarLabel': 'Your car',
      'fairRateLabel': 'Fair Rate',
      'fuelContributionRon': 'Fuel contribution (RON95)',
      'tollShareLabel': 'Toll share',
      'seatsLabel': 'Seats',
      'recommendedPerSeatLabel': 'Recommended / seat',
      'priceRangeHint': 'Can ask up to +15%',
      'listedSuccessTitle': 'Listed!',
      'listedSuccessMessage': 'Your ride is now visible to passengers',
      'backLabel': 'Back',
      // Vehicle colors
      'colorWhite': 'White',
      'colorBlack': 'Black',
      'colorSilver': 'Silver',
      'colorGrey': 'Grey',
      'colorRed': 'Red',
      'colorBlue': 'Blue',
      'colorBrown': 'Brown',
      'colorGold': 'Gold',
      'colorGreen': 'Green',
      'colorOrange': 'Orange',
      'plateHintExample': 'e.g. WXY 1234',
      // Gender buttons
      'maleButton': 'Male',
      'femaleButton': 'Female',
      // Gender labels
      'sexMale': 'Male',
      'sexFemale': 'Female',
      // Ride card & details
      'durationLabel': 'Duration',
      'departureTimeLabel': 'Departure time',
      'perSeatPriceLabel': '/seat (fair rate + comm)',
      // Price breakdown
      'priceBreakdownTitle': 'Price breakdown',
      'fuelShareLabel': 'Fuel contribution',
      'platformFeeLabel': 'Platform fee',
      'maintenanceFeeDescription': 'Platform maintenance fee',
    },
    'ms': {
      'appName': 'Germana',
      'navRides': 'Perjalanan',
      'navHistory': 'Sejarah',
      'navProfile': 'Profil',
      'signInSubtitle': 'Log masuk untuk akses perjalanan, resit, dan profil pemandu.',
      'signInHint': 'nama@smail.unikl.edu.my',
      'signInError': 'Guna e-mel institusi (@{domain})',
      'signInContinue': 'Teruskan',
      'signInClosedLoop': 'Akses tertutup untuk pengguna kampus yang disahkan sahaja.',
      'permissionsTitle': 'Kebenaran',
      'permissionsSubtitle': 'Kami perlukan akses asas untuk ranking perjalanan berdekatan dan notifikasi tempahan.',
      'locationPermissionTitle': 'Lokasi (semasa digunakan)',
      'locationPermissionSubtitle': 'Untuk jarak (km) dan relevansi pickup.',
      'notificationsPermissionTitle': 'Notifikasi',
      'notificationsPermissionSubtitle': 'Untuk status bayaran dan peringatan masa yang ditetapkan.',
      'browserDebugMockTitle': 'Mock browser / debug',
      'browserDebugMockDescription': 'Guna ini untuk lepas prompt OS semasa run di Edge, Chrome, atau sesi debug lain.',
      'enableMockPermissions': 'Aktifkan kebenaran mock',
      'mockPermissionsEnabled': 'Kebenaran mock diaktifkan',
      'continueLabel': 'Teruskan',
      'domainActive': 'Domain aktif: @{domain}',
      'onboardingTitle': 'Lengkapkan Profil',
      'onboardingSubtitle': 'Set info asas pemandu sebelum masuk ke Home.',
      'nameLabel': 'Nama',
      'nameHint': 'Nama penuh',
      'phoneLabel': 'Telefon',
      'phoneHint': '+60 1X-XXXX XXXX',
      'genderLabel': 'Jantina',
      'maleLabel': 'Lelaki',
      'femaleLabel': 'Perempuan',
      'enterHome': 'Masuk Home',
      'driverInfo': 'Info Pemandu',
      'editProfile': 'Sunting Profil',
      'trips': 'Perjalanan',
      'rating': 'Penilaian',
      'driver': 'Pemandu',
      'yourCar': 'Kereta anda',
      'listRide': 'Senarai Perjalanan',
      'settings': 'Tetapan',
      'darkMode': 'Mod gelap',
      'notifications': 'Notifikasi',
      'privacySafety': 'Privasi & Keselamatan',
      'helpSupport': 'Bantuan & Sokongan',
      'language': 'Bahasa',
      'languageEnglish': 'English',
      'languageMalay': 'Bahasa Melayu',
      'languageChinese': '中文',
      'languageTamil': 'தமிழ்',
      'save': 'Simpan',
      'institutionEmail': 'E-mel Institusi',
      'faculty': 'Fakulti',
      'searchHint': 'Ke mana?',
      'destinations': 'Destinasi',
      'allFilter': 'Semua',
      'nowFilter': 'Sekarang',
      'scheduledFilter': 'Dijadual',
      'underFiveFilter': '< RM5',
      'threePlusSeatsFilter': '3+ Tempat',
      'availableRides': 'Perjalanan tersedia',
      'viewAll': 'Lihat semua',
      'manual': 'Manual',
      'seats': 'tempat',
      'sexLabel': 'Jantina',
      'historyTitle': 'Sejarah',
      'thisMonth': 'Bulan ini',
      'totalSpent': 'Jumlah belanja',
      'refunded': 'Dikembalikan',
      'receipts': 'Resit',
      'today': 'Hari ini',
      'receiptRoutes': 'Laluan resit',
      'escrowHold': 'Simpanan Escrow',
      'platformFee': 'Yuran Platform',
      'releasedToDriver': 'Dikeluarkan kepada pemandu',
      'refund': 'Bayaran Balik',
      'daysAgo': '{days} hari lepas',
      'myRidesTitle': 'Perjalanan Saya',
      'upcoming': 'Akan datang',
      'past': 'Lepas',
      'noRidesYet': 'Tiada perjalanan lagi',
      'exploreRidesToStart': 'Terokai perjalanan tersedia untuk bermula',
      'arrivingIn': 'Bertolak dalam {time}',
      'arrived': 'Dah Sampai',
      'unknownDriver': 'Tidak diketahui',
      'rideDetailsTitle': 'Butiran Perjalanan',
      'yourDriver': 'Pemandu anda',
      'verifiedIdentity': 'Identiti disahkan',
      'pickupLabel': 'Pickup',
      'distanceLabel': 'Distance',
      'carImage': 'Gambar kereta',
      'pricePerSeat': 'Harga setiap tempat',
      'chat': 'Chat',
      'phone': 'Telefon',
      'viewRide': 'Lihat Perjalanan',
      'departIn': 'Bertolak dalam',
      'paymentTitle': 'Pembayaran',
      'amount': 'Jumlah',
      'payWith': 'Bayar dengan',
      'instantPayment': 'Bayaran segera',
      'bankTransfer': 'Pindahan bank',
      'fuelContribution': 'Sumbangan minyak',
      'tollShare': 'Bahagian tol',
      'total': 'Jumlah',
      'confirmPayment': 'Sahkan & Bayar',
      'securedTitle': 'Tempat dijamin!',
      'chatDriver': 'Chat',
      'callDriver': 'Telefon',
      'driverReveal': 'Pemandu anda',
      'chooseCar': 'Pilih Kereta',
      'saveCar': 'Simpan Kereta',
      'plateLabel': 'No. Pendaftaran',
      'colorLabel': 'Warna',
      'discontinued': 'Dihentikan',
      'modelsFoundLabel': '{count} model dijumpai',
      'sedan': 'Sedan',
      'hatchback': 'Hatchback',
      'suv': 'SUV',
      'mpv': 'MPV',
      'pickup': 'Pickup',
      'greetingMorning': 'Selamat pagi',
      'greetingAfternoon': 'Selamat petang',
      'greetingEvening': 'Selamat malam',
      'modelsFound': '{count} model dijumpai',
      // List Ride Screen
      'listRideScreenTitle': 'Senarai Perjalanan',
      'listButton': 'Senaraikan',
      'fromWhereHint': 'Dari mana?',
      'fromFieldHint': 'Dari...',
      'toWhereHint': 'Ke mana?',
      'toFieldHint': 'Ke...',
      'yourCarLabel': 'Kereta anda',
      'fairRateLabel': 'Kadar Saksama',
      'fuelContributionRon': 'Sumbangan minyak (RON95)',
      'tollShareLabel': 'Bahagian tol',
      'seatsLabel': 'Tempat',
      'recommendedPerSeatLabel': 'Cadangan /tempat',
      'perSeatPriceLabel': '/tempat (kadar saksama + kom)',
      'priceRangeHint': 'Boleh minta sehingga +15%',
      'listedSuccessTitle': 'Disenaraikan!',
      'listedSuccessMessage': 'Perjalanan anda kini boleh dilihat oleh penumpang',
      'backLabel': 'Kembali',
      // Vehicle colors
      'colorWhite': 'Putih',
      'colorBlack': 'Hitam',
      'colorSilver': 'Perak',
      'colorGrey': 'Kelabu',
      'colorRed': 'Merah',
      'colorBlue': 'Biru',
      'colorBrown': 'Coklat',
      'colorGold': 'Emas',
      'colorGreen': 'Hijau',
      'colorOrange': 'Oren',
      'plateHintExample': 'cth. WXY 1234',
      // Gender buttons
      'maleButton': 'Lelaki',
      'femaleButton': 'Perempuan',
      // Gender labels
      'sexMale': 'Lelaki',
      'sexFemale': 'Perempuan',
      // Ride card & details
      'durationLabel': 'Tempoh',
      'departureTimeLabel': 'Masa bertolak',
      // Price breakdown
      'priceBreakdownTitle': 'Pecahan harga',
      'fuelShareLabel': 'Sumbangan minyak',
      'platformFeeLabel': 'Yuran platform',
      'maintenanceFeeDescription': 'Yuran penyelenggaraan platform',
    },
    'zh': {
      'appName': 'Germana',
      'navRides': '行程',
      'navHistory': '记录',
      'navProfile': '个人资料',
      'signInSubtitle': '登录以访问行程、收据和司机资料。',
      'signInHint': 'name@smail.unikl.edu.my',
      'signInError': '请使用学校邮箱（@{domain}）',
      'signInContinue': '继续',
      'signInClosedLoop': '仅限已验证校园用户的封闭式访问。',
      'permissionsTitle': '权限',
      'permissionsSubtitle': '我们需要基础权限来排序附近行程并发送预订通知。',
      'locationPermissionTitle': '位置（使用时）',
      'locationPermissionSubtitle': '用于距离（公里）和上车相关性。',
      'notificationsPermissionTitle': '通知',
      'notificationsPermissionSubtitle': '用于支付状态和指定时间提醒。',
      'browserDebugMockTitle': '浏览器 / 调试模拟',
      'browserDebugMockDescription': '在 Edge、Chrome 或其他调试会话中绕过系统权限提示。',
      'enableMockPermissions': '启用模拟权限',
      'mockPermissionsEnabled': '已启用模拟权限',
      'continueLabel': '继续',
      'domainActive': '当前域名：@{domain}',
      'onboardingTitle': '完成资料',
      'onboardingSubtitle': '进入首页前先设置基础司机信息。',
      'nameLabel': '姓名',
      'nameHint': '全名',
      'phoneLabel': '电话',
      'phoneHint': '+60 1X-XXXX XXXX',
      'genderLabel': '性别',
      'maleLabel': '男',
      'femaleLabel': '女',
      'enterHome': '进入首页',
      'driverInfo': '司机资料',
      'editProfile': '编辑资料',
      'trips': '行程',
      'rating': '评分',
      'driver': '司机',
      'yourCar': '你的车',
      'listRide': '发布行程',
      'settings': '设置',
      'darkMode': '深色模式',
      'notifications': '通知',
      'privacySafety': '隐私与安全',
      'helpSupport': '帮助与支持',
      'language': '语言',
      'languageEnglish': 'English',
      'languageMalay': 'Bahasa Melayu',
      'languageChinese': '中文',
      'languageTamil': 'தமிழ்',
      'save': '保存',
      'institutionEmail': '学校邮箱',
      'faculty': '学院',
      'searchHint': '去哪儿？',
      'destinations': '目的地',
      'allFilter': '全部',
      'nowFilter': '现在',
      'scheduledFilter': '已安排',
      'underFiveFilter': '< RM5',
      'threePlusSeatsFilter': '3+ 座位',
      'availableRides': '可用行程',
      'viewAll': '查看全部',
      'manual': '手动',
      'seats': '座位',
      'sexLabel': '性别',
      'historyTitle': '记录',
      'thisMonth': '本月',
      'totalSpent': '总支出',
      'refunded': '已退款',
      'receipts': '收据',
      'today': '今天',
      'receiptRoutes': '收据路线',
      'escrowHold': '托管保留',
      'platformFee': '平台费用',
      'releasedToDriver': '已发放给司机',
      'refund': '退款',
      'daysAgo': '{days} 天前',
      'myRidesTitle': '我的行程',
      'upcoming': '即将到来',
      'past': '过去',
      'noRidesYet': '暂无行程',
      'exploreRidesToStart': '浏览可用行程开始使用',
      'arrivingIn': '{time} 后出发',
      'arrived': '已到达',
      'unknownDriver': '未知',
      'rideDetailsTitle': '行程详情',
      'yourDriver': '你的司机',
      'verifiedIdentity': '已验证身份',
      'pickupLabel': '上车点',
      'distanceLabel': '距离',
      'carImage': '车辆照片',
      'pricePerSeat': '每座价格',
      'chat': '聊天',
      'phone': '电话',
      'viewRide': '查看行程',
      'departIn': '出发于',
      'paymentTitle': '支付',
      'amount': '金额',
      'payWith': '支付方式',
      'instantPayment': '即时支付',
      'bankTransfer': '银行转账',
      'fuelContribution': '油费分摊',
      'tollShare': '过路费分摊',
      'total': '合计',
      'confirmPayment': '确认并支付',
      'securedTitle': '座位已保留！',
      'chatDriver': '聊天',
      'callDriver': '电话',
      'driverReveal': '你的司机',
      'chooseCar': '选择车辆',
      'saveCar': '保存车辆',
      'plateLabel': '车牌号',
      'colorLabel': '颜色',
      'discontinued': '已停产',
      'modelsFoundLabel': '找到 {count} 个车型',
      'sedan': '轿车',
      'hatchback': '掀背车',
      'suv': 'SUV',
      'mpv': 'MPV',
      'pickup': '皮卡',
      'greetingMorning': '早上好',
      'greetingAfternoon': '下午好',
      'greetingEvening': '晚上好',
      'modelsFound': '找到 {count} 个车型',
      // List Ride Screen
      'listRideScreenTitle': '发布行程',
      'listButton': '发布',
      'fromWhereHint': '从哪里?',
      'fromFieldHint': '从...',
      'toWhereHint': '去哪里?',
      'toFieldHint': '到...',
      'yourCarLabel': '您的车',
      'fairRateLabel': '公平价格',
      'fuelContributionRon': '燃油贡献 (RON95)',
      'tollShareLabel': '过路费分摊',
      'seatsLabel': '座位',
      'recommendedPerSeatLabel': '每座建议价格',
      'priceRangeHint': '最多可要求上涨 +15%',
      'listedSuccessTitle': '已发布!',
      'listedSuccessMessage': '您的行程现在对乘客可见',
      'backLabel': '返回',
      // Vehicle colors
      'colorWhite': '白色',
      'colorBlack': '黑色',
      'colorSilver': '银色',
      'colorGrey': '灰色',
      'colorRed': '红色',
      'colorBlue': '蓝色',
      'colorBrown': '棕色',
      'colorGold': '金色',
      'colorGreen': '绿色',
      'colorOrange': '橙色',
      'plateHintExample': '例如 WXY 1234',
      // Gender buttons
      'maleButton': '男',
      'femaleButton': '女',
      // Gender labels
      'sexMale': '男',
      'sexFemale': '女',
      // Ride card & details
      'durationLabel': '时长',
      'departureTimeLabel': '出发时间',
      'perSeatPriceLabel': '/座位 (公平价格 + 佣金)',
      // Price breakdown
      'priceBreakdownTitle': '价格明细',
      'fuelShareLabel': '燃油贡献',
      'platformFeeLabel': '平台费用',
      'maintenanceFeeDescription': '平台维护费',
    },
    'ta': {
      'appName': 'Germana',
      'navRides': 'பயணங்கள்',
      'navHistory': 'வரலாறு',
      'navProfile': 'சுயவிவரம்',
      'signInSubtitle': 'பயணங்கள், ரசீதுகள், மற்றும் ஓட்டுநர் சுயவிவரத்தைப் பெற உள்நுழைக.',
      'signInHint': 'name@smail.unikl.edu.my',
      'signInError': 'உங்கள் நிறுவன மின்னஞ்சலை பயன்படுத்தவும் (@{domain})',
      'signInContinue': 'தொடரவும்',
      'signInClosedLoop': 'சரிபார்க்கப்பட்ட காம்பஸ் பயனர்களுக்கான மூடிய அணுகல்.',
      'permissionsTitle': 'அனுமதிகள்',
      'permissionsSubtitle': 'அருகிலுள்ள பயண தரவரிசை மற்றும் முன்பதிவு அறிவிப்புகளுக்கு அடிப்படை அனுமதி தேவை.',
      'locationPermissionTitle': 'இருப்பிடம் (பயன்படுத்தும் போது)',
      'locationPermissionSubtitle': 'தூரம் (கிமீ) மற்றும் pick-up தொடர்புக்கு.',
      'notificationsPermissionTitle': 'அறிவிப்புகள்',
      'notificationsPermissionSubtitle': 'கட்டண நிலை மற்றும் குறிப்பிட்ட நேர நினைவூட்டல்களுக்கு.',
      'browserDebugMockTitle': 'உலாவி / டீபக் மோக்',
      'browserDebugMockDescription': 'Edge, Chrome அல்லது பிற டீபக் அமர்வுகளில் OS prompt ஐ தவிர்க்க இதைப் பயன்படுத்தவும்.',
      'enableMockPermissions': 'மோக் அனுமதிகளை இயக்கு',
      'mockPermissionsEnabled': 'மோக் அனுமதிகள் இயக்கப்பட்டன',
      'continueLabel': 'தொடரவும்',
      'domainActive': 'செயலில் உள்ள டொமைன்: @{domain}',
      'onboardingTitle': 'சுயவிவரத்தை முடிக்கவும்',
      'onboardingSubtitle': 'Home-க்கு செல்வதற்கு முன் அடிப்படை ஓட்டுநர் தகவலை அமைக்கவும்.',
      'nameLabel': 'பெயர்',
      'nameHint': 'முழுப் பெயர்',
      'phoneLabel': 'தொலைபேசி',
      'phoneHint': '+60 1X-XXXX XXXX',
      'genderLabel': 'பாலினம்',
      'maleLabel': 'ஆண்',
      'femaleLabel': 'பெண்',
      'enterHome': 'Home-க்கு செல்',
      'driverInfo': 'ஓட்டுநர் தகவல்',
      'editProfile': 'சுயவிவரத்தைத் திருத்து',
      'trips': 'பயணங்கள்',
      'rating': 'மதிப்பீடு',
      'driver': 'ஓட்டுநர்',
      'yourCar': 'உங்கள் கார்',
      'listRide': 'பயணம் பதிவிடு',
      'settings': 'அமைப்புகள்',
      'darkMode': 'இருள் முறை',
      'notifications': 'அறிவிப்புகள்',
      'privacySafety': 'தனியுரிமை & பாதுகாப்பு',
      'helpSupport': 'உதவி & ஆதரவு',
      'language': 'மொழி',
      'languageEnglish': 'English',
      'languageMalay': 'Bahasa Melayu',
      'languageChinese': '中文',
      'languageTamil': 'தமிழ்',
      'save': 'சேமி',
      'institutionEmail': 'நிறுவன மின்னஞ்சல்',
      'faculty': 'பீடம்',
      'searchHint': 'எங்கு?',
      'destinations': 'இலக்குகள்',
      'allFilter': 'அனைத்தும்',
      'nowFilter': 'இப்போது',
      'scheduledFilter': 'திட்டமிட்டது',
      'underFiveFilter': '< RM5',
      'threePlusSeatsFilter': '3+ இருக்கைகள்',
      'availableRides': 'கிடைக்கும் பயணங்கள்',
      'viewAll': 'அனைத்தையும் காண்க',
      'manual': 'கைமுறை',
      'seats': 'இருக்கைகள்',
      'sexLabel': 'பாலினம்',
      'historyTitle': 'வரலாறு',
      'thisMonth': 'இந்த மாதம்',
      'totalSpent': 'மொத்த செலவு',
      'refunded': 'திருப்பிச் செலுத்தப்பட்டது',
      'receipts': 'ரசீதுகள்',
      'today': 'இன்று',
      'receiptRoutes': 'ரசீது வழிகள்',
      'escrowHold': 'எஸ்க்ரோ வைத்திருப்பு',
      'platformFee': 'தளம் கட்டணம்',
      'releasedToDriver': 'ஓட்டுநருக்கு விடப்பட்டது',
      'refund': 'மீளளிப்பு',
      'daysAgo': '{days} நாட்களுக்கு முன்',
      'myRidesTitle': 'என் பயணங்கள்',
      'upcoming': 'வரவிருப்பவை',
      'past': 'முந்தையவை',
      'noRidesYet': 'இன்னும் பயணங்கள் இல்லை',
      'exploreRidesToStart': 'தொடங்க கிடைக்கும் பயணங்களைப் பார்க்கவும்',
      'arrivingIn': '{time} இல் புறப்படும்',
      'arrived': 'வந்துவிட்டது',
      'unknownDriver': 'தெரியாதவர்',
      'rideDetailsTitle': 'பயண விவரங்கள்',
      'yourDriver': 'உங்கள் ஓட்டுநர்',
      'verifiedIdentity': 'சரிபார்க்கப்பட்ட அடையாளம்',
      'pickupLabel': 'பிக்கப்',
      'distanceLabel': 'தூரம்',
      'carImage': 'கார் படம்',
      'pricePerSeat': 'ஒரு இருக்கை விலை',
      'chat': 'உரையாடல்',
      'phone': 'தொலைபேசி',
      'viewRide': 'பயணத்தைப் பார்க்க',
      'departIn': 'புறப்படும் நேரம்',
      'paymentTitle': 'கட்டணம்',
      'amount': 'தொகை',
      'payWith': 'இதன் மூலம் செலுத்தவும்',
      'instantPayment': 'உடனடி கட்டணம்',
      'bankTransfer': 'வங்கி பரிமாற்றம்',
      'fuelContribution': 'எரிபொருள் பங்களிப்பு',
      'tollShare': 'டோல் பங்கு',
      'total': 'மொத்தம்',
      'confirmPayment': 'உறுதிசெய்து செலுத்து',
      'securedTitle': 'இருக்கை உறுதி செய்யப்பட்டது!',
      'chatDriver': 'உரையாடல்',
      'callDriver': 'அழைப்பு',
      'driverReveal': 'உங்கள் ஓட்டுநர்',
      'chooseCar': 'காரைத் தேர்ந்தெடு',
      'saveCar': 'காரைச் சேமி',
      'plateLabel': 'பதிவு எண்',
      'colorLabel': 'நிறம்',
      'discontinued': 'நிறுத்தப்பட்டது',
      'modelsFoundLabel': '{count} மாடல்கள் கிடைத்தன',
      'sedan': 'செடான்',
      'hatchback': 'ஹாட்ச்பேக்',
      'suv': 'SUV',
      'mpv': 'MPV',
      'pickup': 'பிக்கப்',
      'greetingMorning': 'காலை வணக்கம்',
      'greetingAfternoon': 'மதிய வணக்கம்',
      'greetingEvening': 'மாலை வணக்கம்',
      'modelsFound': '{count} மாடல்கள் கிடைத்தன',
      // List Ride Screen
      'listRideScreenTitle': 'பயணம் பதிவிடு',
      'listButton': 'பதிவிடு',
      'fromWhereHint': 'எங்கிருந்து?',
      'fromFieldHint': 'இதில் இருந்து...',
      'toWhereHint': 'எங்கு?',
      'toFieldHint': 'இதுக்கு...',
      'yourCarLabel': 'உங்கள் கார்',
      'fairRateLabel': 'நியாய விலை',
      'fuelContributionRon': 'எரிபொருள் பங்களிப்பு (RON95)',
      'tollShareLabel': 'டோல் பங்கு',
      'seatsLabel': 'இருக்கைகள்',
      'recommendedPerSeatLabel': 'பரிந்துரை செய்யப்பட்ட / இருக்கை',
      'priceRangeHint': '15% வரை கேட்கலாம்',
      'listedSuccessTitle': 'பதிவிடப்பட்டது!',
      'listedSuccessMessage': 'உங்கள் பயணம் இப்போது பயணிகளுக்கு புலப்படும்',
      'backLabel': 'பின்னே',
      // Vehicle colors
      'colorWhite': 'வெள்ளை',
      'colorBlack': 'கறுப்பு',
      'colorSilver': 'வெள்ளிய நிறம்',
      'colorGrey': 'சாம்பல்',
      'colorRed': 'சிவப்பு',
      'colorBlue': 'நீல',
      'colorBrown': 'பழுப்பு',
      'colorGold': 'தங்கம்',
      'colorGreen': 'பச்சை',
      'colorOrange': 'ஆரஞ்சு',
      'plateHintExample': 'எ.கா. WXY 1234',
      // Gender buttons
      'maleButton': 'ஆண்',
      'femaleButton': 'பெண்',
      // Gender labels
      'sexMale': 'ஆண்',
      'sexFemale': 'பெண்',
      // Ride card & details
      'durationLabel': 'கால அளவு',
      'departureTimeLabel': 'புறப்பட்ட நேரம்',
      'perSeatPriceLabel': '/இருக்கை (நியாய விலை + கமிஷன்)',
      // Price breakdown
      'priceBreakdownTitle': 'விலை விவரம்',
      'fuelShareLabel': 'எரிபொருள் பங்களிப்பு',
      'platformFeeLabel': 'தளம் கட்டணம்',
      'maintenanceFeeDescription': 'தளம் பராமரிப்பு கட்டணம்',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supported) => supported.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return SynchronousFuture(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}