/*
/* @author  : Pradeep CH
/* @version : 1.0
*/

const admin = require('firebase-admin');


const prepareBody  = function(msg){
    return {message:msg};
};

const getDate = function(msg){        
    const date = new Date();
    return date.getFullYear() +("0" + (date.getMonth()+1)).slice(-2)+("0" + date.getDate()).slice(-2);
};
const getTimeAsLong = function(msg){        
    const date = new Date();
    return (new Date()).getTime();
};

const getLocationRange = function(providerlocation, distance){
    // ~1 mile of lat and lon in degrees
    let lat = 0.0144927536231884
    let lon = 0.0181818181818182
    let lowerLat = providerlocation.latitude - (lat * distance)
    let lowerLon = providerlocation.longitude - (lon * distance)

    let greaterLat = providerlocation.latitude + (lat * distance)
    let greaterLon = providerlocation.longitude  + (lon * distance)

    return{
        lesserGeopoint : new admin.firestore.GeoPoint( lowerLat,  lowerLon),
        greaterGeopoint : new admin.firestore.GeoPoint( greaterLat,  greaterLon)
    }

}
// export functions
module.exports ={
    prepareBody, getDate, getTimeAsLong,getLocationRange
}