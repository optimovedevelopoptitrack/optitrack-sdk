 -------------- SDK -------------
 Objectives:
 1. Unify the Optimove SDK to a single SDK in the Client side.
 2. Agility - fast and easy modifications and support.
 3. Easy maintanance.
 4. 
  
  GTM :
  In GTM after Options Json should be updated on each page (Page Load Trigger).
  - after update call the initSDK.

  Client Side :
  - in Client Side (no GTM) Options Json is updated on each page.
  - The call to InitSDK in done over the start of Body tag.


// This is the Optimove Real-Time and Analytics SDK.
// Usage: 
// 1. Load the Optimove SDK to the Page Context : <script type="text/javascript" defer="true" async  src="http://OptimoveSDK.net/optimoveSDK.js" onload="OptimoveSDKHandler()"></script>.
// 2. Register function to the Optimove SDK load resource -add to the script tag the following:  onload="OptimoveSDKHandler()".
// 3. In the Function: 
	// a. Create the instance of OptimoveSDKUserOptions.
	// b. Update the Configuration values.
	// c. if user public ID is known update the publicCustomerID.
	// d. Call the SDK setSDKUserOptions(userOptions);

	// function OptimoveSDKHandler(){

	//         if (typeof window.OptimoveSDKObj != "undefined") {
	//             var userOptions = Object.create(window.OptimoveSDK.OptimoveSDKUserOptions);
	//             userOptions.publicCustomerID = "yossi";

	//             window.OptimoveSDK.OptimoveSDKObj.setSDKUserOptions(userOptions);

	//             console.log('------------------ exists ------------------ ');

	//         } else {
	//             console.log('------------------ not exists ------------------ ');
	//         }

	//     }




// ------------------------------ SDK public member functions ------------------------------

		// ---------------------------------------
		// Function: getSDKVersion 
		// Args: None
		// Gets the Optimove SDK Verion
		// ---------------------------------------
		getSDKVersion();

		// ---------------------------------------
		// Function: setSDKUserOptions 
		// Args: UserOptions
		// Gets the Optimove SDK Verion
		// ---------------------------------------
		setSDKUserOptions(userOptions);

		// ---------------------------------------
		// Function: sendLoadPage 
		// Args: 
		// Gets the Optimove SDK Verion
		// ---------------------------------------
		sendLoadPage();

		// ---------------------------------------
		// Function: logEvent 
		// Args: category, action, name, value
		// Log Event 
		// ---------------------------------------
		logEvent (category, action, name, value);

		// ---------------------------------------
		// Function: setUserId 
		// Args: currUserId
		// Log User Public Id 
		// ---------------------------------------
		setUserId (currUserId);

		// ---------------------------------------
		// Function: logUserEmail 
		// Args: email
		// Log User email 
		// ---------------------------------------
		logUserEmail(email);

		// ---------------------------------------
		// Function: sendTrackPageView 
		// Args: 
		// Tracks a new Page View.
		// This Function should be used incase the Optitrack Infrastructure 
		// does not recognize the routing like in the case of SPA Site.		
		// ---------------------------------------
		sendTrackPageView(currentPageName);