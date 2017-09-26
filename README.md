# On the Map

This is an app for iOS, and one of the projects composing Udacity's iOS nanodegree. It is intended to demonstrate the student's grasp of networking in iOS with Swift. The spec for the app is [here](https://docs.google.com/document/d/1tPF1tmSzVYPSbpl7_JCeMKglKMIs3dUa4OrSAKEYNAs/pub?embedded=true).

This version of the app implements the spec and adds some features:

- The user can log in to their Udacity account via Facebook.
- The UI is blurred and a spinner is shown while network operations are happening.
- When the user tries to add a pin, the app calls the Parse API to find out if a record for the logged-in user has already been added. If yes, the user is shown an alert asking if they want to overwrite the record.

Notes for review:

- The app uses [Codable](https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types), a feature of Swift 4, so it requires XCode 9 to compile.
- The app uses [CocoaPods](https://cocoapods.org/) to grab the dependencies for the Facebook Swift SDK. The user will need to install CocoaPods if they have not yet done so. After cloning this repository the user will need to run `pod install` from the directory containing the `Podfile`.
