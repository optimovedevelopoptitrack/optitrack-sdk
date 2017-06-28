
// This is the Optimove Real-Time and Analytics SDK.
// Usage: 
// 



var OptimoveSDK = (function () {

	
	function OptimoveSDK() {

		
// ------ Object Private members ------				
		var _userId 		= null;				
		var _ot_endpoint 	= null;
		var _ot_tenantId 	= null;
		var _piwikURL 		= null;
		var _configURL  	= null;
		var _tracker 		= null;
		var _sdkConfig 		= null;

// ------------------------------ Event Const Values ------------------------------

		var LogEventCategory_name = 'LogEvent';
		var SetUserIdEvent_name = 'set_user_id_event';
		var SetEmailEvent_name = 'Set_email_event';
		var StitchUsersEvent_name = 'stitch_event';
		var email_param_name = "email";
		var originalVisitorId_param_name = "originalVisitorId";
		var userId_param_name = "userId";
		var updatedVisitorId_param_name = "updatedVisitorId"
// ------------------------------ SDK public member functions ------------------------------

		// ---------------------------------------
		// Function: initialize 	
		// Args: logger - log object.
		// callback_ready - callback when initialization finished successfuly 
		// Gets the Optimove SDK Verion
		// ---------------------------------------
		this.initialize = function (logger, callback_ready) {
		var THIS = this;
		let configReady = function(b){
			var currSDK= self.sdkConfig;
			THIS.initializeOptiTrack(logger,currSDK, callback_ready);
		};
		_configURL = "https://optimovesdk.firebaseapp.com/config.js";
		
		var tracker  = loadJSResource(this, _configURL, configReady);
			
		};		

		// ---------------------------------------
		// Function: initialize 	
		// Args: logger - log object.
		// SDKConfig - config object.
		// callback_ready - callback when initialization finished successfuly 
		// Gets the Optimove SDK Verion
		// ---------------------------------------
		this.initializeOptiTrack = function (logger, SDKConfig, callback_ready) {
			_sdkConfig = SDKConfig;
			_ot_endpoint = getOptiTrackEndpointFromConfig(SDKConfig)
			_ot_tenantId = getOptiTrackTenantIdFromConfig(SDKConfig);
			_piwikURL = buildPiwikResourceURL(SDKConfig);
			let tracker  = loadOptiTrackJSResource(this, _piwikURL, callback_ready);
			
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
		// Flow: Go through the event configuration definition.
		// Per each parameter we chech whether it exist and if so.
		// What is the optiTrackDimensionId we should use for it in the custom Dimension.
		// if the optiTrackDimensionId = -1 we define the parameter not to be delivered to the Optitrack.
		// ---------------------------------------
		var  logOptitrackCustomEvent = function (THIS, eventId, event_parameters) {
			
			try{

				if(event_parameters == undefined)
				{
					return false;
				}
				let numOfAddedParams = 0;
				let currEventConfig = _sdkConfig.events[eventId];
				let parameterConfigsNames = Object.getOwnPropertyNames(currEventConfig.parameters);
				parameterConfigsNames.forEach(function (paramName) {
							
					let currParamConfig = currEventConfig.parameters[paramName];
					// Check if the parameter is given in the Event Argumen
					if(event_parameters[paramName] != undefined && currParamConfig.optiTrackDimensionId > 0  )
					{
						let paramValue = event_parameters[paramName];
						if( paramValue != undefined)
						{
							numOfAddedParams++;
							_tracker.setCustomDimension(currParamConfig.optiTrackDimensionId, paramValue);
						}
					}
					
				});

				if(numOfAddedParams > 0 && typeof _tracker != 'undefined')		
				{
					_tracker.trackEvent(LogEventCategory_name, eventId);
					return true;
				}else{
					throw "_tracker is undefined !!";
				}
													
			}catch(error){
				throw "logOptitrackCustomEvent Failed!!";
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
				let stitchEvent = "stitchEvent"
				let sourcePublicCustomerId = "sourcePublicCustomerId";
				let sourceVisitorId = "sourceVisitorId";
				let targetVsitorId = "targetVsitorId";

				let stitchData = {}

				let eventConfig = getCustomEventConfigById(StitchUsersEvent_name);
				let sourcePCIDParamConfig = null;
				let sourceVisitorIdParamConfig = null;
				let targetVsitorIdIdParamConfig = null;
				if(eventConfig != null)
				{	
					sourcePCIDParamConfig = getCustomEventParamFromConfig(eventConfig, sourcePublicCustomerId);
					sourceVisitorIdParamConfig = getCustomEventParamFromConfig(eventConfig, sourceVisitorId);
					targetVsitorIdIdParamConfig = getCustomEventParamFromConfig(eventConfig, targetVsitorId);
				}

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
					let numOfParams = 0;
					let targetVisitorId = _tracker.getVisitorId();
					if(stitchData.OptimovePublicCustomerId != null)
					{
						
						if(sourcePCIDParamConfig.optiTrackDimensionId > 0){
							numOfParams++;
							_tracker.setCustomDimension(sourcePCIDParamConfig.optiTrackDimensionId, stitchData.OptimovePublicCustomerId);
						}						
						
					}else{

						if(sourceVisitorIdParamConfig.optiTrackDimensionId > 0){
							numOfParams++;
							_tracker.setCustomDimension(sourceVisitorIdParamConfig.optiTrackDimensionId, stitchData.OptimovePublicCustomerId);
						}
						
					}
					if(targetVsitorIdIdParamConfig.optiTrackDimensionId > 0){
						numOfParams++;
						_tracker.setCustomDimension(targetVsitorIdIdParamConfig.optiTrackDimensionId, stitchData.OptimovePublicCustomerId);
					}
				
					_tracker.trackEvent(LogEventCategory_name, StitchUsersEvent_name)
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
			let jsonData = {};
			jsonData["OptimoveStitchDataExist"] = false;
			let optimovePublicCustomerId 	= "OptimovePublicCustomerId";
			let optimoveVisitorId 			= "optimoveVisitorId";
			let optimoveStitchFlow 			= "OptimoveStitchFlow";
			let optimoveStitchDataExist 	= "OptimoveStitchDataExist";
			let isStitchFlow 				= false;

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

						if(isStitchFlow == true)
						{	
							if(item.search(optimovePublicCustomerId)  > -1)
							{
								let publicCustomerId = item.slice(optimovePublicCustomerId.length+1)
								jsonData[optimovePublicCustomerId] = publicCustomerId;
							}
							if(item.search(optimoveVisitorId)  > -1)
							{
								let vistorId = item.slice(optimoveVisitorId.length+1)
								jsonData[optimoveVisitorId] = vistorId;
							}
							
							jsonData[optimoveStitchDataExist] = true;
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
		var logOptitrackUserEmail = function (THIS, emailValue) {
					
			try {
				let isValidEmail = validateEmail(email);
				if (isValidEmail == false) {
					
					throw 'email ' + email + ' is not valid';
				}
				let eventConfig = getCustomEventConfigById(SetEmailEvent_name);
				if(eventConfig != null)
				{	
					let emailConfig = getCustomEventParamFromConfig(eventConfig, email_param_name);
					_tracker.setCustomDimension(emailConfig.optiTrackDimensionId, emailValue);
					_tracker.trackEvent(LogEventCategory_name, SetEmailEvent_name);
				}

			} catch (err) {
				
			}

		};

		

		// ---------------------------------------
		// Function: setOptitrackUserId 
		// Args: currUserId - the public User Id
		// Sets the in Optitrack Infrastructure User ID
		// ---------------------------------------
		var setOptitrackUserId = function (THIS, updatedUserId) {
			
			let isValid = validateUserId(updatedUserId);

			try {
				if (isValid == true && _userId == null) {

					// We might have not Load the Piwik Yet
					if (typeof _tracker != 'undefined') {
						var existUserId = _tracker.getUserId();
						if(existUserId != updatedUserId)
						{
							let origVisitorId = _tracker.getVisitorId();							
							_tracker.setUserId(updatedUserId);
							_userId = updatedUserId;
							let updatedVisitorId = _tracker.getVisitorId();
							logSetUserIdEvent(THIS, origVisitorId, updatedUserId, updatedVisitorId);
							
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
		var logSetUserIdEvent = function (THIS, origVisitorIdValue, updatedUserIdValue, updatedVisitorIdValue) {
			
			try {
				let eventConfig = getCustomEventConfigById(SetUserIdEvent_name);
				if(eventConfig != null)
				{
					
					let originalVisitorIdConfig = getCustomEventParamFromConfig(eventConfig, originalVisitorId_param_name);
					let updatedVisitorIdConfig = getCustomEventParamFromConfig(eventConfig, updatedVisitorId_param_name);
					let userIdParamConfig = getCustomEventParamFromConfig(eventConfig, userId_param_name);

					if(userIdParamConfig != undefined)
					{
						_tracker.setCustomDimension(userIdParamConfig.optiTrackDimensionId, updatedUserIdValue);
					}
					if(originalVisitorIdConfig != undefined)
					{
						_tracker.setCustomDimension(originalVisitorIdConfig.optiTrackDimensionId, origVisitorIdValue);
					}
					if(updatedVisitorIdConfig != undefined)
					{
						_tracker.setCustomDimension(updatedVisitorIdConfig.optiTrackDimensionId, updatedVisitorIdValue);
					}
					
					
					_tracker.trackEvent(LogEventCategory_name, SetUserIdEvent_name);
				}
				
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
			
				let setCookieUrl = "https://gcm.optimove.events/setCookie?optimove_id="+cookieMatcherUserId; 
				let setCookieNode = document.createElement("img"); 
				setCookieNode.style.display = "none"; 
				setCookieNode.setAttribute("src", setCookieUrl); 
				document.body.appendChild(setCookieNode); 
			};
	

			matchCookie = function(tenantId, optimoveCookieMatcherId) { 
				//var url = "https://cm.g.doubleclick.net/pixel?google_nid=OptimoveCookieMatcherID&google_cm&tenant_id=TenantID"; 
				let url = "https://cm.g.doubleclick.net/pixel?google_nid=" + optimoveCookieMatcherId + "&google_cm&tenant_id=" +tenantId; 
				let node = document.createElement("img"); 
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
			
			let visitorInfo = [];
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
		// Function: getCustomEventConfigById 
		// Args: eventId
		// returns the event Configuration.		
		// ---------------------------------------
		var getCustomEventConfigById = function(eventId){
			let currEvent = _sdkConfig.events[eventId];
			if(currEvent == undefined)
			{
				return null;
			}
			return currEvent;
		};

		// ---------------------------------------
		// Function: getCustomEventParamFromConfig 
		// Args: eventConfig, paramName
		// returns the event Configuration.
		// ---------------------------------------
		var getCustomEventParamFromConfig = function(eventConfig, paramName){			
			let currParam = eventConfig.parameters[paramName];
			if(currParam == undefined)
			{
				return null;
			}
			return currParam;
		};


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
			
    		let regexp = /(https?|http?|ftp):\/\/[^\s\/$.?#].[^\s]*$/;
    		return regexp.test(customURL);
		};


		// ---------------------------------------
		// Function: validateEmail 
		// Args: email
		// validats  the email with regexpress
		// ---------------------------------------
		var  validateEmail = function (email) {
    		let regexp = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    		return regexp.test(email);
		};


		// ---------------------------------------
		// Function: loadJSResource 
		// Args:url, callback
		// Handle the User Options to update the current SDK Object.
		// ---------------------------------------
		var loadJSResource = function (THIS, resourceURL, callback) {

			if(resourceURL != null)
			{
					let d = document;
					let g = d.createElement('script');
					let s = d.getElementsByTagName('script')[0];
					g.type = 'text/javascript';
					g.async = true; 
					g.defer = true;
					g.src = resourceURL;
					g.onload= callback ;
					s.parentNode.insertBefore(g, s);
			}

		
		};


		// ---------------------------------------
		// Function: loadOptiTrackJSResource 
		// Args:url, callback
		// Handle the User Options to update the current SDK Object.
		// ---------------------------------------
		var loadOptiTrackJSResource = function (THIS, resourceURL, callback) {

			if(resourceURL != null)
			{
					let d = document;
					let g = d.createElement('script');
					let s = d.getElementsByTagName('script')[0];
					g.type = 'text/javascript';
					g.async = true; 
					g.defer = true;
					g.src = resourceURL;
					g.onload= function(){ handleTrackerLoadedCB(THIS,callback) } ;
					s.parentNode.insertBefore(g, s);
			}

		
		};

		// ---------------------------------------
		// Function: handleTrackerLoadedCB 
		// Args: callback
		// Load the Tracker JS resource, and then call the callback
		// ---------------------------------------
		var handleTrackerLoadedCB = function (THIS, callback){
			_tracker = createOptitrackTracker();
			handleInitializationFinished(THIS,_tracker, callback);
		};

		// ---------------------------------------
		// Function: handleInitializationFinished 
		// Args: tracker, callback
		// Update client with initialization finshed status
		// ---------------------------------------
		var handleInitializationFinished = function (THIS, tracker, callback){
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
		var createOptitrackTracker = function (){

			if (typeof self.Piwik != 'undefined') {
				let tracker = self.Piwik.getAsyncTracker( _ot_endpoint+ 'piwik.php', _ot_tenantId );
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
		var buildPiwikResourceURL = function (SDKConfig){
			return SDKConfig.optitrackEndpoint + 'piwik.js';		
		};
	  

		return this;

	};

	// Inserting the Optimove SDK object into the window context.
	window.OptimoveSDKObj = new OptimoveSDK();
	

	return {
	
		OptimoveSDKObj: window.OptimoveSDKObj
		
	}

})();
