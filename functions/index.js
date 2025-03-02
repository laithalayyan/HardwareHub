/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require('firebase-functions');
const axios = require('axios');

exports.chatWithGemini = functions.https.onRequest(async (req, res) => {
  const { message, imageUrl } = req.body;

  try {
    const response = await axios.post('https://api.gemini.com/v1/chat', {
      message,
      imageUrl,
      apiKey: process.env.GEMINI_API_KEY, // Store your API key in Firebase environment config
    });

    res.status(200).json(response.data);
  } catch (error) {
    res.status(500).json({ error: 'Failed to communicate with Gemini API' });
  }
});