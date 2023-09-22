const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");
const functions = require("firebase-functions");
//const {onRequest} = require("firebase-functions/v2/https");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const { defineInt, defineString, defineSecret } = require('firebase-functions/params');
const secretStripeKey = defineSecret("STRIPE_SECRET_KEY");
//const testStripeKey = defineSecret("TEST_KEY");
//const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);
const admin = require("firebase-admin");
admin.initializeApp();

exports.deleteStripeCustomer = functions.region('europe-west2').https.onRequest(async (req, res) => {
  try {
    const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);
    const { customerId } = req.body;
    log(req.body);
    const customer = await stripe.customers.retrieve(customerId);

    if (!customer) {
      // If the customer doesn't exist, return an error message
      res.status(404).json({ error: 'Customer not found.' });
      return;
    }
    // Delete the customer in Stripe
    await stripe.customers.del(customerId);
    // Return a success message
    res.status(200).json({ message: 'Customer deleted successfully.' });
  } catch (err) {
    console.error(error);
    res.status(500).json({ error: err });
  }
});

exports.createStripeSetupIntent = functions.region('europe-west2').https.onRequest(async (req, res) => {
  try {
    const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);
    // Get the user's Firebase UID from the request (You need to authenticate the user)
    const { uid } = req.body;
    const userRecord = await admin.auth().getUser(uid);
    // Check if the user already has a Stripe customer ID associated with their account
    const customer = await stripe.customers.list({ email: userRecord.email });
    let stripeCustomerId;
    if (customer.data.length === 0) {
        const stripeCustomer = await stripe.customers.create({
        email: userRecord.email,
        // You can add more customer data here as needed
      });
      stripeCustomerId = stripeCustomer.id;
      // Associate the Stripe customer ID with the Firebase user UID
      await admin.firestore().collection('Users').doc(uid).update({
        StripeCustomerId: stripeCustomer.id,
      });
    } else {
      stripeCustomerId = customer.data[0].id;
    }
    // Create a Setup Intent for the customer
    const setupIntent = await stripe.setupIntents.create({
      customer: stripeCustomerId, // Use existing customer ID if available
      usage: 'off_session', // Indicates that this Setup Intent is for future off-session payments
    });

    // Return the Setup Intent client secret to the client
    res.status(200).json({
    clientSecret: setupIntent.client_secret,
    customerId: stripeCustomerId,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err });
  }
});

exports.checkCustomerSubscriptions = functions.region('europe-west2').https.onRequest(async (req, res) => {
  try {
    const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);
    // Extract the customerId from the request body
    const { customerId } = req.body;

    // Retrieve the customer from Stripe using the customerId
    const customer = await stripe.customers.retrieve(customerId);

    if (!customer) {
      // If the customer doesn't exist, return an error message
      res.status(404).json({ error: 'Customer not found.' });
      return;
    }

    // Retrieve the customer's subscriptions from Stripe
    const subscriptions = await stripe.subscriptions.list({
      customer: customerId,
    });

    const activeSubscriptions = subscriptions.data.filter(subscription => subscription.plan.active === true);

    if (activeSubscriptions.length > 0) {
      res.status(200).json({ hasActiveSubscriptions: true });
    } else {
      res.status(200).json({ hasActiveSubscriptions: false });
    }
  } catch (err) {
    console.error(error);
    res.status(500).json({ error: err });
  }
});

exports.makeDefaultPayment = functions.region('europe-west2').https.onRequest(async (req, res) => {
  try {
      const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);
    const {customerId, paymentId } = req.body; // Include the user UID, Stripe Customer ID, and plan ID in the request body

    await stripe.customers.update(customerId, {
          invoice_settings: {
            default_payment_method: paymentId,
          },
        });

    res.status(200).json({message: "succeeded"});
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

exports.createStripeSubscription = functions.region('europe-west2').https.onRequest(async (req, res) => {
  try {
      const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);
    const {uid, customerId, planId } = req.body; // Include the user UID, Stripe Customer ID, and plan ID in the request body

    // Create a subscription for the user
    const subscription = await stripe.subscriptions.create({
      customer: customerId,
      items: [{ plan: planId }], // Replace with your specific plan ID
      // You can add more subscription options here as needed
    });

    await admin.firestore().collection('Users').doc(uid).update({
            Subscribed: true,
          });

    // Return the created subscription object to the client
    res.status(200).json({ subscription });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

exports.deleteStripeSubscription = functions.region('europe-west2').https.onRequest(async (req, res) => {
  try {
      const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);
     const sig = req.headers['stripe-signature'];

    // Create a subscription for the user
    let event;

      try {
      const requestBodyString = Buffer.from(req.body).toString();
        event = stripe.webhooks.constructEvent(requestBodyString, sig, process.env.STRIPE_DEL_SECRET);
      } catch (err) {
        res.status(400).send(`Webhook Error: ${err.message}`);
        return;
      }

      // Handle the event
      switch (event.type) {
        case 'customer.subscription.deleted':
          const customerSubscriptionDeleted = event.data.object;

          const userSnapshot = await admin.firestore().collection('Users')
                  .where('StripeCustomerId', '==', customerId)
                  .get();

                // Update the "Subscribed" field to false for the matching document
                if (!userSnapshot.empty) {
                  const userDoc = userSnapshot.docs[0];
                  await userDoc.ref.update({
                    Subscribed: false,
                  });
                }
          break;
        // ... handle other event types
        default:
          console.log(`Unhandled event type ${event.type}`);
      }
    res.status(200).json({ message : "subscription deleted successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

exports.checkDefaultPaymentMethod = functions.region('europe-west2').https.onRequest(async (req, res) => {
  try {
        const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);

    const { customerId } = req.body; // Include the Stripe Customer ID in the request body


    const customer = await stripe.customers.retrieve(customerId);

    // Check if the customer has a default payment method set
    const hasDefaultPaymentMethod = !!customer.invoice_settings.default_payment_method;

    let paymentMethod = null;

    // If a default payment method is set, retrieve its details
    if (hasDefaultPaymentMethod) {
      // Retrieve the payment method using retrievePaymentMethod
      const paymentMethodId = customer.invoice_settings.default_payment_method;
      const paymentMethod = await stripe.paymentMethods.retrieve(paymentMethodId);

    }

    // Return the result to the client
    res.status(200).json({ hasDefaultPaymentMethod, paymentMethod });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err });
  }
});

exports.updateEmailVerificationStatus = functions.region('europe-west2').pubsub.schedule("every day 00:00").timeZone("GMT").onRun(async (context) => {
    try {
        // Query for users with emailVerified == false
        const usersQuery = await admin.firestore().collection("Users").where("EmailVerified", "==", false).get();

        const batch = admin.firestore().batch();

        // Check email verification status for each user
        usersQuery.forEach(async (doc) => {
            const user = doc.data();

            // Check if the user has verified their email
            if (user.emailVerified) {
                // Update the email verification status for this user
                batch.update(doc.ref, { emailVerified: true });
                console.log(`Email verification status updated for user ${user.uid}`);
            }
        });

        // Commit the batch update
        await batch.commit();

        console.log("Email verification status update completed.");
    } catch (err) {
        console.error("Error updating email verification status:", err);
    }
    return null;
});

exports.pruneTokens = functions.region('europe-west2').pubsub.schedule('0 0 1,16 * *').timeZone('GMT').onRun(async (context) => {
  const EXPIRATION_TIME = 1000 * 60 * 60 * 24 * 182;

  const staleTokensResult = await admin.firestore().collection('fcmTokens')
      .where("timestamp", "<", Date.now() - EXPIRATION_TIME)
      .get();
  // Delete devices with stale tokens
  staleTokensResult.forEach(function(doc) { doc.ref.delete(); });
});

exports.sendGroupNotification = functions.https.onRequest(async (req, res) => {
  // Get the list of recipient user IDs and the message from the request
  const recipientUserIds = req.body.recipientUserIds;
  const message = req.body.message;
  const groupName = req.body.groupName;

  // Look up the device tokens of all recipients in the "fcmTokens" collection
  const db = admin.firestore();
  const fcmTokensRef = db.collection('fcmTokens');

  const recipientTokens = await Promise.all(
    recipientUserIds.map(async (userId) => {
      const doc = await fcmTokensRef.doc(userId).get();
      if (doc.exists) {
        const recipientData = doc.data();
        return recipientData.token;
      } else {
        console.error(`Recipient user with ID ${userId} not found in "fcmTokens" collection`);
        return null;
      }
    })
  );

  // Filter out null tokens (users not found)
  const validRecipientTokens = recipientTokens.filter((token) => token !== null);

  if (validRecipientTokens.length === 0) {
    console.error('No valid recipient tokens found');
    return res.status(404).send('No valid recipient tokens found');
  }

  // Send a push notification to all valid recipient devices
  const payload = {
    notification: {
      title: groupName,
      body: message,
    },
  };

  const options = {
    priority: 'high',
    timeToLive: 60 * 60 * 24, // 24 hours
  };

  try {
    const response = await admin.messaging().sendToDevice(validRecipientTokens, payload, options);
    console.log('Notification sent successfully:', response);
    return res.status(200).send('Notification sent successfully');
  } catch (error) {
    console.error('Error sending notification:', error);
    return res.status(500).send('Error sending notification');
  }
});

exports.sendCustomNotification = functions.https.onRequest(async (req, res) => {
  try {
    const { senderName, deviceId, notificationType } = req.body;

    const docSnapshot = await docRef.get();
        if (docSnapshot.exists) {
          const deviceToken = docSnapshot.data().Token;

          // Respond with the retrieved token
          response.status(200).json({ token });
        }

    // Ensure deviceToken and notificationType are provided
    if (!deviceId || !notificationType) {
      res.status(400).send('Bad Request: deviceToken and notificationType are required.');
      return;
    }
    var notiTitle = "";
      // Customize the notification based on notificationType
      switch (notificationType) {
        case 'friendRequest':
          notiTitle = `$e has accepted your friend Request!`;
          break;
        case 'groupJoin':
          notiTitle = `$e has accepted your group application!`;
          break;
        // Add more cases for other notification types as needed
        default:
          // Default notification
          payload.notification.body = 'MoveIn notification!';
          break;
      }

      const payload = {
          notification: {
            title: notiTitle,
          },
        };

        const options = {
          priority: 'high',
          timeToLive: 60 * 60 * 24, // 24 hours
        };

      // Send the notification to the specified device token
      admin.messaging().sendToDevice(deviceToken, payload, options);

    // Respond with a success message
    res.status(200).send('Notification sent successfully.');
  } catch (error) {
    console.error('Error sending notification:', error);
    res.status(500).send('Internal Server Error');
  }
});