# دليل النشر - تطبيق الحب الحقيقي

## 📋 المتطلبات الأساسية

### الأدوات المطلوبة
- ✅ Flutter SDK 3.19+
- ✅ Firebase CLI
- ✅ Node.js 18+
- ✅ Git
- ✅ Android Studio / VS Code
- ✅ حساب Firebase
- ✅ حساب AdMob

### الإعداد الأولي

## 1️⃣ إعداد Firebase

### إنشاء مشروع Firebase
```bash
# تثبيت Firebase CLI
npm install -g firebase-tools

# تسجيل الدخول
firebase login

# إنشاء مشروع جديد
firebase projects:create truelove-app-2024

# تفعيل الخدمات المطلوبة
firebase projects:addfirebase truelove-app-2024
```

### إعداد المصادقة
```bash
# تفعيل Firebase Auth
firebase ext install firebase/firestore-auth
```

### إعداد Cloud Functions
```bash
# الانتقال إلى مجلد Firebase
cd firebase/functions

# تثبيت الإعتمادات
npm install

# نشر الدوال
firebase deploy --only functions
```

### إعداد Firestore Rules
```bash
# نشر قواعد الأمان
firebase deploy --only firestore:rules

# نشر الفهارس
firebase deploy --only firestore:indexes
```

## 2️⃣ إعداد Flutter

### إنشاء مشروع Flutter
```bash
# إنشاء المشروع
flutter create true_love_app

# الانتقال إلى المشروع
cd true_love_app

# إضافة الحزم المطلوبة
flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage
flutter pub add google_mobile_ads provider flutter_riverpod
flutter pub add shared_preferences cached_network_image
flutter pub add image_picker image_cropper flutter_image_compress
flutter pub add tcard flutter_tindercard
flutter pub add lottie flutter_animate
flutter pub add form_builder_validators flutter_form_builder
flutter pub add geolocator geocoding
flutter pub add url_launcher share_plus
flutter pub add connectivity_plus package_info_plus
flutter pub add device_info_plus
```

### إعداد Firebase في Flutter
```bash
# إضافة Firebase للمشروع
flutterfire configure
```

## 3️⃣ إعداد AdMob

### إنشاء حساب AdMob
1. الذهاب إلى [AdMob](https://admob.google.com)
2. إنشاء حساب جديد
3. إضافة التطبيق
4. الحصول على App ID

### إضافة App ID
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
    </application>
</manifest>
```

```xml
<!-- ios/Runner/Info.plist -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
```

## 4️⃣ إعداد المتاجر

### Aptoide (موصى به)

#### الخطوات
1. الذهاب إلى [Aptoide](https://www.aptoide.com)
2. إنشاء حساب مطور
3. رفع APK
4. إضافة الوصف والصور
5. النشر

#### المميزات
- ✅ مجاني 100%
- ✅ 300 مليون مستخدم
- ✅ مراجعة سريعة
- ✅ لا رسوم

### Galaxy Store

#### الخطوات
1. الذهاب إلى [Galaxy Store](https://seller.samsungapps.com)
2. التسجيل كمطور
3. رفع التطبيق
4. انتظار المراجعة

#### المميزات
- ✅ خاص بأجهزة Samsung
- ✅ وصول جيد في الشرق الأوسط
- ✅ مراجعة معقولة

### Huawei AppGallery

#### الخطوات
1. الذهاب إلى [AppGallery](https://developer.huawei.com)
2. إنشاء حساب مطور
3. رفع APK
4. إضافة المواد التسويقية
5. النشر

#### المميزات
- ✅ 530 مليون مستخدم
- ✅ جيد في إفريقيا والشرق الأوسط
- ✅ دعم جيد

### SlideME

#### الخطوات
1. الذهاب إلى [SlideME](https://slideme.org)
2. التسجيل
3. رفع التطبيق
4. النشر الفوري

#### المميزات
- ✅ رفع سهل
- ✅ مراجعة سريعة
- ✅ مجاني

### Google Play (اختياري)

#### الخطوات
1. الذهاب إلى [Google Play Console](https://play.google.com/console)
2. دفع رسوم التسجيل (25 دولار)
3. إنشاء التطبيق
4. رفع APK/AAB
5. إضافة المواد التسويقية
6. انتظار المراجعة (3-7 أيام)

#### المميزات
- ✅ وصول أوسع
- ✅ ثقة أعلى
- ✅ تحديثات تلقائية

## 5️⃣ إعداد التطبيق

### ملفات الإعداد

#### pubspec.yaml
```yaml
name: true_love_app
description: تطبيق الحب الحقيقي - مواعدة مجانية للمطلقين والمنفصلين والأرامل
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.25.4
  firebase_auth: ^4.17.4
  cloud_firestore: ^4.15.4
  firebase_storage: ^11.6.5
  firebase_messaging: ^14.7.10
  firebase_remote_config: ^4.3.14
  google_mobile_ads: ^4.0.0
  provider: ^6.1.1
  flutter_riverpod: ^2.4.9
  shared_preferences: ^2.2.2
  cached_network_image: ^3.3.1
  image_picker: ^1.0.7
  image_cropper: ^5.0.1
  flutter_image_compress: ^1.4.3
  tcard: ^1.3.2
  flutter_tindercard: ^0.2.1
  lottie: ^3.0.1
  flutter_animate: ^4.5.0
  form_builder_validators: ^9.1.0
  flutter_form_builder: ^9.2.1
  flutter_datetime_picker_plus: ^2.2.4
  geolocator: ^11.0.0
  geocoding: ^2.1.1
  url_launcher: ^6.2.4
  share_plus: ^7.2.1
  connectivity_plus: ^5.0.2
  package_info_plus: ^5.0.1
  device_info_plus: ^10.0.1
  fl_chart: ^0.66.2
  webview_flutter: ^4.7.0
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.8
  flutter_native_splash: ^2.3.10
  flutter_launcher_icons: ^0.13.1

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
    - assets/translations/
  
  fonts:
    - family: Tajawal
      fonts:
        - asset: fonts/Tajawal-Regular.ttf
        - asset: fonts/Tajawal-Bold.ttf
          weight: 700
```

### إعداد Flutter Launcher Icons
```yaml
# pubspec.yaml
flutter_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#2D5A5A"
  adaptive_icon_foreground: "assets/icons/app_icon.png"
```

### إعداد Flutter Native Splash
```yaml
# pubspec.yaml
flutter_native_splash:
  color: "#2D5A5A"
  image: assets/images/splash.png
  android: true
  ios: true
  web: false
```

## 6️⃣ بناء APK

### بناء APK للنشر
```bash
# تنظيف المشروع
flutter clean

# الحصول on الإعتمادات
flutter pub get

# بناء APK
flutter build apk --release

# أو بناء App Bundle (لـ Google Play)
flutter build appbundle --release
```

### APK الملف
- **الموقع**: `build/app/outputs/flutter-apk/app-release.apk`
- **الحجم**: ~15-25 MB
- **الإصدار**: 1.0.0

## 7️⃣ المواد التسويقية

### الصور المطلوبة

#### Screenshots (5 صور)
- **الحجم**: 1080x1920 (9:16)
- **اللغات**: العربية، الإنجليزية، الفرنسية، الإسبانية
- **المحتوى**: 
  1. شاشة التسجيل
  2. شاشة Swipe
  3. شاشة الدردشة
  4. شاشة المجتمع
  5. شاشة الملف الشخصي

#### App Icon
- **الحجم**: 512x512 بكسل
- **التنسيق**: PNG
- **الخلفية**: شفافة

#### Feature Graphic
- **الحجم**: 1024x500 بكسل
- **التنسيق**: PNG
- **المحتوى**: شعار التطبيق + وصف مختصر

### الفيديوهات (3 فيديوهات)

#### Video 1: التسجيل والملف الشخصي (15 ثانية)
```
المحتوى:
- فتح التطبيق
- التسجيل السريع
- إنشاء الملف الشخصي
- عرض البطاقات
```

#### Video 2: Swipe والمطابقة (15 ثانية)
```
المحتوى:
- Swipe على البطاقات
- إعجاب متبادل
- فتح الدردشة
- التواصل
```

#### Video 3: المجتمع والميزات (30 ثانية)
```
المحتوى:
- تصفح المجتمع
- إنشاء منشور
- التفاعل مع المنشورات
- Super Hour
```

### الوصف التسويقي

#### العربية
```
الحب الحقيقي - تطبيق مواعدة مجاني 100% للمطلقين، المنفصلين، والأرامل

✅ مجاني تماماً - لا اشتراكات
✅ خصوصية الأطفال محمية
✅ مجتمع آمن وداعم
✅ Super Hour كل خميس
✅ خوارزمية مطابقة ذكية

ابحث عن الحب الحقيقي مع أشخاص يفهمون تجربتك.
```

#### English
```
True Love - 100% Free Dating App for Divorced, Separated, and Widowed

✅ 100% Free - No Subscriptions
✅ Children's Privacy Protected
✅ Safe & Supportive Community
✅ Super Hour Every Thursday
✅ Smart Matching Algorithm

Find true love with people who understand your journey.
```

## 8️⃣ ملفات الخصوصية

### Privacy Policy
```
Privacy Policy for True Love App

Last updated: December 2024

This Privacy Policy describes Our policies and procedures on the collection, 
use and disclosure of Your information when You use the Service.

We respect your privacy and are committed to protecting it.

Key Points:
- We never share children's photos without explicit permission
- All user data is encrypted
- Location data is optional and encrypted
- Chat messages are private and encrypted
- We use AI moderation to ensure safety

For full policy, visit: https://truelove.app/privacy
```

### Terms of Service
```
Terms of Service for True Love App

Last updated: December 2024

By using True Love App, you agree to these terms.

Key Points:
- You must be 18+ to use this app
- Respect other users and their privacy
- No inappropriate content allowed
- Children's photos require consent
- We reserve the right to suspend accounts for violations

For full terms, visit: https://truelove.app/terms
```

## 9️⃣ التوثيق الفني

### API Documentation
```
# Firebase Cloud Functions API

## Authentication
POST /api/auth/login
POST /api/auth/register
POST /api/auth/logout

## Users
GET /api/users/profile
PUT /api/users/profile
GET /api/users/matches

## Swipes
POST /api/swipes/like
POST /api/swipes/pass
POST /api/swipes/super-like

## Chat
GET /api/chat/messages
POST /api/chat/send
PUT /api/chat/read

## Community
GET /api/community/posts
POST /api/community/posts
POST /api/community/posts/{id}/like
POST /api/community/posts/{id}/comment
```

### Database Schema
```
# Firestore Collections

## users
- uid: string
- email: string
- displayName: string
- photoURL: string
- maritalStatus: string
- childrenCount: number
- childrenAges: array
- location: geopoint
- createdAt: timestamp
- lastActive: timestamp

## profiles
- uid: string (same as user)
- bio: string
- photos: array
- interests: array
- preferences: object
- isActive: boolean

## swipes
- id: string
- userId: string
- targetUserId: string
- type: string (like, pass, super-like)
- timestamp: timestamp

## matches
- id: string
- userId1: string
- userId2: string
- createdAt: timestamp
- isActive: boolean

## messages
- id: string
- matchId: string
- senderId: string
- receiverId: string
- content: string
- timestamp: timestamp
- isRead: boolean

## community_posts
- id: string
- authorId: string
- content: string
- imageUrl: string
- isAnonymous: boolean
- isApproved: boolean
- likes: number
- comments: number
- createdAt: timestamp
```

## 🔟 خطوات النشر النهائية

### قبل النشر
- ✅ اختبار جميع الميزات
- ✅ التأكد من عمل الإعلانات
- ✅ التحقق من Firebase Functions
- ✅ اختبار الإشعارات
- ✅ مراجعة Privacy Policy
- ✅ مراجعة Terms of Service

### أثناء النشر
- ✅ رفع APK
- ✅ إضافة Screenshots
- ✅ إضافة الوصف
- ✅ إضافة الفيديوهات
- ✅ إضافة Privacy Policy
- ✅ إضافة Terms of Service
- ✅ تحديد الفئات العمرية
- ✅ تحديد المناطق الجغرافية

### بعد النشر
- ✅ مراقبة الأداء
- ✅ مراقبة الإيرادات
- ✅ الرد على التقييمات
- ✅ تحديث المحتوى
- ✅ إصلاح الأعطال

## 🎯 النصائح والتوصيات

### لأقصى إيرادات
1. **Super Hour**: الترويج الجيد = eCPM أعلى
2. **الإعلانات**: توازن بين الإيرادات وتجربة المستخدم
3. **المحتوى**: محتوى جذاب = مستخدمون أكثر = إيرادات أكثر
4. **التواصل**: الرد السريع على تقييمات المستخدمين

### للحفاظ على المستخدمين
1. **التحديثات المنتظمة**: ميزات جديدة وإصلاحات
2. **المحتوى المتجدد**: سؤال اليوم، قصص النجاح
3. **المجتمع النشط**: تشجيع النقاشات
4. **الدعم السريع**: حل المشاكل بسرعة

---

**📞 للدعم الفني:** support@truelove.app

**🌐 الموقع الرسمي:** www.truelove.app

**📱 تحميل التطبيق:** متاح على جميع المتاجر المذكورة أعلاه