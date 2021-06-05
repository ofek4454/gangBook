const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();
const database = admin.firestore();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.deletePassedMeets = functions.pubsub.schedule("00 00 * * *").onRun(async (context)=>{
    const allGangs = await database.collection("gangs").get();
    allGangs.forEach(async (gang)=>{
        const meetsThatPassed = await gang.ref.collection("meets")
        .where("meetingAt", "<=" , admin.firestore.Timestamp.now())
        .get();
        meetsThatPassed.forEach(async (meet)=>{
            await gang.ref.update({
                "meetIds" : admin.firestore.FieldValue.arrayRemove(meet.id)
            });
        });
    });
});


