import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();
const MAX_TITLE_LENGTH = 120;
const MAX_BODY_LENGTH = 500;

type SafeNotificationPayload = {
    targetUserId: string;
    fromUserId: string;
    coupleId: string;
    type: string;
    title: string;
    body: string;
    sessionId: string;
};

async function validateNotificationPayload(data: FirebaseFirestore.DocumentData): Promise<SafeNotificationPayload | null> {
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

    const coupleData = coupleDoc.data() ?? {};
    const user1Id = coupleData.user1Id as string | undefined;
    const user2Id = coupleData.user2Id as string | undefined;
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
export const sendPushNotification = functions.firestore
    .document("notifications/{notificationId}")
    .onCreate(async (snapshot, context) => {
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

        const fcmToken = userDoc.data()?.fcmToken as string | undefined;

        if (!fcmToken) {
            console.log(`No FCM token for user ${targetUserId}`);
            return null;
        }

        // Build the FCM message
        const message: admin.messaging.Message = {
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
        } catch (error) {
            console.error("Error sending notification:", error);

            // Mark notification as failed
            await snapshot.ref.update({
                sent: false,
                error: String(error),
            });

            return null;
        }
    });
