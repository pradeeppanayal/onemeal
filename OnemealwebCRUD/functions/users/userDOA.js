/*
/* @author  : Pradeep CH
/* @version : 1.0
*/
const admin = require('firebase-admin');

const db = admin.firestore();

async function getUser(uid){
    try{ 
        if(!uid)
            return null;
        const document = db.collection("users").doc(uid);
        let user = await document.get();
        if(!user.exists)
            return null;
        return user.data();
    }catch(err){
        console.error(err);
        throw Error("Something went wrong.");
    }
    //return null;
}

module.exports= {
    getUser
}
