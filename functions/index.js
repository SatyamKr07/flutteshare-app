const functions = require('firebase-functions');
const admin = require('firebase-admin');
//const admin = require('firebase - admin'); by mistake i did it like this a got error and watsed lots of time. 
//admin.initilizeApp();// this is also wrong
admin.initializeApp(functions.config().functions);

//creating onCreateFollower functions
exports.onCreateFollower = functions.firestore
    .document("/followers/{userId}/userFollowers/{followerId}")
    .onCreate(async (snapshot, context) => {
        console.log('follower created', snapshot.id)
        //console.log('follower created', snapshot.data())
        const userId = context.params.userId
        const followerId = context.params.followerId

        //create followed users post ref
        //equivalent of firestore.instance.collection
        const followedUserPostRef = admin
            .firestore()
            .collection('posts')
            .doc(userId)
            .collection('userPosts')

        //create following user's timeline ref.
        const timelinePostRef = admin
            .firestore()
            .collection('timeline')
            .doc(followerId)
            .collection('timelinePosts')

        //3) get followed user post
        const querySnapshot = await followedUserPostRef.get();
        //4)Add each user post to following user timeline.
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                const postId = doc.id //postId is custom id
                //const postData = doc.data;// doc.data is wrong...note it
                const postData = doc.data();
                timelinePostRef.doc(postId).set(postData)
            }
        })
    })

//
exports.onDeleteFollower = functions.firestore
    .document("/followers/{userId}/userFollowers/{followerId}")
    .onDelete(async (snapshot, context) => {
        console.log('follower deleted', snapshot.id)
        const userId = context.params.userId
        const followerId = context.params.followerId

        const timelinePostRef = admin
            .firestore()
            .collection('timeline')
            .doc(followerId)
            .collection('timelinePosts')
            .where('ownerId', "==", userId)

        const querySnapshot = await timelinePostRef.get();
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                doc.ref.delete();
            }
        })
    })

// // When a post is created, add post to timeline of each follower of post owner.
exports.onCreatePost = functions.firestore
    .document('/posts/{userId}/userPosts/{postId}')
    .onCreate(async (snapshot, context) => {
        const postCreated = snapshot.data();
        const userId = context.params.userId
        const postId = context.params.postId

        //get all the followers of the user who made the post.
        const userFollowersRef = admin
            .firestore()
            .collection('followers')
            .doc(userId)
            .collection('userFollowers')

        const querySnapshot = await userFollowersRef.get();
        //add new post to each followers timeline
        querySnapshot.forEach(doc => {
            const followerId = doc.id;

            admin
                .firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId)
                .set(postCreated)
        })
    })

exports.onUpdatePost = functions.firestore
    .document('/posts/{userId}/userPosts/{postId}')
    .onUpdate(async (change, context) => {
        const postUpdated = change.after.data();
        const userId = context.params.userId
        const postId = context.params.postId
        //get all the followers of the user who made the post.
        const userFollowersRef = admin
            .firestore()
            .collection('followers')
            .doc(userId)
            .collection('userFollowers')

        const querySnapshot = await userFollowersRef.get();
        //update each post in each followers timeline
        querySnapshot.forEach(async doc => {
            const followerId = doc.id;
            await admin
                .firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId)
                .get();
            if (doc.exists) {
                doc.ref.update(postUpdated);
            }
        })
    })

// exports.onDeletePost = functions.firestore
//     .document('/posts/{userId}/userPosts/{postId}')
//     .onDelete(async (snapshot, context) => {
//         const userId = context.params.userId
//         const postId = context.params.postId

//         //get all the followers of the user who made the post.
//         const userFollowersRef = admin
//             .firestore()
//             .collection('followers')
//             .doc(userId)
//             .collection('userFollowers')

//         const querySnapshot = await userFollowersRef.get();
//         //update each post in each followers timeline
//         querySnapshot.forEach(doc => {
//             const followerId = doc.id;

//             admin
//                 .firestore()
//                 .collection('timeline')
//                 .doc(followerId)
//                 .collection('timelinePosts')
//                 .doc(postId)
//                 .get().then(doc => {
//                     if (doc.exists) {
//                         doc.ref.delete()
//                     }
//                 })
//         })
//     })

exports.onDeletePost = functions.firestore
    .document('/posts/{userId}/userPosts/{postId}')
    .onDelete(async (snapshot, context) => {
        const userId = context.params.userId
        const postId = context.params.postId

        //get all the followers of the user who made the post.
        const userFollowersRef = admin
            .firestore()
            .collection('followers')
            .doc(userId)
            .collection('userFollowers')

        const querySnapshot = await userFollowersRef.get();
        //update each post in each followers timeline
        querySnapshot.forEach(async doc => {
            const followerId = doc.id;

            admin
                .firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId)
                .get();
            if (doc.exists) {
                doc.ref.delete()
            }
        })
    })

//"lint": "eslint .",
// "eslint": "^5.12.0",
//     "eslint-plugin-promise": "^4.0.1",
// "predeploy": [
//   "npm --prefix \"$RESOURCE_DIR\" run lint"
// ],
exports.sendNotification = functions.firestore
    .document('messagesList/{groupId1}/{groupId2}/{message}')
    .onCreate((snap, context) => {
        console.log('----------------start function--------------------')

        const doc = snap.data()
        console.log(doc)

        const idFrom = doc.idFrom
        const idTo = doc.idTo
        const contentMessage = doc.content

        // Get push token user to (receive)
        admin
            .firestore()
            .collection('users')
            .where('id', '==', idTo)
            .get()
            .then(querySnapshot => {
                querySnapshot.forEach(userTo => {
                    console.log(`Found user to: ${userTo.data().displayName}`)
                    if (userTo.data().pushToken && userTo.data().chattingWith !== idFrom) {
                        // Get info user from (sent)
                        admin
                            .firestore()
                            .collection('users')
                            .where('id', '==', idFrom)
                            .get()
                            .then(querySnapshot2 => {
                                querySnapshot2.forEach(userFrom => {
                                    console.log(`Found user from: ${userFrom.data().displayName}`)
                                    const payload = {
                                        notification: {
                                            title: `You have a message from "${userFrom.data().displayName}"`,
                                            body: contentMessage,
                                            badge: '1',
                                            sound: 'default'
                                        }
                                    }
                                    // Let push to the target device
                                    admin
                                        .messaging()
                                        .sendToDevice(userTo.data().pushToken, payload)
                                        .then(response => {
                                            console.log('Successfully sent message:', response)
                                        })
                                        .catch(error => {
                                            console.log('Error sending message:', error)
                                        })
                                })
                            })
                    } else {
                        console.log('Can not find pushToken target user')
                    }
                })
            })
        return null
    });