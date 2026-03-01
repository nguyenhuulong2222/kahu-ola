const admin = require("firebase-admin");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");

admin.initializeApp();

exports.sendPublicFireAlert = onDocumentCreated(
  "public_alert_dispatch/{alertId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.warn("No dispatch payload found.");
      return;
    }

    const data = snapshot.data();
    const topics = Array.isArray(data.topics) ? data.topics : [];
    if (topics.length === 0) {
      logger.warn("Dispatch payload missing topics.", {alertId: snapshot.id});
      return;
    }

    const title = data.title || "KAHU OLA ALERT";
    const body =
      data.body || "NASA FIRMS detected a new hotspot in Maui County.";
    const locations = Array.isArray(data.locations) ? data.locations : [];
    const islands = Array.isArray(data.islands) ? data.islands : [];
    const hotspotCount = String(data.hotspotCount || 0);

    const sendPromises = topics.map((topic) =>
      admin.messaging().send({
        topic,
        notification: {
          title,
          body,
        },
        data: {
          source: "nasa_firms",
          alertId: snapshot.id,
          islands: islands.join(","),
          locations: locations.join(","),
          hotspotCount,
        },
        android: {
          priority: "high",
          notification: {
            priority: "max",
            defaultSound: true,
          },
        },
        apns: {
          headers: {
            "apns-priority": "10",
          },
          payload: {
            aps: {
              sound: "default",
            },
          },
        },
      }),
    );

    await Promise.all(sendPromises);
    await snapshot.ref.set(
      {
        status: "sent",
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true},
    );
    logger.info("Public fire alert sent.", {
      alertId: snapshot.id,
      topics,
      hotspotCount,
    });
  },
);
