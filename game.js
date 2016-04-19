
var Module;

if (typeof Module === 'undefined') Module = eval('(function() { try { return Module || {} } catch(e) { return {} } })()');

if (!Module.expectedDataFileDownloads) {
  Module.expectedDataFileDownloads = 0;
  Module.finishedDataFileDownloads = 0;
}
Module.expectedDataFileDownloads++;
(function() {
 var loadPackage = function(metadata) {

    var PACKAGE_PATH;
    if (typeof window === 'object') {
      PACKAGE_PATH = window['encodeURIComponent'](window.location.pathname.toString().substring(0, window.location.pathname.toString().lastIndexOf('/')) + '/');
    } else if (typeof location !== 'undefined') {
      // worker
      PACKAGE_PATH = encodeURIComponent(location.pathname.toString().substring(0, location.pathname.toString().lastIndexOf('/')) + '/');
    } else {
      throw 'using preloaded data can only be done on a web page or in a web worker';
    }
    var PACKAGE_NAME = 'game.data';
    var REMOTE_PACKAGE_BASE = 'game.data';
    if (typeof Module['locateFilePackage'] === 'function' && !Module['locateFile']) {
      Module['locateFile'] = Module['locateFilePackage'];
      Module.printErr('warning: you defined Module.locateFilePackage, that has been renamed to Module.locateFile (using your locateFilePackage for now)');
    }
    var REMOTE_PACKAGE_NAME = typeof Module['locateFile'] === 'function' ?
                              Module['locateFile'](REMOTE_PACKAGE_BASE) :
                              ((Module['filePackagePrefixURL'] || '') + REMOTE_PACKAGE_BASE);
  
    var REMOTE_PACKAGE_SIZE = metadata.remote_package_size;
    var PACKAGE_UUID = metadata.package_uuid;
  
    function fetchRemotePackage(packageName, packageSize, callback, errback) {
      var xhr = new XMLHttpRequest();
      xhr.open('GET', packageName, true);
      xhr.responseType = 'arraybuffer';
      xhr.onprogress = function(event) {
        var url = packageName;
        var size = packageSize;
        if (event.total) size = event.total;
        if (event.loaded) {
          if (!xhr.addedTotal) {
            xhr.addedTotal = true;
            if (!Module.dataFileDownloads) Module.dataFileDownloads = {};
            Module.dataFileDownloads[url] = {
              loaded: event.loaded,
              total: size
            };
          } else {
            Module.dataFileDownloads[url].loaded = event.loaded;
          }
          var total = 0;
          var loaded = 0;
          var num = 0;
          for (var download in Module.dataFileDownloads) {
          var data = Module.dataFileDownloads[download];
            total += data.total;
            loaded += data.loaded;
            num++;
          }
          total = Math.ceil(total * Module.expectedDataFileDownloads/num);
          if (Module['setStatus']) Module['setStatus']('Downloading data... (' + loaded + '/' + total + ')');
        } else if (!Module.dataFileDownloads) {
          if (Module['setStatus']) Module['setStatus']('Downloading data...');
        }
      };
      xhr.onload = function(event) {
        var packageData = xhr.response;
        callback(packageData);
      };
      xhr.send(null);
    };

    function handleError(error) {
      console.error('package error:', error);
    };
  
      var fetched = null, fetchedCallback = null;
      fetchRemotePackage(REMOTE_PACKAGE_NAME, REMOTE_PACKAGE_SIZE, function(data) {
        if (fetchedCallback) {
          fetchedCallback(data);
          fetchedCallback = null;
        } else {
          fetched = data;
        }
      }, handleError);
    
  function runWithFS() {

    function assert(check, msg) {
      if (!check) throw msg + new Error().stack;
    }
Module['FS_createPath']('/', 'assets', true, true);
Module['FS_createPath']('/assets', 'cars_characters', true, true);
Module['FS_createPath']('/assets', 'font', true, true);
Module['FS_createPath']('/assets', 'gearshift', true, true);
Module['FS_createPath']('/assets/gearshift', 'symbols', true, true);
Module['FS_createPath']('/assets', 'inscreen', true, true);
Module['FS_createPath']('/assets', 'menu', true, true);
Module['FS_createPath']('/assets/menu', 'buttons', true, true);
Module['FS_createPath']('/assets', 'misc', true, true);
Module['FS_createPath']('/assets', 'sounds', true, true);
Module['FS_createPath']('/', 'lib', true, true);
Module['FS_createPath']('/', 'states', true, true);
Module['FS_createPath']('/states', 'gui', true, true);

    function DataRequest(start, end, crunched, audio) {
      this.start = start;
      this.end = end;
      this.crunched = crunched;
      this.audio = audio;
    }
    DataRequest.prototype = {
      requests: {},
      open: function(mode, name) {
        this.name = name;
        this.requests[name] = this;
        Module['addRunDependency']('fp ' + this.name);
      },
      send: function() {},
      onload: function() {
        var byteArray = this.byteArray.subarray(this.start, this.end);

          this.finish(byteArray);

      },
      finish: function(byteArray) {
        var that = this;

        Module['FS_createDataFile'](this.name, null, byteArray, true, true, true); // canOwn this data in the filesystem, it is a slide into the heap that will never change
        Module['removeRunDependency']('fp ' + that.name);

        this.requests[this.name] = null;
      },
    };

        var files = metadata.files;
        for (i = 0; i < files.length; ++i) {
          new DataRequest(files[i].start, files[i].end, files[i].crunched, files[i].audio).open('GET', files[i].filename);
        }

  
    function processPackageData(arrayBuffer) {
      Module.finishedDataFileDownloads++;
      assert(arrayBuffer, 'Loading data file failed.');
      assert(arrayBuffer instanceof ArrayBuffer, 'bad input to processPackageData');
      var byteArray = new Uint8Array(arrayBuffer);
      var curr;
      
        // copy the entire loaded file into a spot in the heap. Files will refer to slices in that. They cannot be freed though
        // (we may be allocating before malloc is ready, during startup).
        if (Module['SPLIT_MEMORY']) Module.printErr('warning: you should run the file packager with --no-heap-copy when SPLIT_MEMORY is used, otherwise copying into the heap may fail due to the splitting');
        var ptr = Module['getMemory'](byteArray.length);
        Module['HEAPU8'].set(byteArray, ptr);
        DataRequest.prototype.byteArray = Module['HEAPU8'].subarray(ptr, ptr+byteArray.length);
  
          var files = metadata.files;
          for (i = 0; i < files.length; ++i) {
            DataRequest.prototype.requests[files[i].filename].onload();
          }
              Module['removeRunDependency']('datafile_game.data');

    };
    Module['addRunDependency']('datafile_game.data');
  
    if (!Module.preloadResults) Module.preloadResults = {};
  
      Module.preloadResults[PACKAGE_NAME] = {fromCache: false};
      if (fetched) {
        processPackageData(fetched);
        fetched = null;
      } else {
        fetchedCallback = processPackageData;
      }
    
  }
  if (Module['calledRun']) {
    runWithFS();
  } else {
    if (!Module['preRun']) Module['preRun'] = [];
    Module["preRun"].push(runWithFS); // FS is not initialized yet, wait for it
  }

 }
 loadPackage({"files": [{"audio": 0, "start": 0, "crunched": 0, "end": 3838, "filename": "/conf.lua"}, {"audio": 0, "start": 3838, "crunched": 0, "end": 5071, "filename": "/loop.lua"}, {"audio": 0, "start": 5071, "crunched": 0, "end": 8311, "filename": "/main.lua"}, {"audio": 0, "start": 8311, "crunched": 0, "end": 9007, "filename": "/assets/default.png"}, {"audio": 0, "start": 9007, "crunched": 0, "end": 214367, "filename": "/assets/cars_characters/car_1_large.png"}, {"audio": 0, "start": 214367, "crunched": 0, "end": 259466, "filename": "/assets/cars_characters/car_1_small.png"}, {"audio": 0, "start": 259466, "crunched": 0, "end": 448829, "filename": "/assets/cars_characters/car_2_large.png"}, {"audio": 0, "start": 448829, "crunched": 0, "end": 493393, "filename": "/assets/cars_characters/car_2_small.png"}, {"audio": 0, "start": 493393, "crunched": 0, "end": 635793, "filename": "/assets/cars_characters/character_1.png"}, {"audio": 0, "start": 635793, "crunched": 0, "end": 767344, "filename": "/assets/cars_characters/character_2.png"}, {"audio": 0, "start": 767344, "crunched": 0, "end": 945008, "filename": "/assets/font/Raleway-Black.ttf"}, {"audio": 0, "start": 945008, "crunched": 0, "end": 1000976, "filename": "/assets/gearshift/first_gear.png"}, {"audio": 0, "start": 1000976, "crunched": 0, "end": 3375591, "filename": "/assets/gearshift/game_background.png"}, {"audio": 0, "start": 3375591, "crunched": 0, "end": 3446563, "filename": "/assets/gearshift/next_gear.png"}, {"audio": 0, "start": 3446563, "crunched": 0, "end": 3467989, "filename": "/assets/gearshift/shift_knob.png"}, {"audio": 0, "start": 3467989, "crunched": 0, "end": 3478443, "filename": "/assets/gearshift/shift_rod.png"}, {"audio": 0, "start": 3478443, "crunched": 0, "end": 3487278, "filename": "/assets/gearshift/symbols/symbol_background.png"}, {"audio": 0, "start": 3487278, "crunched": 0, "end": 3493152, "filename": "/assets/gearshift/symbols/s_001.png"}, {"audio": 0, "start": 3493152, "crunched": 0, "end": 3500370, "filename": "/assets/gearshift/symbols/s_002.png"}, {"audio": 0, "start": 3500370, "crunched": 0, "end": 3505388, "filename": "/assets/gearshift/symbols/s_003.png"}, {"audio": 0, "start": 3505388, "crunched": 0, "end": 3511055, "filename": "/assets/gearshift/symbols/s_004.png"}, {"audio": 0, "start": 3511055, "crunched": 0, "end": 3517248, "filename": "/assets/gearshift/symbols/s_005.png"}, {"audio": 0, "start": 3517248, "crunched": 0, "end": 3525368, "filename": "/assets/gearshift/symbols/s_006.png"}, {"audio": 0, "start": 3525368, "crunched": 0, "end": 3531361, "filename": "/assets/gearshift/symbols/s_007.png"}, {"audio": 0, "start": 3531361, "crunched": 0, "end": 3536802, "filename": "/assets/gearshift/symbols/s_008.png"}, {"audio": 0, "start": 3536802, "crunched": 0, "end": 3544264, "filename": "/assets/gearshift/symbols/s_009.png"}, {"audio": 0, "start": 3544264, "crunched": 0, "end": 3550938, "filename": "/assets/gearshift/symbols/s_010.png"}, {"audio": 0, "start": 3550938, "crunched": 0, "end": 3556188, "filename": "/assets/gearshift/symbols/s_011.png"}, {"audio": 0, "start": 3556188, "crunched": 0, "end": 3562465, "filename": "/assets/gearshift/symbols/s_012.png"}, {"audio": 0, "start": 3562465, "crunched": 0, "end": 3570737, "filename": "/assets/inscreen/bollards_background.png"}, {"audio": 0, "start": 3570737, "crunched": 0, "end": 3576686, "filename": "/assets/inscreen/bollards_foreground.png"}, {"audio": 0, "start": 3576686, "crunched": 0, "end": 3586506, "filename": "/assets/inscreen/mountains.png"}, {"audio": 0, "start": 3586506, "crunched": 0, "end": 3587965, "filename": "/assets/inscreen/road.png"}, {"audio": 0, "start": 3587965, "crunched": 0, "end": 5808354, "filename": "/assets/menu/background_menu.png"}, {"audio": 0, "start": 5808354, "crunched": 0, "end": 5814615, "filename": "/assets/menu/credits.png"}, {"audio": 0, "start": 5814615, "crunched": 0, "end": 5863066, "filename": "/assets/menu/game_title.png"}, {"audio": 0, "start": 5863066, "crunched": 0, "end": 5946745, "filename": "/assets/menu/howtoplay_text.png"}, {"audio": 0, "start": 5946745, "crunched": 0, "end": 5989688, "filename": "/assets/menu/howtoplay_title.png"}, {"audio": 0, "start": 5989688, "crunched": 0, "end": 6036375, "filename": "/assets/menu/race_lost.png"}, {"audio": 0, "start": 6036375, "crunched": 0, "end": 6040525, "filename": "/assets/menu/race_lost_grannyshifter.png"}, {"audio": 0, "start": 6040525, "crunched": 0, "end": 6046832, "filename": "/assets/menu/race_lost_wrecked_clutch.png"}, {"audio": 0, "start": 6046832, "crunched": 0, "end": 6048244, "filename": "/assets/menu/volume_bubble.png"}, {"audio": 0, "start": 6048244, "crunched": 0, "end": 6051325, "filename": "/assets/menu/volume_slider.png"}, {"audio": 0, "start": 6051325, "crunched": 0, "end": 6054821, "filename": "/assets/menu/buttons/btn_arrow_left.png"}, {"audio": 0, "start": 6054821, "crunched": 0, "end": 6055482, "filename": "/assets/menu/buttons/btn_arrow_left_mask.png"}, {"audio": 0, "start": 6055482, "crunched": 0, "end": 6059039, "filename": "/assets/menu/buttons/btn_arrow_right.png"}, {"audio": 0, "start": 6059039, "crunched": 0, "end": 6059697, "filename": "/assets/menu/buttons/btn_arrow_right_mask.png"}, {"audio": 0, "start": 6059697, "crunched": 0, "end": 6062278, "filename": "/assets/menu/buttons/btn_back.png"}, {"audio": 0, "start": 6062278, "crunched": 0, "end": 6067434, "filename": "/assets/menu/buttons/btn_chooseyourdriver.png"}, {"audio": 0, "start": 6067434, "crunched": 0, "end": 6085895, "filename": "/assets/menu/buttons/btn_howtoplay.png"}, {"audio": 0, "start": 6085895, "crunched": 0, "end": 6105651, "filename": "/assets/menu/buttons/btn_howtoplay_hover.png"}, {"audio": 0, "start": 6105651, "crunched": 0, "end": 6107693, "filename": "/assets/menu/buttons/btn_howtoplay_mask.png"}, {"audio": 0, "start": 6107693, "crunched": 0, "end": 6114305, "filename": "/assets/menu/buttons/btn_quit.png"}, {"audio": 0, "start": 6114305, "crunched": 0, "end": 6121560, "filename": "/assets/menu/buttons/btn_quit_hover.png"}, {"audio": 0, "start": 6121560, "crunched": 0, "end": 6122426, "filename": "/assets/menu/buttons/btn_quit_mask.png"}, {"audio": 0, "start": 6122426, "crunched": 0, "end": 6140235, "filename": "/assets/menu/buttons/btn_startgame.png"}, {"audio": 0, "start": 6140235, "crunched": 0, "end": 6158232, "filename": "/assets/menu/buttons/btn_startgame_hover.png"}, {"audio": 0, "start": 6158232, "crunched": 0, "end": 6160094, "filename": "/assets/menu/buttons/btn_startgame_mask.png"}, {"audio": 0, "start": 6160094, "crunched": 0, "end": 6218683, "filename": "/assets/misc/fuzzy_dice_updated_update_very_transparent.png"}, {"audio": 1, "start": 6218683, "crunched": 0, "end": 6229233, "filename": "/assets/sounds/button_mouseover.wav"}, {"audio": 1, "start": 6229233, "crunched": 0, "end": 6239783, "filename": "/assets/sounds/button_pressed.wav"}, {"audio": 1, "start": 6239783, "crunched": 0, "end": 6269374, "filename": "/assets/sounds/engine_1.ogg"}, {"audio": 1, "start": 6269374, "crunched": 0, "end": 6298567, "filename": "/assets/sounds/engine_2.ogg"}, {"audio": 1, "start": 6298567, "crunched": 0, "end": 6310947, "filename": "/assets/sounds/gear.wav"}, {"audio": 1, "start": 6310947, "crunched": 0, "end": 6410055, "filename": "/assets/sounds/shift_failed.wav"}, {"audio": 1, "start": 6410055, "crunched": 0, "end": 6420725, "filename": "/assets/sounds/shift_succeded.wav"}, {"audio": 1, "start": 6420725, "crunched": 0, "end": 6430913, "filename": "/assets/sounds/symbol_presented.wav"}, {"audio": 0, "start": 6430913, "crunched": 0, "end": 6435190, "filename": "/lib/color.lua"}, {"audio": 0, "start": 6435190, "crunched": 0, "end": 6437140, "filename": "/lib/gearbox.lua"}, {"audio": 0, "start": 6437140, "crunched": 0, "end": 6441239, "filename": "/lib/images.lua"}, {"audio": 0, "start": 6441239, "crunched": 0, "end": 6443576, "filename": "/lib/sounds.lua"}, {"audio": 0, "start": 6443576, "crunched": 0, "end": 6444380, "filename": "/lib/stringfunctions.lua"}, {"audio": 0, "start": 6444380, "crunched": 0, "end": 6456959, "filename": "/lib/tween.lua"}, {"audio": 0, "start": 6456959, "crunched": 0, "end": 6462077, "filename": "/states/carselect.lua"}, {"audio": 0, "start": 6462077, "crunched": 0, "end": 6464722, "filename": "/states/fader.lua"}, {"audio": 0, "start": 6464722, "crunched": 0, "end": 6472408, "filename": "/states/game.lua"}, {"audio": 0, "start": 6472408, "crunched": 0, "end": 6473655, "filename": "/states/howtoplay.lua"}, {"audio": 0, "start": 6473655, "crunched": 0, "end": 6476712, "filename": "/states/menu.lua"}, {"audio": 0, "start": 6476712, "crunched": 0, "end": 6478191, "filename": "/states/racelost.lua"}, {"audio": 0, "start": 6478191, "crunched": 0, "end": 6481489, "filename": "/states/gui/button.lua"}, {"audio": 0, "start": 6481489, "crunched": 0, "end": 6485882, "filename": "/states/gui/racepanel.lua"}, {"audio": 0, "start": 6485882, "crunched": 0, "end": 6494275, "filename": "/states/gui/shifter.lua"}], "remote_package_size": 6494275, "package_uuid": "8de10e0f-1832-425f-815f-0b9dda5426d1"});

})();
