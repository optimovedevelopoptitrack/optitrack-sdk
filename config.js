var clientEndPoint = 'http://35.184.87.239/';
var clientSiteId = 801;
var clientSupportRT = true;
var clientSupportOT = true;
var MinimumEmailAddressLength = 3;
var heartBeatTimer = 0;
var cookieMatcherId = null;
var supportUserEmailStitch = true;
	
var sdkConfig={
  "tenantToken": "undefined",
  "optitrackEndpoint": clientEndPoint,
  "siteId": clientSiteId,
  "enableOptitrackSupport": true,
  "enableRTSupport": true,
  "otEnableHeartBeatTimer": (heartBeatTimer > 0),
  "otSupportCookieMatcher": (cookieMatcherId != null),
  "optimoveCookieMatcherId": cookieMatcherId,
  "otsupportUserEmailStitch": supportUserEmailStitch,
  "UserOptions": {
    "useWaterMark": "undefined",
    "backgroundMode": "undefined",
    "popupCallback": "undefined"
  },
  "events": {
    "Event-1": {
      "supportedOnOptitrack": "true",
      "supportedOnRealTime": "true",
      "parameters": {
        "action_name": {
          "optional": "false",
          "name": "action_name",
          "id": "1",
          "type": "String",
          "optiTrackDimensionId": "6"
        },
        "action_value": {
          "optional": "false",
          "name": "action_value",
          "id": "2",
          "type": "int",
          "optiTrackDimensionId": "7"
        },
        "action_price": {
          "optional": "false",
          "name": "action_price",
          "id": "3",
          "type": "int",
          "optiTrackDimensionId": "8"
        }
      }
    },

    "Event-2": {
      "supportedOnOptitrack": "true",
      "supportedOnRealTime": "true",
      "parameters": {
        "action_name": {
          "optional": "false",
          "name": "action_name",
          "id": "1",
          "type": "String",
          "optiTrackDimensionId": "6"
        },
        "action_value": {
          "optional": "false",
          "name": "action_value",
          "id": "2",
          "type": "int",
          "optiTrackDimensionId": "7"
        },
        "action_price": {
          "optional": "false",
          "name": "action_price",
          "id": "3",
          "type": "int",
          "optiTrackDimensionId": "8"
        }
      }
    },

    "Event-3": {
      "supportedOnOptitrack": "true",
      "supportedOnRealTime": "true",
      "parameters": {
        "action_name": {
          "optional": "false",
          "name": "action_name",
          "id": "1",
          "type": "String",
          "optiTrackDimensionId": "6"
        },
        "action_value": {
          "optional": "false",
          "name": "action_value",
          "id": "2",
          "type": "int",
          "optiTrackDimensionId": "7"
        },
        "action_price": {
          "optional": "false",
          "name": "action_price",
          "id": "3",
          "type": "int",
          "optiTrackDimensionId": "8"
        }
      }
    },
    "Event-4": {
      "supportedOnOptitrack": "true",
      "supportedOnRealTime": "true",
      "parameters": {
        "action_name": {
          "optional": "false",
          "name": "action_name",
          "id": "1",
          "type": "String",
          "optiTrackDimensionId": "6"
        },
        "action_value": {
          "optional": "false",
          "name": "action_value",
          "id": "2",
          "type": "int",
          "optiTrackDimensionId": "7"
        },
        "action_price": {
          "optional": "false",
          "name": "action_price",
          "id": "3",
          "type": "int",
          "optiTrackDimensionId": "8"
        }
      }
    },
	
	"stitchEvent": {
      "supportedOnOptitrack": "true",
      "supportedOnRealTime": "true",
      "parameters": {
        "sourcePublicCustomerId": {
          "optional": "true",
          "name": "sourcePublicCustomerId",
          "id": "1",
          "type": "String",
          "optiTrackDimensionId": "6"
        },
        "sourceVisitorId": {
          "optional": "true",
          "name": "sourceVisitorId",
          "id": "2",
          "type": "String",
          "optiTrackDimensionId": "7"
        },
        "targetVsitorId": {
          "optional": "false",
          "name": "targetVsitorId",
          "id": "3",
          "type": "String",
          "optiTrackDimensionId": "8"
        }
      }
    }
  }
}
