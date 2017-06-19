
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


	var clientEndPoint = 'http://35.184.87.239/';
	var clientSiteID = 801;
	var clientSupportRT = true;
	var clientSupportOT = true;
	var MinimumEmailAddressLength = 3;
	var heartBeatTimer = 0;
	var CustomDimensionsMapping = {

		originalVisitorId: 1,
		email: 2

	};

	var SDKConfig = {
		tenantToken: undefined,
		optitrackEndpoint: clientEndPoint,
		siteID: clientSiteID,
		enableOptitrackSupport: clientSupportOT,
		enableRTSupport: clientSupportRT,
		otEnableHeartBeatTimer: heartBeatTimer 
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


	function OptimoveSDK(sdkConfig) {

		// ------ Object Private members ------
		var _sdk_init_options = sdkConfig;
		var _sdk_init_user_options = null;
		var _userId = null;
		var _status = 1;
		var _optimove_log = false;
		var _optitrackInfraLoaded = false;
		var _ot_endpoint = null;
		var ot_tenantId = null;
		var _piwikURL = null;
		var _tracker = null;
		var _sdkConfig = null;
// ------------------------------ SDK public member functions ------------------------------

		// ---------------------------------------
		// Function: initialize 	
		// Args: logger - log object.
		// SDKConfig - config object.
		// callback_ready - callback when initialization finished successfuly 
		// Gets the Optimove SDK Verion
		// ---------------------------------------
		this.initialize = function (logger, SDKConfig, callback_ready) {
			_sdkConfig = SDKConfig;
			_ot_endpoint = getOptiTrackEndpointFromConfig(SDKConfig)
			_ot_tenantId = getOptiTrackTenantIdFromConfig(SDKConfig);
			_piwikURL = buildPiwikResourceURL();
			var tracker  = loadJSResource(this, _piwikURL, callback_ready);
			
		};		


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
			
			var propNames = Object.getOwnPropertyNames(userOptions);
            var THIS = this;
			propNames.forEach(function (optionPropName) {
				handleUserOption(THIS, optionPropName, userOptions);
			});

		};

		

		// ---------------------------------------
		// Function: setUserId 
		// Args: updatedUserId
		// Log User Public Id 
		// ---------------------------------------
		this.setUserId = function (updatedUserId) {

			setOptitrackUserId(this, updatedUserId);

		}

		// ---------------------------------------
		// Function: logPageVisitEvent 
		// Args: 
		// Gets the Optimove SDK Verion
		// ---------------------------------------
		this.logPageVisitEvent = function (customURL, pageTitle) {

			logOptitrackLoadPage(this, customURL, pageTitle);
			
		}


		// ---------------------------------------
		// Function: logUserEmail 
		// Args: email
		// Log User email 
		// ---------------------------------------
		this.logUserEmail = function (email) {

			this.logOptitrackUserEmail(this, email);

		}

	
		
		// ---------------------------------------
		// Function: logEvent 
		// Args: category, action, name, value
		// Log Event 
		// ---------------------------------------
		this.logEvent = function (eventId, eventParameters) {

			logOptitrackEvent(this,eventId, eventParameters);
			
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



		
// ------------------------------ Optitrack Private member functions ------------------------------ 


	

		// ---------------------------------------
		// Function: logOptitrackEvent 
		// Args: category, action, name, value
		// Sets the Event in Optitrack Infrastructure
		// ---------------------------------------
		var  logOptitrackEvent = function (THIS, eventId, event_parameters) {
			
	
		};

		

		// ---------------------------------------
		// Function: logOptitrackLoadPage 
		// Args: customURL, pageTitle
		// Send Optitrack Infrastructure with the Loading Page Event.
		// ---------------------------------------
		var logOptitrackLoadPage = function (THIS, customURL, pageTitle) {

			try{
					
				let isValidURL = validatePageURL(customURL);
				if(isValidURL == false)
				{
					throw 'customURL-' + customURL  + 'is not a valid URL';
				}
				_tracker.enableLinkTracking(true);

				if(_sdkConfig.otEnableHeartBeatTimer > 0)
				{
					_tracker.enableHeartBeatTimer(_sdkConfig.otEnableHeartBeatTimer);
				}
				
				_tracker.setCustomUrl(customURL);
				_tracker.trackPageView(pageTitle);

			}catch(error){


			}
		
		};



		// ---------------------------------------
		// Function: logOptitrackUserEmail 
		// Args: email - the User email
		// Sets the email in Optitrack Infrastructure
		// ---------------------------------------
		var logOptitrackUserEmail = function (THIS, email) {
			// We might have not Load the Piwik Yet
			
			try {
				let isValidEmail = validateEmail(email);
				if (isValidEmail == false) {
					
					throw 'email ' + email + ' is not valid';
				}
				_tracker.setCustomDimension(CustomDimensionsMapping.email, email);
				_tracker.trackEvent('Event', 'Email')

			} catch (err) {
				
			}

		};

		

		// ---------------------------------------
		// Function: setOptitrackUserId 
		// Args: currUserId - the public User Id
		// Sets the in Optitrack Infrastructure User ID
		// ---------------------------------------
		var setOptitrackUserId = function (THIS, updatedUserId) {
			
			var isValid = validateUserId(updatedUserId);

			try {
				if (isValid == true && _userId == null) {

					// We might have not Load the Piwik Yet
					if (typeof _tracker != 'undefined') {
						var existUserId = _tracker.getUserId();
						if(existUserId != updatedUserId)
						{
							var origVisitorId = _tracker.getVisitorId();
							_tracker.setCustomDimension(CustomDimensionsMapping.originalVisitorId, origVisitorId);
							_tracker.setUserId(updatedUserId);
							_userId = updatedUserId;
							updateCookieMatcher(THIS, updatedUserId);
						}
						
					}

				}

			} catch (err) {
				
			}

		};

		updateCookieMatcher = function (THIS, updatedUserId)
		{


		}

		// ---------------------------------------
		// Function: getOptitrackVisitorInfo 
		// Args: None
		// Sets the Optimove SDK Logging Mode
		// ---------------------------------------
		var getOptitrackVisitorInfo = function (THIS) {
			
			var visitorInfo = [];
			try {

				if (typeof _tracker != 'undefined') {
					visitorInfo = _tracker.getVisitorInfo();
				}else{
					throw  'tracker is not defined';
				}
			}catch (err) {
				
			}

			return visitorInfo;
		};

		// ------------------------------ Optitrack Private Utility member functions ------------------------------ 


		// ---------------------------------------
		// Function: getOptitrackVisitorInfo 
		// Args: updatedUserId
		// Sets the Optimove SDK Logging Mode
		// We ill allow to set null as userId,
		// inorder to enable reset of the curren userId when logged out
		// ---------------------------------------
		var validateUserId = function(updatedUserId){
			
			if (typeof updatedUserId == 'undefined' || typeof updatedUserId != 'string' || updatedUserId == undefined || updatedUserId == '' || updatedUserId == 'null' ||  updatedUserId == 'undefined') {
			 return false;
			}
			else{
				return true;
			} 

		};

		// ---------------------------------------
		// Function: validatePageURL 
		// Args: email
		// validats  the email with regexpress
		// taken from https://mathiasbynens.be/demo/url-regex
		// the selectd version of: @stephenhay
		// ---------------------------------------
		var  validatePageURL = function (customURL) {
			
    		var re = /(https?|http?|ftp):\/\/[^\s\/$.?#].[^\s]*$/;
    		return re.test(customURL);
		};


		// ---------------------------------------
		// Function: validateEmail 
		// Args: email
		// validats  the email with regexpress
		// ---------------------------------------
		var  validateEmail = function (email) {
    		var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    		return re.test(email);
		};


		// ---------------------------------------
		// Function: loadJSResource 
		// Args:url, callback
		// Handle the User Options to update the current SDK Object.
		// ---------------------------------------
		var loadJSResource = function (THIS, resourceURL, callback) {

			if(resourceURL != null)
			{
					var d = document;
					var g = d.createElement('script');
					var s = d.getElementsByTagName('script')[0];
					g.type = 'text/javascript';
					g.async = true; 
					g.defer = true;
					g.src = resourceURL;
					g.onload= function(){ handleTrackerLoadedCB(callback) } ;
					s.parentNode.insertBefore(g, s);
			}

		
		};

		// ---------------------------------------
		// Function: handleTrackerLoadedCB 
		// Args: callback
		// Load the Tracker JS resource, and then call the callback
		// ---------------------------------------
		var handleTrackerLoadedCB = function (callback){
			_tracker = createOptitrackTracker();
			handleInitializationFinished(_tracker, callback);
		};

		// ---------------------------------------
		// Function: handleInitializationFinished 
		// Args: tracker, callback
		// Update client with initialization finshed status
		// ---------------------------------------
		var handleInitializationFinished = function (tracker, callback){
			if(tracker == null)
			callback(false);
			else
			callback(true);
		};

		// ---------------------------------------
		// Function: createOptitrackTracker 
		// Args: SDKConfig
		// create the tracker object
		// ---------------------------------------
		var createOptitrackTracker = function (SDKConfig){

			if (typeof self.Piwik != 'undefined') {
				var tracker = self.Piwik.getAsyncTracker( _ot_endpoint+ 'piwik.php', _ot_tenantId );
				return tracker;
			}else {
				return undefined;
			}
			
		};

		// ---------------------------------------
		// Function: getOptiTrackEndpointFromConfig 
		// Args: SDKConfig
		// Get the Tracker Endpoint from the Config
		// ---------------------------------------
		var getOptiTrackEndpointFromConfig = function (SDKConfig){

			return  SDKConfig.optitrackEndpoint;
		};

		// ---------------------------------------
		// Function: getOptiTrackTenantIdFromConfig 
		// Args: SDKConfig
		// Get the siteId from the Config
		// ---------------------------------------
		var getOptiTrackTenantIdFromConfig = function (SDKConfig){

			return   SDKConfig.siteID;
		};

		// ---------------------------------------
		// Function: buildPiwikResourceURL 
		// Args: SDKConfig
		// build Tracker endpoint URL.
		// ---------------------------------------
		var buildPiwikResourceURL = function (){
			return _ot_endpoint + 'piwik.js';		
		};
	  

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
