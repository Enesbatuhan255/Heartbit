"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendPushNotification = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();
const MAX_TITLE_LENGTH = 120;
const MAX_BODY_LENGTH = 500;
async function validateNotificationPayload(data) {
    var _a;
    const targetUserId = typeof data.targetUserId === "string" ? data.targetUserId.trim() : "";
    const fromUserId = typeof data.fromUserId === "string" ? data.fromUserId.trim() : "";
    const coupleId = typeof data.coupleId === "string" ? data.coupleId.trim() : "";
    const type = typeof data.type === "string" ? data.type.trim() : "general";
    const title = typeof data.title === "string" ? data.title.trim() : "HeartBit";
    const body = typeof data.body === "string" ? data.body.trim() : "Yeni bir bildirim var!";
    const sessionId = typeof data.sessionId === "string" ? data.sessionId.trim() : "";
    if (!targetUserId || !fromUserId || !coupleId) {
        return null;
    }
    if (targetUserId === fromUserId) {
        return null;
    }
    if (title.length > MAX_TITLE_LENGTH || body.length > MAX_BODY_LENGTH) {
        return null;
    }
    const coupleDoc = await db.collection("couples").doc(coupleId).get();
    if (!coupleDoc.exists) {
        return null;
    }
    const coupleData = (_a = coupleDoc.data()) !== null && _a !== void 0 ? _a : {};
    const user1Id = coupleData.user1Id;
    const user2Id = coupleData.user2Id;
    const validPair = (fromUserId === user1Id && targetUserId === user2Id) ||
        (fromUserId === user2Id && targetUserId === user1Id);
    if (!validPair) {
        return null;
    }
    return {
        targetUserId,
        fromUserId,
        coupleId,
        type,
        title,
        body,
        sessionId,
    };
}
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
    const safePayload = await validateNotificationPayload(data);
    if (!safePayload) {
        await snapshot.ref.update({
            sent: false,
            rejected: true,
            error: "Invalid notification payload or unauthorized sender/target pair",
        });
        return null;
    }
    const targetUserId = safePayload.targetUserId;
    const title = safePayload.title;
    const body = safePayload.body;
    const notificationType = safePayload.type;
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
            coupleId: safePayload.coupleId,
            sessionId: safePayload.sessionId,
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