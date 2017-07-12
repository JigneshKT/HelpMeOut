# HelpMeOut
Help Me Out is project for helping patient by their caregivers.

Platform: iOS
Code: Objective C
Supported devices: iPhone 5/6/7/S/Plus 

Why single application for patient and caregiver?

1. As notification is required to be sent between patient and caregiver, we need to have single and unique bundle identifier for sending messages.
2. Easy to maintain
3. App store will have only 1 application for HelpMeOut and users will not get confused.
4. Depending upon the sign up / login, application will show the relevant content to patient and caregiver.

Installation procedure:

1. Download the source code from GIT repository
2. Open terminal -> cd /to/path/source code
3. Pod install. If cocoapods is not installed, please see https://guides.cocoapods.org/using/getting-started.html for
4.  It should show following installation:
	Using AFNetworking (3.1.0)
	Using Firebase (3.17.0)
	Using FirebaseAnalytics (3.9.0)
	Using FirebaseAuth (3.1.1)
	Using FirebaseCore (3.6.0)
	Using FirebaseDatabase (3.1.2)
	Using FirebaseInstanceID (1.0.10)
	Using FirebaseMessaging (1.2.3)
	Using GTMSessionFetcher (1.1.9)
	Using GoogleToolboxForMac (2.1.1)
	Using MBProgressHUD (1.0.0)
	Using Protobuf (3.3.0)

5. Now it should also give below complete message:
	Pod installation complete! There are 6 dependencies from the Podfile and 12 total pods installed.
6. Now open app and change the bundle identifier. This is required as I have already used this appID in my account so you need to change it and create unique appID and corresponding APN certificate in your account.



Configuring application for firebase usage:

1. Create your firebase account at firebase.google.com
2. Create application and add iOS app with your XXX.XXX.XXXX bundle identifier.
3. Download GoogleService-Info.plist. First remove existing GoogleService-Info.plist in the project and than add the downloaded GoogleService-Info.plist.
4. In console of firebase account, click Authentication and enable Email authentication. This is to identify the user. WITHOUT THIS SETTING, APPLICATION WILL NOT WORK PROPERLY.
5. In console of firebase account, click settings button (in overview section) —> Project settings. Now click CLOUD MESSAGING and add the development / product certificates which has APN enabled.
6. As we are sending the notification between device, without server, it is required to add the server key details in code. In Global.m file —> sendpushNotiViaFireBase_PushTitle method, please change the server key at
[manager.requestSerializer setValue:@"key=XXXXXXXXXXXXXXXXXXXXX-JFWBMfDztM6GDfiRkHbreSb9TCSjXrlCI_XXXXXXXXXXXnlZCr1GIN7W7eeXF3SJHWYkrRmA54v_" forHTTPHeaderField:@"Authorization"];


Problems encountered:

1. Core part of this project is to connect Patient and caregiver. This should be simple at the same time working. Adding notification for message and change of database was main problem.


Main features implemented:

1. Whenever user open app, it will ask to register as patient or caregiver
2. User will enter the name, if that name already exists in database, it will consider as login or else as new registration
3. Whenever patient add any caregiver, if caregiver app is open, it will directly detect the change in database for his/her ID. App will add the patient’s request  with Accept and reject button. This will be useful for instant connect of patient with caregiver
4. Patient can add multiple caregiver
5. Caregiver will see the added patient or request to accept or reject the patient’s request
6. Patient can notify the caregiver for help only if that caregiver has accepted the request
7. Application will send notification for:
 —> when patient sends request to caregiver
 —> when caregiver accepts / reject the request
 —> when patient need help from caregiver



Further developments:

1. Notification through server and not between device to device. This is required for security and logical purpose
2. Validating patient / caregiver from their mobile and/or email
3. Better UI with flashy images
4. Proper guidance to app user through walk through pages
5. Video calling facility to talk
6. Patient caregiver message chat
7. Patient should be able to upload their medical reports to be viewed by caregiver
5. Testing



