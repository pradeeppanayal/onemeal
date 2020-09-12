/*
/* @author  : Pradeep CH
/* @version : 1.0
*/

const functions = require('firebase-functions');
const admin = require('firebase-admin');

var serviceAccount = require("./adminpermission.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://onemealwh.firebaseio.com"
});

const userservices = require('./users/userservices');
const orderservices = require('./orders/orderservices');
//const ordernotification = require('./orders/notification');
//
exports.userservices = functions.https.onRequest(userservices.app);
exports.orderservices = functions.https.onRequest(orderservices.app);
//exports.ordernotification = ordernotification.createdAnOrder;
