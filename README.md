# Athlima
Greek for "Sport", Athlima is an IOS application created using SwiftUI, Google FireBase and Apple MapKit that connects people with a shared passion for sports through creating and joining personalized events.

# Project Screenshots

<table>
  <tr>
    <td>Current Activities Page</td>
    <td>Create Activity Page</td>
    <td>Events Attending Page</td>
  </tr>
  <tr>
    <td><img src="https://user-images.githubusercontent.com/64728439/200912126-fb3fcf01-6be1-45f5-abe6-a5cf3e165fb2.png"></td>
    <td><img src="https://user-images.githubusercontent.com/64728439/200912338-d147001c-c147-48b4-8323-820549228412.png"></td>
    <td><img src="https://user-images.githubusercontent.com/64728439/200912413-d2777570-3917-4576-9ad2-733bd9961648.png"></td>
  </tr>
  <tr>
    <td>Users Created Events Page</td>
    <td>Profile Page</td>
  </tr>
  <tr>
    <td><img src="https://user-images.githubusercontent.com/64728439/200912477-1b3db57a-29ca-4f48-b527-25ea886e1f28.png"></td>
    <td><img src="https://user-images.githubusercontent.com/64728439/200912537-18d8368c-86be-4a25-874b-2a4a22201cee.png"></td>
  </tr>
 </table>
 
 # Installation and Setup Instructions
 Download the project and open using Xcode. 
 You will need to set up your own FireBase project to host the apps configurations and data since the app won't compile without the GoogleService-Info.plist file that should be in the Resources folder.
 I am not pushing my GoogleService-Info.plist file as it will allow you to write data which I dont want. 
 Once you create your firebase project and have your GoogleService-Info.plist file add it into the resources folder as seen below:
 
 <img width="221" alt="image" src="https://user-images.githubusercontent.com/64728439/200913827-9084df8b-0191-4fd7-acfa-d8794e3f9892.png">
 
 And then you'll be able to compile and run the app and read and write data (events, etc.) 
 
# Reflection
This is a project I started working on over the summer of 2022 and I'm planning on updating in the near future, adding more features. The app, which was inspired by seeing my younger
brother not being able to book a soccer pitch because of a few friends cancelling, allows users to create and join sports events for a variety of 
sports ranging from soccer to surfing to martial arts. Each event a user creates is highly personalized to their needs with information including the location of the event,
age required, experience level, number of players needed and more. Although as of now these specifications don't stop other users that dont meet them from 
joining the event, I plan on using this data to filter out events and make the list of active events more tailored towards the current user. So only showing 
events around them, where their age meets the specification, etc. This is all to come in future updates. 

My end goal for Athlima is to connect people with similar passions together and create new friendships and memories along the way. 

The app is designed using Swift and following the MVVM (Model, View, View-Model) design pattern which allowed me to structure my code into specific parts all of which interacted together to perform complex tasks from writing and fetching
data from FireBase to setting up maps showing where each event is taking place. Having users creating and joining events and interacting with each 
other gave rise to special privacy related considerations and design choices I had to make to ensure that the app complied with Apple's privacy 
guidelines. I see great potential for the idea which is why I'm still currently working on it and planning to launch some updates in the near future. 
Updates that allow users to create private friend groups, send message invitations to others as well as involve personal trainers and a verification + point system, improving trust between users and opening the door for potential monetization.









