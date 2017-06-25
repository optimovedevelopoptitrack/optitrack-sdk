
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
	var clientSiteId = 801;
	var clientSupportRT = true;
	var clientSupportOT = true;
	var MinimumEmailAddressLength = 3;
	var heartBeatTimer = 0;
	var cookieMatcherId = 2222;
	var supportUserEmailStitch = true;
	var CustomDimensionsMapping = {

		originalVisitorId: 1,
		email: 1,		
		convertedVisitorId: 6,
		userId: 7,
		stitchPubCustomerId: 1,
		stitchVisitorId: 2,

	};

	var SDKConfig = {
		tenantToken: undefined,
		optitrackEndpoint: clientEndPoint,
		siteId: clientSiteId,
		enableOptitrackSupport: clientSupportOT,
		enableRTSupport: clientSupportRT,
		otEnableHeartBeatTimer: heartBeatTimer,
		otSupportCookieMatcher: false,
		optimoveCookieMatcherId: cookieMatcherId,
		otsupportUserEmailStitch: supportUserEmailStitch
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
		var LogEventCategory = 'LogEvent';
		var SetUserIdEvent = 'SetUserIdEvent';
		var SetEmailEvent = 'SetEmailEvent';
		var StitchUsersEvent = 'StitchUsersEvent';
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

			logOptitrackPageVisit(this, customURL, pageTitle);
			
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
		// Args: eventId, eventParameters
		// Log Custom Event 
		// ---------------------------------------
		this.logEvent = function (eventId, eventParameters) {

			logOptitrackCustomEvent(this,eventId, eventParameters);
			
		}
			
		
// ------------------------------ Optitrack Private member functions ------------------------------ 


	

		// ---------------------------------------
		// Function: logOptitrackCustomEvent 
		// Args: category, action, name, value
		// Sets the Event in Optitrack Infrastructure
		// ---------------------------------------
		var  logOptitrackCustomEvent = function (THIS, eventId, event_parameters) {
			
			try{
				if (typeof _tracker != 'undefined') {
				
					_tracker.setCustomDimension(2, "inVisit2");
					_tracker.setCustomDimension(3, "inVisit3");
					_tracker.setCustomDimension(6, "inAction1");
					_tracker.setCustomDimension(7, "inAction2");
					_tracker.setCustomDimension(8, "inAction3");
					//_tracker.setCustomDimension(25, "inAction25");
					//_tracker.setCustomDimension(26, "inAction26");
					// _tracker.setCustomDimension(6, "6");
					// _tracker.setCustomDimension(7, "7");
					// _tracker.setCustomDimension(8, "8");
					// _tracker.setCustomDimension(9, "9");

					_tracker.trackEvent(LogEventCategory, "eventX");
				}else{
					throw "_tracker is undefined !!";
				}

			}catch(error){

			}			
			
		};

		

		// ---------------------------------------
		// Function: logOptitrackPageVisit 
		// Args: pageURL, pageTitle
		// Send Optitrack Infrastructure with the Loading Page Event.
		// ---------------------------------------
		var logOptitrackPageVisit = function (THIS, pageURL, pageTitle) {

			try{
					
				let isValidURL = validatePageURL(pageURL);
				if(isValidURL == false)
				{
					throw 'customURL-' + pageURL  + 'is not a valid URL';
				}
				_tracker.enableLinkTracking(true);

				if(_sdkConfig.otEnableHeartBeatTimer > 0)
				{
					_tracker.enableHeartBeatTimer(_sdkConfig.otEnableHeartBeatTimer);
				}
				
				_tracker.setCustomUrl(pageURL);
				_tracker.trackPageView(pageTitle);

				if(_sdkConfig.otSupportCookieMatcher == true)
				{
					updateCookieMatcher(THIS, updatedUserId);
				}

				if(_sdkConfig.otsupportUserEmailStitch == true)
				{
					processEmailStitch(THIS, customURL);
				}


			}catch(error){


			}
		
		};

		

		// ---------------------------------------
		// Function: processEmailStitch 
		// Args: pageURL
		// Sets the email in Optitrack Infrastructure
		// the Stitch will try to find th estitch data in
		// both the URL supplied by the PageVisit event and the
		// URL extracted from the window.location
		// ---------------------------------------
		var processEmailStitch = function (THIS, pageURL) {
			// We might have not Load the Piwik Yet
			
			try {
				let stitchDataFound = false;
				let stitchData = {}
				let pageStitchData = getOptimoveStitchData(pageURL);
				if(pageStitchData.OptimoveStitchDataExist == false)
				{
					var browserURL = window.location.pathname;
					let browserStitchData = getOptimoveStitchData(browserURL);

					if(browserStitchData.OptimoveStitchDataExist == true)
					{
						stitchData  = browserStitchData;
						stitchDataFound = true;
					}
				}else{
					stitchData  = pageStitchData;
					stitchDataFound = true;
				}
				
				if (stitchData == true && typeof _tracker != 'undefined') 
				{
					let visitorId = _tracker.getVisitorId();
					_tracker.setCustomDimension(CustomDimensionsMapping.stitchPubCustomerId, stitchData.OptimovePublicCustomerId);
					_tracker.setCustomDimension(CustomDimensionsMapping.stitchVisitorId, visitorId);
					_tracker.trackEvent(LogEventCategory, StitchUsersEvent)
				}
				

			} catch (err) {
				
			}

		};

		// ---------------------------------------
		// Function: getOptimoveStitchData 
		// Args: URL
		// Gets the data from the URL which is used by 
		// Optimove Stitch Flow.
		// return - JSON obj containng the optimovePublicCustomerId
		//  and the status.
		// ---------------------------------------
		var  getOptimoveStitchData = function(currURL)
		{
			// We might have not Load the Piwik Yet
			var jsonData = {};
			jsonData["OptimoveStitchDataExist"] = false;
			let optimovePublicCustomerId = "OptimovePublicCustomerId";
			let optimoveStitchFlow = "OptimoveStitchFlow";
			let isStitchFlow = false;
			try {
				let parts = currURL.split('&');				
				if(parts.length > 0)
				{
					parts.forEach((item, index) => {
						
						if(item.search(optimoveStitchFlow) > -1)
						{	
							isStitchFlow = item.slice(optimoveStitchFlow.length+1) == 'true';														
						}else{
							isStitchFlow = false;
						}

						if(isStitchFlow == true && item.search(optimovePublicCustomerId)  > -1)
						{	
							publicCustomerId = item.slice(optimovePublicCustomerId.length+1)
							jsonData["OptimovePublicCustomerId"] = publicCustomerId;
							jsonData["OptimoveStitchDataExist"] = true;
						}

					})
				}
								
			} catch (err) {
				
			}
			return jsonData;

		};


		// ---------------------------------------
		// Function: logOptitrackUserEmail 
		// Args: email - the User email
		// Sets the email in Optitrack Infrastructure
		// ---------------------------------------
		var logOptitrackUserEmail = function (THIS, email) {
					
			try {
				let isValidEmail = validateEmail(email);
				if (isValidEmail == false) {
					
					throw 'email ' + email + ' is not valid';
				}
				_tracker.setCustomDimension(CustomDimensionsMapping.email, email);
				_tracker.trackEvent(LogEventCategory, SetEmailEvent);

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
							logSetUserIdEvent(THIS, origVisitorId, updatedUserId);
							_userId = updatedUserId;
							if(_sdkConfig.otSupportCookieMatcher == true)
							{
								updateCookieMatcher(THIS, updatedUserId);
							}
							
						}
						
					}

				}

			} catch (err) {
				
			}

		};

		// ---------------------------------------
		// Function: logSetUserIdEvent 
		// Args: THIS, origVisitorId, updatedUserId
		// Sets the in Optitrack Infrastructure User ID
		// ---------------------------------------
		var logSetUserIdEvent = function (THIS, origVisitorId, updatedUserId) {
			
			try {
				_tracker.setCustomDimension(CustomDimensionsMapping.convertedVisitorId, origVisitorId);
				_tracker.setCustomDimension(CustomDimensionsMapping.userId, updatedUserId);
				_tracker.trackEvent(LogEventCategory, SetUserIdEvent);
			} catch (err) {
				
			}

		};

		// ---------------------------------------
		// Function: updateCookieMatcher 
		// Args: None
		// Sets the Optimove SDK Logging Mode
		// ---------------------------------------
		var updateCookieMatcher = function (THIS, updatedUserId)
		{
			
			let cookieMatcherUserId = null;
			if(_userId != null)
			{
				cookieMatcherUserId = _userId;
			}else{
			   cookieMatcherUserId = _tracker.getVisitorId();
			}

			setOptimoveCookie(cookieMatcherUserId);

			matchCookie(_sdkConfig.siteId, _sdkConfig.optimoveCookieMatcherId);


			let setOptimoveCookie = function(cookieMatcherUserId) { 
			
				var setCookieUrl = "https://gcm.optimove.events/setCookie?optimove_id="+cookieMatcherUserId; 
				var setCookieNode = document.createElement("img"); 
				setCookieNode.style.display = "none"; 
				setCookieNode.setAttribute("src", setCookieUrl); 
				document.body.appendChild(setCookieNode); 
			};
	

			matchCookie = function(tenantId, optimoveCookieMatcherId) { 
				//var url = "https://cm.g.doubleclick.net/pixel?google_nid=OptimoveCookieMatcherID&google_cm&tenant_id=TenantID"; 
				var url = "https://cm.g.doubleclick.net/pixel?google_nid=" + optimoveCookieMatcherId + "&google_cm&tenant_id=" +tenantId; 
				var node = document.createElement("img"); 
				node.style.display = "none"; 
				node.setAttribute("src", url); 
				document.body.appendChild(node); 
			} 

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

			return   SDKConfig.siteId;
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
