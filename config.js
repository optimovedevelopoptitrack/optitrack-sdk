var sdkConfig={
  "tenantToken": "undefined",
  "optitrackEndpoint": "undefined",
  "siteId": "clientSiteId",
  "enableOptitrackSupport": "undefined",
  "enableRTSupport": "undefined",
  "otEnableHeartBeatTimer": "undefined",
  "otSupportCookieMatcher": "undefined",
  "optimoveCookieMatcherId": "cookieMatcherId",
  "otsupportUserEmailStitch": "supportUserEmailStitch",
  "UserOptions": {
    "useWaterMark": "undefined",
    "backgroundMode": "undefined",
    "popupCallback": "undefined"
  },
  "events": {
    "Action": {
      "supportedOnOptitrack": "true",
      "supportedOnRealTime": "true",
      "parameters": {
        "action_name": {
          "optional": "false",
          "name": "action_name",
          "id": "1",
          "type": "String",
          "optiTrackDimensionId": "1"
        },
        "action_value": {
          "optional": "false",
          "name": "action_value",
          "id": "2",
          "type": "Number",
          "optiTrackDimensionId": "2"
        },
        "action_price": {
          "optional": "false",
          "name": "action_price",
          "id": "3",
          "type": "Number",
          "optiTrackDimensionId": "3"
        }
      }
    }
  }
}
