// Firebase Setup Script
// يتم تشغيل هذا السكربت لإعداد Firebase والأمان

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();

// إعداد قواعد الأمان لـ Firestore
async function setupFirestoreRules() {
  const rules = `
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        // Users collection
        match /users/{userId} {
          allow read: if request.auth != null;
          allow write: if request.auth != null && request.auth.uid == userId;
          allow create: if request.auth != null && request.auth.uid == userId;
        }
        
        // Profiles collection
        match /profiles/{profileId} {
          allow read: if request.auth != null;
          allow write: if request.auth != null && request.auth.uid == profileId;
          allow create: if request.auth != null && request.auth.uid == profileId;
        }
        
        // Swipes collection
        match /swipes/{swipeId} {
          allow read: if request.auth != null && request.auth.uid == resource.data.userId;
          allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
          allow update: if request.auth != null && request.auth.uid == resource.data.userId;
        }
        
        // Matches collection
        match /matches/{matchId} {
          allow read: if request.auth != null && 
            (request.auth.uid == resource.data.userId1 || request.auth.uid == resource.data.userId2);
          allow create: if request.auth != null;
        }
        
        // Messages collection
        match /messages/{messageId} {
          allow read: if request.auth != null && 
            (request.auth.uid == resource.data.senderId || request.auth.uid == resource.data.receiverId);
          allow create: if request.auth != null && request.auth.uid == request.resource.data.senderId;
        }
        
        // Community Posts collection
        match /community_posts/{postId} {
          allow read: if request.auth != null;
          allow create: if request.auth != null && request.auth.uid == request.resource.data.authorId;
          allow update: if request.auth != null && request.auth.uid == resource.data.authorId;
          allow delete: if request.auth != null && request.auth.uid == resource.data.authorId;
        }
        
        // Reports collection
        match /reports/{reportId} {
          allow create: if request.auth != null;
          allow read: if request.auth != null && 
            (request.auth.token.admin == true || request.auth.moderator == true);
        }
        
        // Settings collection
        match /settings/{settingId} {
          allow read: if request.auth != null;
          allow write: if request.auth != null && request.auth.token.admin == true;
        }
      }
    }
  `;
  
  try {
    await db.collection('_rules').doc('firestore').set({ rules });
    console.log('✅ Firestore rules setup completed');
  } catch (error) {
    console.error('❌ Error setting up Firestore rules:', error);
  }
}

// إعداد فهارس قواعد البيانات
async function setupIndexes() {
  const indexes = [
    // Users indexes
    {
      collectionGroup: 'users',
      queryScope: 'COLLECTION',
      fields: [
        { fieldPath: 'maritalStatus', order: 'ASCENDING' },
        { fieldPath: 'hasChildren', order: 'ASCENDING' },
        { fieldPath: 'lastActive', order: 'DESCENDING' }
      ]
    },
    {
      collectionGroup: 'users',
      queryScope: 'COLLECTION',
      fields: [
        { fieldPath: 'location', order: 'ASCENDING' },
        { fieldPath: 'lastActive', order: 'DESCENDING' }
      ]
    },
    
    // Swipes indexes
    {
      collectionGroup: 'swipes',
      queryScope: 'COLLECTION',
      fields: [
        { fieldPath: 'userId', order: 'ASCENDING' },
        { fieldPath: 'targetUserId', order: 'ASCENDING' },
        { fieldPath: 'timestamp', order: 'DESCENDING' }
      ]
    },
    
    // Matches indexes
    {
      collectionGroup: 'matches',
      queryScope: 'COLLECTION',
      fields: [
        { fieldPath: 'userId1', order: 'ASCENDING' },
        { fieldPath: 'timestamp', order: 'DESCENDING' }
      ]
    },
    {
      collectionGroup: 'matches',
      queryScope: 'COLLECTION',
      fields: [
        { fieldPath: 'userId2', order: 'ASCENDING' },
        { fieldPath: 'timestamp', order: 'DESCENDING' }
      ]
    },
    
    // Community posts indexes
    {
      collectionGroup: 'community_posts',
      queryScope: 'COLLECTION',
      fields: [
        { fieldPath: 'timestamp', order: 'DESCENDING' }
      ]
    },
    {
      collectionGroup: 'community_posts',
      queryScope: 'COLLECTION',
      fields: [
        { fieldPath: 'authorId', order: 'ASCENDING' },
        { fieldPath: 'timestamp', order: 'DESCENDING' }
      ]
    },
    {
      collectionGroup: 'community_posts',
      queryScope: 'COLLECTION',
      fields: [
        { fieldPath: 'isAnonymous', order: 'ASCENDING' },
        { fieldPath: 'timestamp', order: 'DESCENDING' }
      ]
    }
  ];
  
  console.log('📊 Database indexes defined');
}

// إعداد Remote Config defaults
async function setupRemoteConfig() {
  const defaults = {
    question_of_the_day: "ما هو الشيء الذي تبحث عنه في العلاقة القادمة؟",
    super_hour_enabled: true,
    super_hour_day: "thursday",
    super_hour_start: "20:00",
    super_hour_end: "21:00",
    max_swipes_per_day: 50,
    max_messages_per_day: 100,
    match_algorithm_version: "1.0",
    ads_enabled: true,
    banner_ad_interval: 30,
    interstitial_ad_interval: 5,
    rewarded_ads_daily_limit: 3
  };
  
  try {
    await db.collection('remote_config').doc('defaults').set(defaults);
    console.log('⚙️ Remote Config defaults setup completed');
  } catch (error) {
    console.error('❌ Error setting up Remote Config:', error);
  }
}

// إعداد مستخدم admin افتراضي
async function setupAdminUser() {
  try {
    const adminUser = {
      email: 'admin@truelove.app',
      password: 'Admin@2024!',
      displayName: 'مدير التطبيق',
      emailVerified: true,
      disabled: false
    };
    
    const userRecord = await auth.createUser(adminUser);
    
    // Set custom claims
    await auth.setCustomUserClaims(userRecord.uid, {
      admin: true,
      moderator: true,
      role: 'admin'
    });
    
    // Create admin profile
    await db.collection('users').doc(userRecord.uid).set({
      email: adminUser.email,
      displayName: adminUser.displayName,
      role: 'admin',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true
    });
    
    console.log('👨‍💼 Admin user created:', userRecord.uid);
  } catch (error) {
    console.error('❌ Error creating admin user:', error);
  }
}

// تشغيل جميع الإعدادات
async function setupFirebase() {
  console.log('🔧 Starting Firebase setup...');
  
  await setupFirestoreRules();
  await setupIndexes();
  await setupRemoteConfig();
  await setupAdminUser();
  
  console.log('✅ Firebase setup completed successfully!');
  process.exit(0);
}

// Run setup
setupFirebase().catch(console.error);