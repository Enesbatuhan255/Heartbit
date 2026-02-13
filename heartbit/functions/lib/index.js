"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendPushNotification = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();
/**
 * Cloud Function that sends FCM push notification when a new notification
 * document is created in Firestore.
 *
 * Triggers on: /notifications/{notificationId}
 */
exports.sendPushNotification = functions.firestore
    .document("notifications/{notificationId}")
    .onCreate(async (snapshot, context) => {
    var _a;
    const data = snapshot.data();
    if (!data) {
        console.log("No data in notification document");
        return null;
    }
    const targetUserId = data.targetUserId;
    const title = data.title || "HeartBit";
    const body = data.body || "Yeni bir bildirim var!";
    const notificationType = data.type;
    console.log(`Sending notification to user: ${targetUserId}`);
    console.log(`Type: ${notificationType}, Title: ${title}`);
    // Get target user's FCM token
    const userDoc = await db.collection("users").doc(targetUserId).get();
    if (!userDoc.exists) {
        console.log(`User ${targetUserId} not found`);
        return null;
    }
    const fcmToken = (_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.fcmToken;
    if (!fcmToken) {
        console.log(`No FCM token for user ${targetUserId}`);
        return null;
    }
    // Build the FCM message
    const message = {
        token: fcmToken,
        notification: {
            title: title,
            body: body,
        },
        data: {
            type: notificationType || "general",
            notificationId: context.params.notificationId,
            coupleId: data.coupleId || "",
            sessionId: data.sessionId || "",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        android: {
            priority: "high",
            notification: {
                channelId: "heartbit_notifications",
                priority: "high",
                defaultSound: true,
                defaultVibrateTimings: true,
            },
        },
        apns: {
            payload: {
                aps: {
                    alert: {
                        title: title,
                        body: body,
                    },
                    sound: "default",
                    badge: 1,
                },
            },
        },
    };
    try {
        const response = await messaging.send(message);
        console.log(`Successfully sent notification: ${response}`);
        // Mark notification as sent
        await snapshot.ref.update({
            sent: true,
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return response;
    }
    catch (error) {
        console.error("Error sending notification:", error);
        // Mark notification as failed
        await snapshot.ref.update({
            sent: false,
            error: String(error),
        });
        return null;
    }
});
//# sourceMappingURL=index.js.map