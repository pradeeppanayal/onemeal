/*
/* @author  : Pradeep CH
/* @version : 1.0
*/

const functions = require('firebase-functions');

const admin = require('firebase-admin');
const commonUtil  =  require('../common/CommonUtils.js');

const userDoa =  require('../users/userDOA.js');

const db = admin.firestore();

exports.createdAnOrder = functions.firestore
    .document('orders/{date}/items/{orderId}')
    .onCreate((snap, context) => {
      // Get an object representing the document
      // e.g. {'name': 'Marie', 'age': 66}
      const newValue = snap.data();

      // access a particular field as you would any JS property
      const name = newValue.name;

      // perform desired operations ...
      //console.log(newValue);
      notifyNearByUsers(newValue);
}); 

async function notifyNearByUsers(val) {
    if(!val || !val.location)
        return;        
    const locationRange = commonUtil. getLocationRange(val.location,1);

    var options = getOptions();

    var payload = {
        notification: {
          title: "Hunger Reported",
          body: "A hunger has been reported near by."
        },
        data:{id:val.id?val.id:"no id"}
    };
    
    const dateDocs = db.collection('users');
    await dateDocs.where("location",">",locationRange.lesserGeopoint)
                .where("location","<",locationRange.greaterGeopoint)
    .get().then(snapshot=>{
        if(snapshot.empty){
            console.log("No user found near the area for the order :"+val.id);
            return snapshot;
        }
        snapshot.forEach(doc=>{
            let val= doc.data();
            val.id = doc.id; 
            //TODO check the user if the user is author ignore
            if(!val.notificationToken)
                return val.id;
            sendNotification(val.notificationToken, payload, options);
            return val.id;
        });
        return snapshot;
    });
}

async function notifyUserServed(val) {
    var reporterId = val.reporterId
    var servedBy = val.servedBy;
    if(!reporterId || !servedBy)
        return;
    var reporter = await userDoa.getUser(reporterId);

    if(!reporter || !reporter.notificationToken)
        return; 

    var options = getOptions();
    var payload = {
        notification: {
          title: "Meal Served",
          body: "One of your reported hungers has been served by '"+servedBy +"' "
        },
        data:{id:val.id?val.id:"no id"}
    };
    sendNotification(reporter.notificationToken,payload,options);    
}

function getOptions(){
    return {
        priority: "normal",
        timeToLive: 60 * 60 * 3 //3 hrs
    };
}

function sendNotification(notificationToken,payload,options){
    admin.messaging().sendToDevice(notificationToken, payload, options)
    .then(function(response) {
      //console.log("Successfully sent message:", response);
      return null;
    })
    .catch(function(error) {
      console.log("Error sending message:", error);
    }); 
}

module.exports={
    notifyUserServed,notifyNearByUsers
}