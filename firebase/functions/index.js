/**
 * Cloud Function: envoie les push FCM quand un doc est ajouté dans notification_queue
 *
 * Déploiement:
 *   cd firebase
 *   firebase functions:create -- or init
 *   cd functions && npm install firebase-admin firebase-functions
 *   firebase deploy --only functions
 *
 * Nécessite le plan Blaze (pay-as-you-go) pour Cloud Functions.
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendQueuedNotification = functions.firestore
  .document("notification_queue/{id}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data || data.sent) return null;

    const toUserId = data.toUserId;
    if (!toUserId) return null;

    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(toUserId)
      .get();

    if (!userDoc.exists) {
      await snap.ref.update({ sent: false, error: "user_not_found" });
      return null;
    }

    const fcmToken = userDoc.data().fcmToken;
    if (!fcmToken) {
      await snap.ref.update({ sent: false, error: "no_token" });
      return null;
    }

    const payload = {
      token: fcmToken,
      notification: {
        title: data.title || "eFoot Arena",
        body: data.body || "",
      },
      data: {
        type: data.type || "general",
        route: data.route || "/",
        ...(data.data || {}),
      },
      android: {
        priority: "high",
        notification: {
          channelId: "efoot_arena_channel",
        },
      },
    };

    try {
      await admin.messaging().send(payload);
      await snap.ref.update({
        sent: true,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (err) {
      console.error("FCM send error", err);
      await snap.ref.update({
        sent: false,
        error: String(err.message || err),
      });
    }

    return null;
  });
