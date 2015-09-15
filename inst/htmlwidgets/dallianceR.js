HTMLWidgets.widget({

  name: "dallianceR",

  type: "output",

  initialize: function (el, width, height) {},


  renderValue: function (el, x, instance) {
    // The data arrives in a weird format: an object with multiple
    // arrays, all with the same length.  We'd rather want a single
    // array containing objects with named columns.
    var data = (function () {
      var groups = {},
          data = x["data"],
          rows = data["Path"].length;

      // This function creates a single object from the given data at
      // the given index.
      var makeObject = function (data, index) {
        var obj = {};
        for(var prop in data) {
          if (data.hasOwnProperty(prop)) {
            obj[prop] = data[prop][index];
          }
        }
        return obj;
      };

      // group objects by their "group" property
      for (var i = 0; i < rows; i++) {
        var obj = makeObject(data, i);
        if (groups[obj["group"]] === undefined) {
          groups[obj["group"]] = [obj];
        } else {
          groups[obj["group"]].push(obj);
        }
      }
      return groups;
    })();

    // Create tracks from grouped data.  Each track consists of *all*
    // related data sets.  Some of the data sets are made almost
    // invisible with an insanely low "Alpha" setting.  This is
    // necessary in order to get the same scale for related tracks.
    // Dalliance.js does not permit setting the scaling factor
    // manually.
    var tracks = (function () {
      var makeOverlay = function (obj) {
        return { name: obj["Replicate"], // TODO: group name
                 bwgURI: obj["Path"],
                 noDownsample: true
               };
      };

      var makeStyle = function (obj) {
        return { type: "default",
                 method: obj["Replicate"],
                 style: {
                   glyph: "HISTOGRAM",
                   BGCOLOR: obj["Color"],
                   HEIGHT: 30, // FIXME: make configurable
                   ALPHA: obj["Alpha"]
                 }
               };
      };

      var makeTrack = function (groupName, group) {
        return { name: groupName,
                 merge: "concat",
                 overlay: group.map(makeOverlay),
                 style:   group.map(makeStyle)
               };
      };

      var tracks = [];
      for(var groupName in data) {
        if (data.hasOwnProperty(groupName)) {
          tracks.push(makeTrack(groupName, data[groupName]));
        }
      }
      return tracks;
    })();

    // The sources consist of the genome and standard annotations
    // followed by the tracks specified in the dataset.
    // FIXME: this should be configurable via R.
    var sources = [
      { name: "Genome GRCh38",
        twoBitURI: "http://www.biodalliance.org/datasets/hg38.2bit",
        tier_type: "sequence",
        provides_entrypoints: true
      },

      { name: "GENCODEv21",
        desc: "Gene structures from GENCODE 21",
        bwgURI: "http://www.biodalliance.org/datasets/GRCh38/gencode.v21.annotation.bb",
        stylesheet_uri: "http://www.biodalliance.org/stylesheets/gencode2.xml",
        collapseSuperGroups: true,
        trixURI: "http://www.biodalliance.org/datasets/GRCh38/gencode.v21.annotation.ix"
      }
    ].concat(tracks);

    // Create a genome browser with dalliance.js
    new Browser({
      // The worker (along with various CSS files) is expected to be
      // located on a host indicated by the prefix.  The same applies
      // to data files that are not hosted publicly.  We can only load
      // them into our widgets if the following conditions apply:
      //
      //   1) We use our own copy of the worker.
      //   2) The data files are served by an HTTP server
      //   3) The worker is located on the same host as the data files
      //
      // The easiest way to satisfy all these conditions is to run a
      // local HTTP server that serves both worker and data files.
      // A simple way to start a local web server is to use Python:
      //
      //    cd /path/to/your/data
      //    python3 -m http.server 8000
      //    # or: python2 -m SimpleHTTPServer
      //
      // But actually, this doesn't work.  At all.  The built-in HTTP
      // server in Python does not support Range requests, which
      // dalliance uses to load only the required chunks of bigwig
      // files.

      // FIXME: make the port configurable via R
      uiPrefix:     "http://localhost:8000/",
      chr:          "22",
      viewStart:    30000000,
      viewEnd:      30030000,
      cookieKey:    "human",
      coordSystem: { speciesName: "Human",
                     taxon: 9606,
                     auth: "GRCh",
                     version: "38"
                   },
      chains: { hg19ToHg38: new Chainset("http://www.derkholm.net:8080/das/hg19ToHg38/",
                                         "GRCh37",
                                         "GRCh38",
                                         { speciesName: "Human",
                                           taxon: 9606,
                                           auth: "GRCh",
                                           version: 37,
                                           ucscName: "hg19"
                                         })
              },
      sources: sources,
      fullScreen: true,
      noTitle: true,
      hubs: [ "http://ngs.sanger.ac.uk/production/ensembl/regulation/hub.txt",
             { url: "http://ftp.ebi.ac.uk/pub/databases/ensembl/encode/integration_data_jan2011/hub.txt",
               genome: "hg19",
               mapping: "hg19ToHg38"
             }
            ]
    });
  },

  resize: function (el, width, height, instance) {}

});
