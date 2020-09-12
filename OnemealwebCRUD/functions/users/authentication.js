/**
 * @author Pradeep CH
 * @version 1.0
 */

const admin = require('firebase-admin');

//
const commonUtil  =  require('../common/CommonUtils.js');
const userDoa =  require('./userDOA.js');

const getAuthToken = (req, res, next) => {
    
    if (
      req.headers.authorization &&
      req.headers.authorization.split(' ')[0] === 'Bearer'
    ) {
      req.authToken = req.headers.authorization.split(' ')[1];
      //console.log("req.headers.authorization.split(' ')[1]",req.headers.authorization.split(' ')[1])
    } else {
      req.authToken = null;
    }
    next();
  };

function checkIfAuthenticated(req, res, next){
    getAuthToken(req, res, async () => {
       try {
         const { authToken } = req;
        // console.log("authToken",authToken);
         const userInfo = await admin
           .auth()
           .verifyIdToken(authToken);
         req.authId = userInfo.uid;
         req.currentUser = await userDoa.getUser(userInfo.uid);
         if(!req.currentUser)
            throw Error("Could not find the user");
         return next();
       } catch (e) {
         return res
           .status(401)
           .send(commonUtil.prepareBody('You are not authorized to make this request' ));
       }
       //return next();
     });
   }
   
   // export functions
module.exports ={
    checkIfAuthenticated
}