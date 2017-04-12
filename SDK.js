
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



var OptimoveSDK = (function () {


	var clientEndPoint = 'http://146.148.68.185/';
	var clientSiteID = 1;
	var clientSupportRT = true;
	var clientSupportOT = true;
	var MinimumEmailAddressLength = 3;

	var CustomDimensionsMapping = {

		originalVisitorId: 1,
		email: 2

	};

	var SDKConfig = {
		tenantToken: undefined,
		optitrackEndpoint: clientEndPoint,
		siteID: clientSiteID,
		enableOptitrackSupport: clientSupportOT,
		enableRTSupport: clientSupportRT
	};

	var UserOptions = {
		useWaterMark: undefined,
		backgroundMode: undefined,
		publicCustomerID: undefined,
		popupCallback: undefined,

	};

	var EventContext = {
		eventType: undefined, // For Future use
		category: undefined, // Category of event
		action: undefined,// Action of event
		eventID: undefined,  // Category of event
		context: undefined
	};


	var prepareWindow = function () {

		if (window._paq == undefined) {
			window._paq = [];
		} else {
			window._paq = _paq || [];
		}
	}();


	function OptimoveSDK(sdkConfig) {

		// ------ Object Private members ------
		var _sdk_init_options = sdkConfig;
		var _sdk_init_user_options = null;
		var _userId = null;
		var _status = 1;
		var _optimove_log = false;
		var _optitrackInfraLoaded = false;


// ------------------------------ SDK public member functions ------------------------------

		// ---------------------------------------
		// Function: getSDKVersion 
		// Args: None
		// Gets the Optimove SDK Verion
		// ---------------------------------------
		this.getSDKVersion = function () {
			return "Optimove SDK V1.0";
		};		


		// ---------------------------------------
		// Function: setSDKUserOptions 
		// Args: UserOptions
		// Gets the Optimove SDK Verion
		// ---------------------------------------
		this.setSDKUserOptions = function (userOptions) {
			if (_optimove_log == true)
				console.log('OptimoveSDK: setSDKUserOptions():  Enter');

			var propNames = Object.getOwnPropertyNames(userOptions);
            var THIS = this;
			propNames.forEach(function (optionPropName) {
				handleUserOption(THIS, optionPropName, userOptions);
			});

			this.sendLoadPage();

			if (_optimove_log == true)
				console.log('OptimoveSDK: setSDKUserOptions():  Exit');
		};

		// ---------------------------------------
		// Function: sendLoadPage 
		// Args: 
		// Gets the Optimove SDK Verion
		// ---------------------------------------
		this.sendLoadPage = function () {

			if(_sdk_init_options.enableOptitrackSupport == true)
			{
				sendOptitrackLoadPage(this);
			}
			
		}

		// ---------------------------------------
		// Function: sendTrackPageView 
		// Args: 
		// Tracks a new Page View.
		// This Function should be used incase the Optitrack Infrastructure 
		// does not recognize the routing like in the case of SPA Site.		
		// ---------------------------------------
		this.sendTrackPageView = function (currentPageName) {

			if(_sdk_init_options.enableOptitrackSupport == true)
			{
				sendOptitrackTrackPageView(this, currentPageName);
			}
			
		}
		
		// ---------------------------------------
		// Function: logEvent 
		// Args: category, action, name, value
		// Log Event 
		// ---------------------------------------
		this.logEvent = function (category, action, name, value) {

			if(_sdk_init_options.enableOptitrackSupport == true)
			{
				logOptitrackEvent(this, category, action, name, value);
			}
			
			
		}

		// ---------------------------------------
		// Function: setUserId 
		// Args: currUserId
		// Log User Public Id 
		// ---------------------------------------
		this.setUserId = function (currUserId) {

			if(_sdk_init_options.enableOptitrackSupport == true)
			{
				setOptitrackUserId(this, currUserId);
			}
			
			if(_sdk_init_options.enableRTSupport == true)
			{
				
			}

		}

		// ---------------------------------------
		// Function: logUserEmail 
		// Args: email
		// Log User email 
		// ---------------------------------------
		this.logUserEmail = function (email) {

			if(_sdk_init_options.enableOptitrackSupport == true)
			{
				this.logOptitrackUserEmail(this, email)
			}
			

		}


		// --------------  Private Member Functions -------------- 

		// ---------------------------------------
		// Function: setSDKLogMode 
		// Args: None
		// Sets the Optimove SDK Logging Mode
		// ---------------------------------------
		var  setSDKLogMode = function (logMode) {
			if (logMode == 'debug') {
				if (_optimove_log == false)
					console.log('OptimoveSDK: setSDKLogMode(): Starting Log Mode');
				_optimove_log = true;

			} else {
				if (_optimove_log == true)
					console.log('OptimoveSDK: setSDKLogMode(): Stopping Log Mode');
				_optimove_log = false;
			}
		};


		// ---------------------------------------
		// Function: handleUserOption 
		// Args:optionName, options
		// Handle the User Options to update the current SDK Object.
		// ---------------------------------------
		var handleUserOption = function (THIS, optionName, options) {

			switch (optionName) {

				case 'popupCallback':
					break;
				case 'publicCustomerID':
					THIS.setUserId(options[optionName]);
					break;
				case 'backgroundMode':
					break;
				case 'useWaterMark':
					break;
			}

		};


// ------------------------------ Optitrack Private member functions ------------------------------ 


		// ---------------------------------------
		// Function: sendOptitrackLoadPage 
		// Args: None
		// Send Optitrack Infrastructure with the Loading Page Event.
		// ---------------------------------------
		var sendOptitrackLoadPage = function (THIS) {

			if (_optimove_log)
				console.log('OptimoveSDK: sendOptitrackLoadPage():  Enter');

			// tracker methods like "setCustomDimension" should be called before "trackPageView"
			window._paq.push(['trackPageView']);
			window._paq.push(['enableLinkTracking']);

			var u = _sdk_init_options.optitrackEndpoint;
			(function () {
				window._paq.push(['setTrackerUrl', u + 'piwik.php']);
				_paq.push(['setSiteId', '1']);
				if (_optitrackInfraLoaded == false) {
					var d = document, g = d.createElement('script'), s = d.getElementsByTagName('script')[0];
					g.type = 'text/javascript'; g.async = true; g.defer = true; g.src = u + 'piwik.js'; s.parentNode.insertBefore(g, s);
					_optitrackInfraLoaded = true;
				}

			})();
			if (_optimove_log)
				console.log('OptimoveSDK: sendOptitrackLoadPage():  Exit');
		};


		// ---------------------------------------
		// Function: sendOptitrackTrackPageView 
		// Args: currentPageName
		// Send Optitrack Infrastructure with the New Page View.
		// This Function is used by SPA Sites, which routing is not effecting
		//  the Optitrack. 
		// ---------------------------------------
		var sendOptitrackTrackPageView = function (THIS, currentPageName) {

			if (_optimove_log)
				console.log('OptimoveSDK: sendOptitrackTrackPageView():  Enter, currentPageName = ' + currentPageName);

			// tracker methods like "setCustomDimension" should be called before "trackPageView"
			window._paq.push(['trackPageView', currentPageName]);
		
			if (_optimove_log)
				console.log('OptimoveSDK: sendOptitrackTrackPageView():  Exit');
		};

		// ---------------------------------------
		// Function: logOptitrackEvent 
		// Args: category, action, name, value
		// Sets the Event in Optitrack Infrastructure
		// ---------------------------------------
		var  logOptitrackEvent = function (THIS, category, action, name, value) {
			if (_optimove_log)
				console.log('OptimoveSDK: logOptitrackEvent():  Enter');

			if (window._paq == undefined) {
				if (_optimove_log)
					console.log('OptimoveSDK: logOptitrackEvent() Exiting window._paq == undefined');
				return;
			}
			if (category != undefined && action != undefined && name == undefined)
				window._paq.push(['trackEvent', category, action]);

			if (category != undefined && action != undefined && name != undefined)
				window._paq.push(['trackEvent', category, action, name]);

			if (category != undefined && action != undefined && name != undefined && value != undefined)
				window._paq.push(['trackEvent', category, action, name, value]);

			if (_optimove_log)
				console.log('OptimoveSDK: logOptitrackEvent():  Exit');
		};

		// ---------------------------------------
		// Function: logOptitrackGoal 
		// Args: GoalId, CustomRevenue
		// Sets the GoalId in Optitrack Infrastructure
		// ---------------------------------------
		var  logOptitrackGoal = function (THIS, GoalId, CustomRevenue) {
			if (_optimove_log)
				console.log('OptimoveSDK: logOptitrackGoal():  Enter');


			if (_optimove_log)
				console.log('OptimoveSDK: logOptitrackGoal():  Exit');
		};

		// ---------------------------------------
		// Function: logOptitrackUserEmail 
		// Args: email - the User email
		// Sets the email in Optitrack Infrastructure
		// ---------------------------------------
		var logOptitrackUserEmail = function (THIS, email) {
			// We might have not Load the Piwik Yet
			if (_optimove_log)
				console.log('OptimoveSDK: logOptitrackUserEmail():  Enter Email=' + email);

			if (typeof email == 'undefined' || typeof email != 'string' || email.length > MinimumEmailAddressLength) {
				if (_optimove_log)
					console.log('OptimoveSDK: logOptitrackUserEmail():  Email is not valid Exiting ');

				return;
			}

			try {

				window._paq.push(['setCustomDimension', CustomDimensionsMapping.email, email]);

			} catch (err) {
				if (_optimove_log)
					console.error('OptimoveSDK: logOptitrackUserEmail():  Failed' + err);
			}


			if (_optimove_log)
				console.log('OptimoveSDK: logOptitrackUserEmail():  Exit');
		};

		// ---------------------------------------
		// Function: setOptitrackUserId 
		// Args: currUserId - the public User Id
		// Sets the in Optitrack Infrastructure User ID
		// ---------------------------------------
		var setOptitrackUserId = function (THIS, currUserId) {
			if (_optimove_log)
				console.log('OptimoveSDK: setOptitrackUserId():  Enter currUserId=' + currUserId);

			if (typeof currUserId == 'undefined' || typeof currUserId != 'string' || currUserId == undefined || currUserId == '' || currUserId == 'null' || currUserId == 'null' || currUserId == 'undefined') {
				if (_optimove_log)
					console.log('OptimoveSDK: setOptitrackUserId():  Exiting userID is not legit currUserId=' + currUserId);
				return;
			}

			if (_userId != null) {
				if (_optimove_log)
					console.log('OptimoveSDK: setOptitrackUserId():  Exiting userID is already set currUserId=' + this.userId);
				return;
			}

			try {
				if (_userId == null) {

					// We might have not Load the Piwik Yet
					if (typeof Piwik != 'undefined') {
						var tracker = window.Piwik.getAsyncTracker();
						var origVisitorId = tracker.getVisitorId();
						window._paq.push(['setCustomDimension', CustomDimensionsMapping.originalVisitorId, origVisitorId]);
					}

					_paq.push(['setUserId', currUserId]);
					window._paq.push(['trackEvent', 'LogIn', 'SignIn']);
					_userId = currUserId;
				}


			} catch (err) {
				if (_optimove_log)
					console.error('OptimoveSDK: setOptitrackUserId():  failed ');
			}

			if (_optimove_log)
				console.log('OptimoveSDK: setOptitrackUserId():  Exit');
		};

		// ---------------------------------------
		// Function: getOptitrackVisitorInfo 
		// Args: None
		// Sets the Optimove SDK Logging Mode
		// ---------------------------------------
		var getOptitrackVisitorInfo = function (THIS) {
			if (_optimove_log == true)
				console.log('OptimoveSDK: getOptitrackVisitorInfo(): Enter');

			var visitorInfo = [];
			try {
				if (typeof Piwik != 'undefined') {
					var tracker = window.Piwik.getAsyncTracker();
					visitorInfo = tracker.getVisitorInfo();
				}

			} catch (err) {
				if (_optimove_log)
					console.error('OptimoveSDK: getOptitrackVisitorInfo():  failed ');
			}

			if (_optimove_log == true)
				console.log('OptimoveSDK: getOptitrackVisitorInfo(): Exit');

			return visitorInfo;
		};

// ------------------------------ Real-Time Private member functions ------------------------------


		return this;

	};

	// Inserting the Optimove SDK object into the window context.
	window.OptimoveSDKObj = new OptimoveSDK(SDKConfig);
	

	return {
		OptimoveSDKConfig: SDKConfig,				
		OptimoveCreateSDK: OptimoveSDK,
		OptimoveSDKUserOptions: UserOptions,
		OptimoveEventContext: EventContext,
		OptimoveSDKObj: window.OptimoveSDKObj
		
	}

})();

