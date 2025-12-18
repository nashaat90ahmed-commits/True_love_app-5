import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:backendless_flutter_sdk/backendless_flutter_sdk.dart';  // ← التعديل النهائي
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ======== المفاتيح من GitHub Secrets ========
class BackendlessKeys {
  static const String applicationId = String.fromEnvironment('BLAPPID');
  static const String androidApiKey = String.fromEnvironment('BLANDROIDKEY');
  static const String iosApiKey = String.fromEnvironment('BLIOSKEY');
  static const String jsApiKey = String.fromEnvironment('BLJSKEY');
}

// ======== MAIN APP ========
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Backendless.initApp(
    applicationId: BackendlessKeys.applicationId,
    androidApiKey: BackendlessKeys.androidApiKey,
    iosApiKey: BackendlessKeys.iosApiKey,
    jsApiKey: BackendlessKeys.jsApiKey,
  );
  
  runApp(const ProviderScope(child: TrueLoveApp()));
}

class TrueLoveApp extends StatelessWidget {
  const TrueLoveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'الحب الحقيقي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        textDirection: TextDirection.rtl,
      ),
      home: const SplashScreen(),
    );
  }
}

// ======== SPLASH SCREEN ========
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));
    BackendlessUser? user = await Backendless.userService.currentUser();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => user != null ? const SwipeScreen() : const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.pink.shade400, Colors.pink.shade700])), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.favorite, size: 100, color: Colors.white), const SizedBox(height: 20), const Text('الحب الحقيقي', style: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 30), const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))]))));
  }
}

// ======== LOGIN SCREEN ========
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLoginMode = true;

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);
    try {
      if (_isLoginMode) {
        await Backendless.userService.login(_emailController.text.trim(), _passwordController.text.trim());
      } else {
        BackendlessUser user = BackendlessUser()..email = _emailController.text.trim()..password = _passwordController.text.trim();
        await Backendless.userService.register(user);
        await Backendless.userService.login(_emailController.text.trim(), _passwordController.text.trim());
      }
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SwipeScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.favorite, size: 80, color: Colors.pink), const SizedBox(height: 20), Text(_isLoginMode ? 'تسجيل الدخول' : 'إنشاء حساب', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.pink.shade700)), const SizedBox(height: 40), if (!_isLoginMode) ...[TextField(decoration: InputDecoration(labelText: 'الاسم', prefixIcon: Icon(Icons.person, color: Colors.pink))), const SizedBox(height: 16)], TextField(controller: _emailController, decoration: InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email, color: Colors.pink))), const SizedBox(height: 16), TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: 'كلمة المرور', prefixIcon: Icon(Icons.lock, color: Colors.pink))), const SizedBox(height: 24), _isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _handleSubmit, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)), child: Text(_isLoginMode ? 'دخول' : 'تسجيل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), TextButton(onPressed: () => setState(() => _isLoginMode = !_isLoginMode), child: Text(_isLoginMode ? 'ليس لديك حساب؟ سجل الآن' : 'لديك حساب؟ دخول', style: TextStyle(color: Colors.pink.shade700, fontWeight: FontWeight.w600))])))));
  }
}

// ======== SWIPE SCREEN ========
class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  final CardSwiperController controller = CardSwiperController();
  List<Map<String, dynamic>> candidates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    final queryBuilder = DataQueryBuilder()..whereClause = "isActive = true"..pageSize = 50..sortBy = ["lastSeen DESC"];
    final result = await Backendless.data.of('Profiles').find(queryBuilder);
    if (mounted) setState(() { candidates = List<Map<String, dynamic>>.from(result ?? []); _isLoading = false; });
  }

  Future<bool> _handleSwipe(int? previousIndex, int? currentIndex, CardSwiperDirection direction) async {
    if (previousIndex == null || candidates.isEmpty) return true;
    final swipedProfile = candidates[previousIndex];
    final currentUser = await Backendless.userService.currentUser();
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يجب تسجيل الدخول'), backgroundColor: Colors.red));
      return false;
    }
    await Backendless.data.of('Swipes').save({'ownerId': currentUser.objectId, 'targetId': swipedProfile['ownerId'], 'direction': direction == CardSwiperDirection.right ? 'right' : 'left', 'timestamp': DateTime.now().millisecondsSinceEpoch});
    if (direction == CardSwiperDirection.right) _checkForMatch(currentUser.objectId!, swipedProfile['ownerId']);
    return true;
  }

  Future<void> _checkForMatch(String userId, String targetId) async {
    final queryBuilder = DataQueryBuilder()..whereClause = "ownerId = '$targetId' AND targetId = '$userId' AND direction = 'right'"..pageSize = 1;
    final result = await Backendless.data.of('Swipes').find(queryBuilder);
    if (result != null && result.isNotEmpty) {
      await Backendless.data.of('Matches').save({'user1Id': userId, 'user2Id': targetId, 'matchedAt': DateTime.now().millisecondsSinceEpoch});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 Match جديد!'), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('اكتشف'), actions: [IconButton(icon: const Icon(Icons.message), onPressed: () {})]), body: _isLoading ? const Center(child: CircularProgressIndicator()) : candidates.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.people, size: 80, color: Colors.grey), const SizedBox(height: 16), const Text('لا يوجد ملفات جديدة'), ElevatedButton(onPressed: _loadCandidates, child: const Text('تحديث'))])) : Column(children: [Expanded(child: CardSwiper(controller: controller, cardsCount: candidates.length, onSwipe: _handleSwipe, cardBuilder: (context, index) { final c = candidates[index]; return _buildCard(c); })), Padding(padding: const EdgeInsets.all(20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [FloatingActionButton(heroTag: "pass", backgroundColor: Colors.red, onPressed: () => controller.swipeLeft(), child: Icon(Icons.close)), FloatingActionButton(heroTag: "like", backgroundColor: Colors.green, onPressed: () => controller.swipeRight(), child: Icon(Icons.favorite))]))]));
  }

  Widget _buildCard(Map<String, dynamic> candidate) {
    return Container(margin: const EdgeInsets.all(10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)]), child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Stack(children: [Image.network(candidate['imageUrl'] ?? 'https://via.placeholder.com/400', width: double.infinity, height: double.infinity, fit: BoxFit.cover), Align(alignment: Alignment.bottomCenter, child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)])), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text('${candidate['name']}, ${candidate['age']}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)), if (candidate['isActive'] == true) ...[const SizedBox(width: 8), Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle))]]), Text(candidate['city'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 20)), const SizedBox(height: 8), Text(candidate['bio'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis)]))])))]);
  }
}
