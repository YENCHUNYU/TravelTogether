# TravelTogether
## Introduction   
TravelTogether is a platform designed for travel enthusiasts and aims to provide users with a convenient way to plan and share travel itineraries.

## Requirements
Minimun iOS version: 15

## Installation
Please go to App Store to download:
https://apps.apple.com/tw/app/traveltogether/id6474057254

or search "TravelTogether" in App Store.

## Technique Detail
- Implemented the MVC architecture for constructing maintainable code.
- Stored users’ travel itineraries and memories securely by using Firebase Firestore[Firebase Firestore](https://firebase.google.com/docs/firestore).
- Stored and displayed photos of places by leveraging [Firebase Storage](https://firebase.google.com/docs/storage), which enhanced the user experience in itinerary editing.

<img src="./READMEgif/EditPlan.png" alt="Edit Plan" width="300">

- Managed user accounts using [Firebase Authentication](https://firebase.google.com/docs/auth) and offered several login methods, including Native registration (email/password), Google, and Apple.

<img src="./READMEgif/loginN.png" alt="loginN" width="200">  <img src="./READMEgif/loginAG.png" alt="loginAG" width="200">

- Retrieve and display geographical information by integrating [Google Maps SDK](https://developers.google.com/maps/documentation/ios-sdk/overview).

<img src="./READMEgif/googleMap.png" alt="googleMap" width="200">

- Ensured code consistency and quality using [SwiftLint](https://github.com/realm/SwiftLint).

- Utilized [Kingfisher](https://github.com/onevcat/Kingfisher) to efficiently load users' images fetched from APIs, offering good user experience.

- Installed necessary dependencies using [CocoaPods](https://cocoapods.org) for project dependency management.

## Features
- [Explore Users' Memories and Plans](#explore-users-memories-and-plans)
 - [Plan a Trip](#plan-a-trip)
 - [Record and Share Travel Memories](#record-and-share-travel-memories)
 - [Favorite Memories and Plans](#favorite-memories-and-plans)
 - [Profile](#profile)

### Explore Users' Memories and Plans

![ExploreMemories.gif](./READMEgif/exploreMemories.gif)
![ExplorePlans.gif](./READMEgif/explorePlans.gif)

- Explore the travel memories and plans of other users.
- Click the like button to save them to their favorites.
- Click the copy button to copy the user's travel plan.

### Plan a Trip

![EditPlan.gif](./READMEgif/EditPlan.gif)

- Go to "我的行程" to plan the trip.
- Able to add a new day, new location in a trip.
- Able to drag and drop a specific location to change locations' order.

<img src="./READMEgif/sendALink.gif" alt="linkToApp" width="300">  <img src="./READMEgif/linkToApp.gif" alt="linkToApp" width="300">

- User A sends a link to User B, inviting him/her to collaborate on editing the plan.
- User B clicks the link to join the editing.

### Record and Share Travel Memories
![MemoryDraft.gif](./READMEgif/MemoryDraft.gif)

- Create new travel memories based on existing travel plans and save as a draft.

![MemoryPost.gif](./READMEgif/MemoryPost.gif)

- Create new travel memories based on existing travel plans and post on the platform.

### Favorite Memories and Plans

![favorite.gif](./READMEgif/favoriteMP.gif)

- Check the details of favorite memories or plans that were saved earlier.

### Profile

<img src="./READMEgif/profile.png" alt="profile" width="300">

- Check all the memories and plans that have been previously published.

## License
This project is licensed under the [MIT License](LICENSE).