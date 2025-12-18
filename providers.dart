import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:true_love_app/src/core/services/auth_service.dart';
import 'package:true_love_app/src/core/services/firestore_service.dart';
import 'package:true_love_app/src/core/services/storage_service.dart';
import 'package:true_love_app/src/core/services/notification_service.dart';
import 'package:true_love_app/src/core/services/remote_config_service.dart';
import 'package:true_love_app/src/core/services/ads_service.dart';
import 'package:true_love_app/src/core/services/match_service.dart';
import 'package:true_love_app/src/core/services/community_service.dart';

// Shared Preferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

// Theme Provider
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Locale Provider
final localeProvider = StateProvider<Locale>((ref) => const Locale('ar'));

// Services Providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());
final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) => RemoteConfigService());
final adsServiceProvider = Provider<AdsService>((ref) => AdsService());
final matchServiceProvider = Provider<MatchService>((ref) => MatchService());
final communityServiceProvider = Provider<CommunityService>((ref) => CommunityService());

// User State Provider
final currentUserProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// Loading State Provider
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Error State Provider
final errorProvider = StateProvider<String?>((ref) => null);

// Success State Provider
final successProvider = StateProvider<String?>((ref) => null);

// Bottom Navigation Index Provider
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

// Question of the Day Provider
final questionOfTheDayProvider = FutureProvider<String>((ref) async {
  final remoteConfig = ref.watch(remoteConfigServiceProvider);
  return await remoteConfig.getQuestionOfTheDay();
});

// Ad Providers
final bannerAdProvider = FutureProvider<BannerAd?>((ref) async {
  final adsService = ref.watch(adsServiceProvider);
  return await adsService.loadBannerAd();
});

final interstitialAdProvider = FutureProvider<InterstitialAd?>((ref) async {
  final adsService = ref.watch(adsServiceProvider);
  return await adsService.loadInterstitialAd();
});

final rewardedAdProvider = FutureProvider<RewardedAd?>((ref) async {
  final adsService = ref.watch(adsServiceProvider);
  return await adsService.loadRewardedAd();
});

// Swipe Providers
final swipeCountProvider = StateProvider<int>((ref) => 0);
final canSwipeProvider = Provider<bool>((ref) {
  final swipeCount = ref.watch(swipeCountProvider);
  final remoteConfig = ref.watch(remoteConfigServiceProvider);
  return swipeCount < remoteConfig.maxSwipesPerDay;
});

// Match Providers
final matchesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final matchService = ref.watch(matchServiceProvider);
  final user = ref.watch(currentUserProvider);
  if (user != null) {
    return matchService.getUserMatches(user['uid']);
  }
  return const Stream.empty();
});

// Community Providers
final postsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final communityService = ref.watch(communityServiceProvider);
  return communityService.getPosts();
});

final trendingPostsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final communityService = ref.watch(communityServiceProvider);
  return communityService.getTrendingPosts();
});

// Notification Providers
final notificationsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  final user = ref.watch(currentUserProvider);
  if (user != null) {
    return notificationService.getUserNotifications(user['uid']);
  }
  return const Stream.empty();
});

// Search Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filter Provider
final filterProvider = StateProvider<Map<String, dynamic>>((ref) => {
  'maritalStatus': 'all',
  'hasChildren': 'all',
  'location': 'all',
  'ageRange': const RangeValues(18, 65),
});

// Super Hour Provider
final isSuperHourProvider = StateProvider<bool>((ref) => false);

// Boost Provider
final isBoostActiveProvider = StateProvider<bool>((ref) => false);

// Profile Completion Provider
final profileCompletionProvider = Provider<double>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0.0;
  
  double completion = 0.0;
  int completedFields = 0;
  int totalFields = 8;
  
  if (user['displayName'] != null && user['displayName'].isNotEmpty) completedFields++;
  if (user['bio'] != null && user['bio'].isNotEmpty) completedFields++;
  if (user['photos'] != null && user['photos'].isNotEmpty) completedFields++;
  if (user['maritalStatus'] != null) completedFields++;
  if (user['childrenCount'] != null) completedFields++;
  if (user['location'] != null) completedFields++;
  if (user['interests'] != null && user['interests'].isNotEmpty) completedFields++;
  if (user['preferences'] != null) completedFields++;
  
  completion = completedFields / totalFields;
  return completion.clamp(0.0, 1.0);
});

// Settings Providers
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
final locationEnabledProvider = StateProvider<bool>((ref) => false);
final privacyModeProvider = StateProvider<String>((ref) => 'public'); // public, friends, private
final childrenPhotosVisibleProvider = StateProvider<bool>((ref) => false);

// Analytics Providers
final appOpenedProvider = Provider<void>((ref) {
  // Track app open event
  print('App opened');
});

final screenViewProvider = Provider.family<void, String>((ref, screenName) {
  // Track screen view
  print('Screen viewed: $screenName');
});

// Utility Providers
final isOnlineProvider = StateProvider<bool>((ref) => true);
final connectionStatusProvider = StateProvider<String>((ref) => 'connected');

// Loading States
final isLoggingInProvider = StateProvider<bool>((ref) => false);
final isRegisteringProvider = StateProvider<bool>((ref) => false);
final isUploadingImageProvider = StateProvider<bool>((ref) => false);
final isSendingMessageProvider = StateProvider<bool>((ref) => false);

// Form Validation Providers
final emailValidationProvider = Provider.family<String?, String>((ref, email) {
  if (email.isEmpty) return 'البريد الإلكتروني مطلوب';
  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
    return 'البريد الإلكتروني غير صالح';
  }
  return null;
});

final passwordValidationProvider = Provider.family<String?, String>((ref, password) {
  if (password.isEmpty) return 'كلمة المرور مطلوبة';
  if (password.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
  return null;
});

final nameValidationProvider = Provider.family<String?, String>((ref, name) {
  if (name.isEmpty) return 'الاسم مطلوب';
  if (name.length < 2) return 'الاسم يجب أن يكون حرفين على الأقل';
  return null;
});