const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { CloudTasksClient } = require('@google-cloud/tasks');
const vision = require('@google-cloud/vision');
const language = require('@google-cloud/language');

admin.initializeApp();

const db = admin.firestore();
const auth = admin.auth();
const messaging = admin.messaging();
const visionClient = new vision.ImageAnnotatorClient();
const languageClient = new language.LanguageServiceClient();
const tasksClient = new CloudTasksClient();

// 1. دالة المطابقة الذكية
exports.matchUsers = functions.firestore
  .document('swipes/{swipeId}')
  .onCreate(async (snap, context) => {
    const swipe = snap.data();
    
    if (swipe.type === 'like') {
      // Check for mutual like
      const mutualSwipe = await db.collection('swipes')
        .where('userId', '==', swipe.targetUserId)
        .where('targetUserId', '==', swipe.userId)
        .where('type', '==', 'like')
        .limit(1)
        .get();
      
      if (!mutualSwipe.empty) {
        // Create match
        const matchId = `${swipe.userId}_${swipe.targetUserId}`;
        await db.collection('matches').doc(matchId).set({
          userId1: swipe.userId,
          userId2: swipe.targetUserId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          isActive: true
        });
        
        // Send notification
        await sendMatchNotification(swipe.userId, swipe.targetUserId);
        await sendMatchNotification(swipe.targetUserId, swipe.userId);
      }
    }
    
    // Update user swipe count
    await db.collection('users').doc(swipe.userId).update({
      swipeCount: admin.firestore.FieldValue.increment(1),
      lastSwipeAt: admin.firestore.FieldValue.serverTimestamp()
    });
  });

// 2. دالة الإشراف على المحتوى
exports.moderateContent = functions.firestore
  .document('community_posts/{postId}')
  .onCreate(async (snap, context) => {
    const post = snap.data();
    let isApproved = true;
    let violations = [];
    
    // Moderate text content
    if (post.content) {
      const [textAnalysis] = await languageClient.analyzeSentiment({
        document: {
          content: post.content,
          type: 'PLAIN_TEXT',
        },
      });
      
      // Check for toxic content
      if (textAnalysis.documentSentiment.score < -0.6) {
        isApproved = false;
        violations.push('negative_sentiment');
      }
    }
    
    // Moderate images
    if (post.imageUrl) {
      const [imageAnalysis] = await visionClient.safeSearchDetection(post.imageUrl);
      const safeSearch = imageAnalysis.safeSearchAnnotation;
      
      if (safeSearch.adult === 'LIKELY' || safeSearch.adult === 'VERY_LIKELY' ||
          safeSearch.violence === 'LIKELY' || safeSearch.violence === 'VERY_LIKELY' ||
          safeSearch.racy === 'LIKELY' || safeSearch.racy === 'VERY_LIKELY') {
        isApproved = false;
        violations.push('inappropriate_image');
      }
    }
    
    // Update post with moderation result
    await snap.ref.update({
      isApproved,
      violations,
      moderatedAt: admin.firestore.FieldValue.serverTimestamp(),
      moderator: 'ai'
    });
    
    // Send notification if not approved
    if (!isApproved) {
      await sendModerationNotification(post.authorId, post.id);
    }
  });

// 3. دالة الإشعارات
exports.sendNotification = functions.https.onCall(async (data, context) => {
  const { title, body, userId, type, data: payload } = data;
  
  // Get user token
  const userDoc = await db.collection('users').doc(userId).get();
  const token = userDoc.data()?.fcmToken;
  
  if (!token) {
    throw new functions.https.HttpsError('not-found', 'User token not found');
  }
  
  const message = {
    notification: { title, body },
    data: { type: type || 'general', ...payload },
    android: {
      priority: 'high',
      notification: {
        channelId: 'general',
        icon: '@mipmap/ic_launcher',
        color: '#FF6B6B'
      }
    },
    apns: {
      payload: {
        aps: {
          sound: 'default'
        }
      }
    },
    token
  };
  
  await messaging.send(message);
  
  return { success: true };
});

// 4. دالة حساب Decay لـ Elo
exports.calculateEloDecay = functions.pubsub
  .schedule('every 72 hours')
  .onRun(async (context) => {
    const cutoffDate = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 72 * 60 * 60 * 1000)
    );
    
    const inactiveUsers = await db.collection('users')
      .where('lastActive', '<', cutoffDate)
      .get();
    
    const batch = db.batch();
    
    inactiveUsers.docs.forEach(doc => {
      const currentScore = doc.data().eloScore || 1000;
      const newScore = Math.max(800, currentScore * 0.95); // 5% decay
      
      batch.update(doc.ref, {
        eloScore: newScore,
        lastDecayAt: admin.firestore.FieldValue.serverTimestamp()
      });
    });
    
    await batch.commit();
    
    console.log(`Updated ${inactiveUsers.size} users with Elo decay`);
    return null;
  });

// 5. دالة تصدير KPI
exports.exportKPIs = functions.https.onCall(async (data, context) => {
  // Verify admin access
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError('permission-denied', 'Admin access required');
  }
  
  const now = new Date();
  const last24Hours = new Date(now.getTime() - 24 * 60 * 60 * 1000);
  const lastWeek = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
  
  const kpis = {};
  
  // User metrics
  const totalUsers = await db.collection('users').count().get();
  const activeUsers = await db.collection('users')
    .where('lastActive', '>', last24Hours)
    .count().get();
  const newUsers = await db.collection('users')
    .where('createdAt', '>', last24Hours)
    .count().get();
  
  kpis.users = {
    total: totalUsers.data().count,
    active: activeUsers.data().count,
    new: newUsers.data().count
  };
  
  // Engagement metrics
  const swipes = await db.collection('swipes')
    .where('timestamp', '>', last24Hours)
    .count().get();
  const matches = await db.collection('matches')
    .where('createdAt', '>', last24Hours)
    .count().get();
  const messages = await db.collection('messages')
    .where('timestamp', '>', last24Hours)
    .count().get();
  
  kpis.engagement = {
    swipes: swipes.data().count,
    matches: matches.data().count,
    messages: messages.data().count
  };
  
  // Community metrics
  const posts = await db.collection('community_posts')
    .where('createdAt', '>', last24Hours)
    .count().get();
  const reports = await db.collection('reports')
    .where('createdAt', '>', last24Hours)
    .count().get();
  
  kpis.community = {
    posts: posts.data().count,
    reports: reports.data().count
  };
  
  // Store KPIs
  await db.collection('kpis').doc(now.toISOString().split('T')[0]).set({
    ...kpis,
    date: now,
    period: 'daily'
  });
  
  return kpis;
});

// 6. دالة تحديث حالة المستخدم
exports.updateUserStatus = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    
    // Check if user became active
    if (!before.isActive && after.isActive) {
      // Remove from shadow ban
      await db.collection('users').doc(context.params.userId).update({
        shadowBannedAt: null
      });
    }
    
    // Check if user became inactive
    if (before.isActive && !after.isActive) {
      const sevenDaysAgo = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
      );
      
      if (after.lastActive < sevenDaysAgo) {
        // Apply shadow ban
        await db.collection('users').doc(context.params.userId).update({
          shadowBannedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      }
    }
  });

// 7. دالة إدارة الإبلاغات
exports.handleReport = functions.firestore
  .document('reports/{reportId}')
  .onCreate(async (snap, context) => {
    const report = snap.data();
    
    // Get report count for the reported user
    const reportCount = await db.collection('reports')
      .where('reportedUserId', '==', report.reportedUserId)
      .count().get();
    
    const count = reportCount.data().count;
    
    if (count >= 5) {
      // Ban user for 24 hours
      await db.collection('users').doc(report.reportedUserId).update({
        suspendedUntil: admin.firestore.Timestamp.fromDate(
          new Date(Date.now() + 24 * 60 * 60 * 1000)
        ),
        suspensionReason: 'Multiple reports'
      });
      
      // Send notification to reported user
      await sendSuspensionNotification(report.reportedUserId, 24);
    } else if (count >= 3) {
      // Send warning
      await sendWarningNotification(report.reportedUserId, count);
    }
  });

// 8. دالة Super Hour
exports.superHour = functions.pubsub
  .schedule('every thursday 19:30')
  .timeZone('Africa/Cairo')
  .onRun(async (context) => {
    // Send notification to all users
    const users = await db.collection('users').get();
    
    const tokens = users.docs
      .map(doc => doc.data().fcmToken)
      .filter(token => token);
    
    const message = {
      notification: {
        title: 'ساعة السوبر بدأت! ⚡',
        body: 'كل Like = Super Like الآن! استمتع بساعة من المفاجآت'
      },
      data: {
        type: 'super_hour',
        startTime: '20:00',
        endTime: '21:00'
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'super_hour',
          icon: '@mipmap/ic_launcher',
          color: '#FFD700'
        }
      }
    };
    
    // Send in batches
    const batches = [];
    for (let i = 0; i < tokens.length; i += 500) {
      const batch = tokens.slice(i, i + 500);
      batches.push(
        messaging.sendMulticast({
          ...message,
          tokens: batch
        })
      );
    }
    
    await Promise.all(batches);
    
    console.log(`Super Hour notification sent to ${tokens.length} users`);
    return null;
  });

// 9. دالة تنظيف البيانات القديمة
exports.cleanupOldData = functions.pubsub
  .schedule('every day 03:00')
  .onRun(async (context) => {
    const thirtyDaysAgo = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
    );
    
    // Clean old messages
    const oldMessages = await db.collection('messages')
      .where('timestamp', '<', thirtyDaysAgo)
      .limit(1000)
      .get();
    
    const batch = db.batch();
    oldMessages.docs.forEach(doc => batch.delete(doc.ref));
    
    // Clean old swipes
    const oldSwipes = await db.collection('swipes')
      .where('timestamp', '<', thirtyDaysAgo)
      .limit(1000)
      .get();
    
    oldSwipes.docs.forEach(doc => batch.delete(doc.ref));
    
    await batch.commit();
    
    console.log(`Cleaned ${oldMessages.size + oldSwipes.size} old documents`);
    return null;
  });

// 10. دالة إحصائيات الإعلانات
exports.trackAdMetrics = functions.https.onCall(async (data, context) => {
  const { userId, adType, action, revenue } = data;
  
  // Log ad interaction
  await db.collection('ad_metrics').add({
    userId,
    adType,
    action, // impression, click, reward
    revenue: revenue || 0,
    timestamp: admin.firestore.FieldValue.serverTimestamp()
  });
  
  // Update user ad stats
  const userRef = db.collection('users').doc(userId);
  await userRef.update({
    [`adStats.${adType}.${action}`]: admin.firestore.FieldValue.increment(1),
    totalAdRevenue: admin.firestore.FieldValue.increment(revenue || 0)
  });
  
  return { success: true };
});

// Helper functions
async function sendMatchNotification(userId, matchedUserId) {
  const matchedUser = await db.collection('users').doc(matchedUserId).get();
  const matchedUserData = matchedUser.data();
  
  await exports.sendNotification({
    userId,
    title: 'مطابقة جديدة! ❤️',
    body: `لقد تطابقت مع ${matchedUserData.displayName}`,
    type: 'match',
    data: { matchedUserId }
  });
}

async function sendModerationNotification(userId, postId) {
  await exports.sendNotification({
    userId,
    title: 'منشورك يحتاج مراجعة',
    body: 'تم الإبلاغ عن منشورك لانتهاك معايير المجتمع',
    type: 'moderation',
    data: { postId }
  });
}

async function sendSuspensionNotification(userId, hours) {
  await exports.sendNotification({
    userId,
    title: 'تم تعليق حسابك',
    body: `تم تعليق حسابك لمدة ${hours} ساعة بسبب عدة إبلاغات`,
    type: 'suspension'
  });
}

async function sendWarningNotification(userId, reportCount) {
  await exports.sendNotification({
    userId,
    title: 'تحذير',
    body: `لقد تم الإبلاغ عنك ${reportCount} مرات. يرجى الالتزام بمعايير المجتمع`,
    type: 'warning'
  });
}

module.exports = {
  matchUsers: exports.matchUsers,
  moderateContent: exports.moderateContent,
  sendNotification: exports.sendNotification,
  calculateEloDecay: exports.calculateEloDecay,
  exportKPIs: exports.exportKPIs,
  updateUserStatus: exports.updateUserStatus,
  handleReport: exports.handleReport,
  superHour: exports.superHour,
  cleanupOldData: exports.cleanupOldData,
  trackAdMetrics: exports.trackAdMetrics
};