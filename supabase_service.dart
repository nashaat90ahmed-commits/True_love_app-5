import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final client = Supabase.instance.client;

  // تسجيل مستخدم جديد
  Future<void> register(String email, String password) async {
    await client.auth.signUp(email: email, password: password);
  }

  // تسجيل دخول
  Future<void> login(String email, String password) async {
    await client.auth.signInWithPassword(email: email, password: password);
  }

  // حفظ بيانات البروفايل (مطلق/أرمل/أطفال)
  Future<void> updateProfile(Map<String, dynamic> data) async {
    final user = client.auth.currentUser;
    if (user != null) {
      await client.from('profiles').upsert({'id': user.id, ...data});
    }
  }
}
