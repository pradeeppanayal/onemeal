/*
/* @author  : Pradeep CH
/* @version : 1.0
*/

const functions = require('firebase-functions');
const admin = require('firebase-admin');

const express = require('express');
const cors = require('cors');
const app = express();
const db = admin.firestore();

app.use(cors({ orgin:true}));

//
const commonUtil  =  require('../common/CommonUtils.js');
const constants  =  require('../common/Constants.js');
const notification  =  require('./notification');
const useraccess  =  require('../users/authentication.js');



//add a user
app.post("/api/orders",useraccess.checkIfAuthenticated,(req,res)=>{
    (async() => {

        // this one will take the current date into yyyymmdd
        const formattedDateKey= commonUtil.getDate();        
        const addedTime= commonUtil.getTimeAsLong();

        if(!req.body.location)
            return res.status(501).send(commonUtil.prepareBody("Location should be provided"));
        
        if(!req.currentUser.userId)
            return res.status(501).send(commonUtil.prepareBody("Invalid user info "));
        if(constants.MAX_ORDER_PER_USER <= getDailyOrderCount(formattedDateKey,req.currentUser.userId))
            return res.status(501).send(commonUtil.prepareBody("Maximum report count reached."));

        try{
            const document = db.collection("orders").doc("/"+ formattedDateKey + "/" ).collection("items" )
            .doc();
            var dataToBeSaved = {
                reporter: req.currentUser.preferredName?req.currentUser.preferredName:req.currentUser.displayName,
                reporterId: req.currentUser.userId,
                reportTime: addedTime,
                status:'open',
                location:new admin.firestore.GeoPoint (req.body.location._latitude,req.body.location._longitude),
                description: req.body.description
            };
            if(req.body.title)
                dataToBeSaved.title=  req.body.title;
            if(req.body.reporterLocation)
                dataToBeSaved.reporterLocation = new admin.firestore.GeoPoint (req.body.reporterLocation._latitude,req.body.reporterLocation._longitude);

            await document.create(dataToBeSaved);
            var updateddocument= await document.get();
            updateddocument.id = document.id
            notification.notifyNearByUsers(updateddocument.data());

            return res.status(200).send(updateddocument.data());
        }catch(err){
            console.error(err);
            return res.status(500).send(commonUtil.prepareBody("Something went wrong"));
        }
    })();
});
//i have  meal call response
//add a user
app.get("/api/orders",useraccess.checkIfAuthenticated,(req,res)=>{
    (async() => {

        try{
            const username=req.query.username;
            const location= req.query.location;
            if( !location)
                return res.status(501).send(commonUtil.prepareBody("Location should be provided"));
            let parts = location.split(",");
            if(parts.length !== 2)
                return res.status(501).send(commonUtil.prepareBody("Invalid location"));

            let providerlocation;
            try{
                providerlocation= new admin.firestore.GeoPoint(parseFloat(parts[0]),parseFloat(parts[1]));
            }catch(err){
                console.err.log(err);
                return res.status(501).send(commonUtil.prepareBody("Invalid location"));
            }     
            const formattedDateKey= commonUtil.getDate();    
            
            const dateDocs =  db.collection("orders").doc(formattedDateKey).collection("items");
            let respose  =[]

            //location 
            const locationRange = commonUtil. getLocationRange(providerlocation,1);
            //console.log(providerlocation);
            //console.log(locationRange);
            await dateDocs//.where("status","==","open")//
                        .where("location",">",locationRange.lesserGeopoint)
                        .where("location","<",locationRange.greaterGeopoint)
                        //.orderBy("status")
            .get().then(snapshot=>{
                if(!snapshot.empty){
                    snapshot.forEach(doc=>{
                        let val= doc.data();
                        val.id = doc.id; 
                        respose.push(val);
                    });
                    
                }
                return respose;
            });
            return res.status(200).send(respose);
        }catch(err){
            console.error(err);
            return res.status(500).send(commonUtil.prepareBody("Something went wrong"));
        }
    })();
});

async function getDailyOrderCount(formattedDateKey,userId){
    const dateDocs =  db.collection("orders").doc(formattedDateKey).collection("items");
    const orders = await dateDocs.where('reporterId','==',userId).get();
    return orders.size;
}
//get the number of orders and status
app.get("/api/orders/summary",useraccess.checkIfAuthenticated,(req,res)=>{
    (async() => {

        try{                          
            const formattedDateKey= req.query.date? req.query.date: commonUtil.getDate();    
           // console.log("formattedDateKey",formattedDateKey);
            const dateDocs =  db.collection("orders").doc(formattedDateKey).collection("items");
            const col = await dateDocs.get();
            const response =  {
                total:0,
                open:0
            }
            response.total= col.size;
            const opened = await dateDocs.where('status','==','open').get();
            response.open = opened.size;
            response.served  = response.total-response.open;
            response.date  =  formattedDateKey;
                       
            return res.status(200).send(response);
        }catch(err){
            console.error(err);
            return res.status(500).send(commonUtil.prepareBody("Something went wrong"));
        }
    })();
});


//add a user
app.put("/api/orders/:orderid/serve",useraccess.checkIfAuthenticated,(req,res)=>{
    (async() => {

        // this one will take the current date into yyyymmdd
        const formattedDateKey= commonUtil.getDate();        
        const addedTime= commonUtil.getTimeAsLong();

        try{
            const doc = db.collection("orders").doc("/"+ formattedDateKey + "/" )
            .collection("items" ).doc(req.params.orderid);
            const currentval = await doc.get();
            
            if(!currentval.exists)
                return res.status(404).send(commonUtil.prepareBody("Order does not exist."));
            if("open" !== currentval.data().status )
                return res.status(501).send(commonUtil.prepareBody("Invalid order. Order status :"+currentval.data().status));

            //add serve info
            const modifieddata = currentval.data();
            modifieddata.status = "Served";
            modifieddata.serveTime  =addedTime;
            modifieddata.servedBy  = req.currentUser.preferredName?req.currentUser.preferredName:req.currentUser.displayName;
            modifieddata.servedById = req.currentUser.userId;
            if(req.body.comment)
                modifieddata.comment =  req.body.comment;

            await doc.update(modifieddata);
            modifieddata.id = req.params.orderid;
            notification.notifyUserServed(modifieddata);
            return res.status(200).send(commonUtil.prepareBody("Success"));
        }catch(err){
            console.error(err);
            return res.status(500).send(commonUtil.prepareBody("Something went wrong"));
        }
    })();
});
exports.app = functions.https.onRequest(app);
