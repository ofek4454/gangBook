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

exports.notifyOnMeetCreation = functions.firestore.document("gangs/{gang}/meets/{meet}")
.onCreate((snapshot, context)=>{
    const gangDoc = snapshot.ref.parent.parent;
    console.log("called gangId: " + gangDoc.id + " createdMeetId: " + snapshot.id);
    return admin.messaging().sendToTopic(gangDoc.id+"Meets" ,
    {notification: {
        title: "new meet is schedulled in your gang!", 
        body: snapshot.data().title, 
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
    } 
});
});

exports.notifyOnMessageCreation = functions.firestore.document("gangs/{gang}/chat/{message}")
.onCreate(async(snapshot, context)=>{
    const gangDoc = snapshot.ref.parent.parent;
    //const gang = await gangDoc.get();
    const sender = JSON.parse(snapshot.data().sender);
    console.log("called gangId: " + gangDoc.id + " createdMessageId: " + snapshot.id);
    return admin.messaging().sendToTopic(gangDoc.id+"Chat" ,
    {notification: {
        title: sender.name, //gang.data().name,
        body: snapshot.data().message, //sender.name + "\n" + snapshot.data().message,
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
    }
}); 
});

exports.notifyLeaderOnJoinRequest = functions.firestore.document("gangs/{gang}")
.onUpdate(async(change, context)=>{
    const oldGangData = change.before.data();
    const newGangData = change.after.data();
    const oldRequsts = oldGangData.joinRequests;
    const newRequests = newGangData.joinRequests;
    if(oldRequsts.length != newRequests.length){
        return admin.messaging().sendToTopic(gangDoc.id+"Leader" ,
        {notification: {
            title: "New request to join you gang!", //gang.data().name,
            body: "Click to approve/denie requst", //sender.name + "\n" + snapshot.data().message,
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        }
    }); 
    }
});
