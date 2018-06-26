
var argscheck = require ('cordova/argscheck'),
    exec = require('cordova/exec');

var amrExport = {};

/**
 * This enum represents Amr's supported ad sizes.  Use one of these
 * constants as the adSize when calling createBannerView.
 * @const
 */
amrExport.AD_SIZE = {
  BANNER: 50,
  LEADERBOARD: 90,
  MEDIUM_RECTANGLE: 250
};

amrExport.AMRSdkConfig =
	function(config, successCallback, failureCallback) {
	  if(typeof config === 'object' 
		  && typeof config.amrAppId === 'string'
	      && config.amrAppId.length > 0) {
		  cordova.exec(
			      successCallback,
			      failureCallback,
			      'Amr',
			      'AMRSdkConfig',
			      [config]
			  );
	  } else {
		  if(typeof failureCallback === 'function') {
			  failureCallback('config.amrAppId should be specified.')
		  }
	  }
	};
	
amrExport.startWithConfig =
function(config, successCallback, failureCallback) {
  cordova.exec(
      successCallback,
      failureCallback,
      'Amr',
      'startWithConfig',
      [ config ]
  );
};

amrExport.startTestSuite =
function(config, successCallback, failureCallback) {
    cordova.exec(
                 successCallback,
                 failureCallback,
                 'Amr',
                 'startTestSuite',
                 [ config ]
                 );
};

	
amrExport.loadBanner =
function(config, successCallback, failureCallback) {
  if(typeof config === 'undefined' || config == null) config = {};
  cordova.exec(
      successCallback,
      failureCallback,
      'Amr',
      'loadBanner',
      [ config ]
  );
};


amrExport.hideBanner =
function(successCallback, failureCallback) {
	cordova.exec(
		successCallback,
		failureCallback, 
		'Amr', 
		'hideBanner', 
        []
		
	);
};


amrExport.destroyBanner =
function(config, successCallback, failureCallback) {
  if(typeof config === 'undefined' || config == null) config = {};
  cordova.exec(
	      successCallback,
	      failureCallback,
	      'Amr',
	      'destroyBanner',
	      []
	  );
};


amrExport.loadInterstitial =
function(config, successCallback, failureCallback) {
	  if(typeof config === 'undefined' || config == null) config = {};
  cordova.exec(
      successCallback,
      failureCallback,
      'Amr',
      'loadInterstitial',
      [ config ]
  );
};

amrExport.showInterstitial = 
	function( show, successCallback, failureCallback) {
		if (show === undefined) {
			show = true;
		}

		cordova.exec(
			successCallback,
			failureCallback, 
			'Amr', 
			'showInterstitial', 
			[ show ]
		);
	};

amrExport.destroyInterstitial = 
	function(successCallback, failureCallback) {
		
		cordova.exec(
			successCallback,
			failureCallback, 
			'Amr', 
			'destroyInterstitial', 
			[ ]
        );
};


amrExport.loadRewardedVideo =
function(config, successCallback, failureCallback) {
	  if(typeof config === 'undefined' || config == null) config = {};
  cordova.exec(
      successCallback,
      failureCallback,
      'Amr',
      'loadRewardedVideo',
      [ config ]
  );
};

amrExport.showRewardedVideo = 
	function( show, successCallback, failureCallback) {
		if (show === undefined) {
			show = true;
		}

		cordova.exec(
			successCallback,
			failureCallback, 
			'Amr', 
			'showRewardedVideo', 
			[ show ]
		);
};	
amrExport.destroyRewardedVideo = 
	function(successCallback, failureCallback) {
		
		cordova.exec(
			successCallback,
			failureCallback, 
			'Amr', 
			'destroyRewardedVideo', 
			[  ]
		);
};	

amrExport.trackPurchaseForAndroid = 
	function( product, successCallback, failureCallback) {
    if(typeof product === 'undefined' || product == null) product = {};
		cordova.exec(
			successCallback,
			failureCallback, 
			'Amr', 
			'trackPurchaseForAndroid', 
			[ product ]
		);
	};	

amrExport.trackPurchaseForIOS = 
	function( product, successCallback, failureCallback) {
    if(typeof product === 'undefined' || product == null) product = {};
		cordova.exec(
			successCallback,
			failureCallback, 
			'Amr', 
			'trackPurchaseForIOS', 
			[ product ]
		);
	};	

amrExport.setUserId = 
	function( applicationUserId, successCallback, failureCallback) {
    if(typeof applicationUserId === 'undefined' || applicationUserId == null) applicationUserId = {};
		cordova.exec(
			successCallback,
			failureCallback, 
			'Amr', 
			'setUserId', 
			[applicationUserId ]
		);
	};	



module.exports = amrExport;


