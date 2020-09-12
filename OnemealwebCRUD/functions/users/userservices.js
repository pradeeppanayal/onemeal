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
const useraccess  =  require('./authentication.js');
const CommonUtils = require('../common/CommonUtils.js');
const userDoa = require('./userDOA.js');

//routes
app.get("/helloworld",useraccess.checkIfAuthenticated,(req,res)=>{
    return res.status(200).send("hello all")
});

//add a user
app.post("/api/users",useraccess.checkIfAuthenticated,(req,res)=>{
    (async() => {

        try{
            const doc = db.collection("users").doc("/"+ req.body.username + "/" );
            const currentVal  = await doc.get();
            if(currentVal.exists)
                return await updateuserInfo(req,res,req.body.username); 
            var userdata = {
                username: req.body.username,
                displayName : req.body.displayName ,
                email : req.body.email,
                userId: req.body.userId,
                createdOn: CommonUtils.getTimeAsLong(),
                photoUrl: req.body.photoUrl ? req.body.photoUrl:"",
                preferredName:req.body.displayName
            }     
            if(req.body.notificationToken)
                userdata.notificationToken = req.body.notificationToken;
                
            await doc.create(userdata);
            return res.status(200).send(commonUtil.prepareBody("Success"));
        }catch(err){
            console.error(err);
            return res.status(500).send(commonUtil.prepareBody("Something went wrong"));
        }
    })();
});

//get user info
app.get("/api/users/:username",useraccess.checkIfAuthenticated,(req,res)=>{
    (async() => {

        try{ 
            let user = await userDoa.getUser(req.params.username);
            if(!user)
                return res.status(404).send(commonUtil.prepareBody("User does not exist."));            
            return res.status(200).send(user);
        }catch(err){
            console.error(err);
            return res.status(500).send(commonUtil.prepareBody("Something went wrong"));
        }
    })();
});

//get all user info
app.get("/api/users",useraccess.checkIfAuthenticated,(req,res)=>{
    (async() => {

        try{ 
            const document = db.collection("users");//.doc(req.params.username);
            
            let respose  =[]
            await document.get().then(item=>{
                const docs= item.docs;
                for(let doc of docs){
                    respose.push(doc.data());
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

const updateuserInfo =  async function(req,res,username){
    const document = db.collection("users").doc(username);
    const currentVal = await document.get();

    if(!currentVal.exists)
        return res.status(404).send(commonUtil.prepareBody("User does not exist."));
        
    //update user info
    const updatedVal = currentVal.data();
    if(req.body.notificationToken)
        updatedVal.notificationToken = req.body.notificationToken;
    if(req.body.location)
        updatedVal.location = new admin.firestore.GeoPoint (req.body.location._latitude,req.body.location._longitude);
    if(req.body.displayName)
        updatedVal.displayName = req.body.displayName;
    if(req.body.photoUrl)
        updatedVal.photoUrl = req.body.photoUrl;
    if(req.body.preferredName)
        updatedVal.preferredName = req.body.preferredName;

    updatedVal.lastUpdated = CommonUtils.getTimeAsLong();
    
    await document.update(updatedVal);
    return res.status(200).send(commonUtil.prepareBody("Success"));
}

//update a user
app.put("/api/users/:username",useraccess.checkIfAuthenticated,(req,res)=>{
    (async() => {

        try{
            var user = updateuserInfo(req,res,req.params.username);
            return {
                displayName: user.displayName,
                preferredName: user.preferredName,
                userId: user.userId
            };
        }catch(err){
            console.error(err);
            return res.status(500).send(commonUtil.prepareBody("Something went wrong"));
        }
    })();
});

//delete a user
app.delete("/api/users/:username",useraccess.checkIfAuthenticated,(req,res)=>{
    (async() => {

        try{
            const document = db.collection("users").doc(req.params.username);
            await document.delete();
            return res.status(200).send(commonUtil.prepareBody("Success"));
        }catch(err){
            console.error(err);
            return res.status(500).send(commonUtil.prepareBody("Something went wrong"));
        }
    })();
});

//
exports.app = functions.https.onRequest(app);
