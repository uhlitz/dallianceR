HTMLWidgets.widget({

  name: 'dalliancer',

  type: 'output',

  initialize: function(el, width, height) {

    return {  }

  },

  renderValue: function(el, x, instance) {

    new Browser({
      chr:          '22',
      viewStart:    30000000,
      viewEnd:      30030000,
      cookieKey:    'human',
      coordSystem: {
        speciesName: 'Human',
        taxon: 9606,
        auth: 'GRCh',
        version: '38'
      },
      chains: {
        hg19ToHg38: new Chainset('http://www.derkholm.net:8080/das/hg19ToHg38/', 'GRCh37', 'GRCh38',
                                 {
                                    speciesName: 'Human',
                                    taxon: 9606,
                                    auth: 'GRCh',
                                    version: 37,
                                    ucscName: 'hg19'
                                 })
      },
      sources:     [{name:                 'Genome GRCh38',
                     twoBitURI:            'http://www.biodalliance.org/datasets/hg38.2bit',
                     tier_type:            'sequence',
                     provides_entrypoints: true}

                    ,{name: 'GENCODEv21',
                         desc: 'Gene structures from GENCODE 21',
                         bwgURI: 'http://www.biodalliance.org/datasets/GRCh38/gencode.v21.annotation.bb',
                         stylesheet_uri: 'http://www.biodalliance.org/stylesheets/gencode2.xml',
                         collapseSuperGroups: true,
                         trixURI: 'http://www.biodalliance.org/datasets/GRCh38/gencode.v21.annotation.ix'}

                      ,{name: "My track",
                          bwgURI: "bigwig/ML_CS_001_X_TS.fastq_GRCh38.77_STAR_Signal.Unique.str1.out.sorted.bw",
                          style: [{type: 'bigwig', style: {glyph: 'HISTOGRAM', BGCOLOR: 'rgb(166,71,71)', HEIGHT: 30, id: 'style1'}}]}
                  ],
                          fullScreen: true,
                          noTitle: true,
                          hubs: ['http://ngs.sanger.ac.uk/production/ensembl/regulation/hub.txt', {url: 'http://ftp.ebi.ac.uk/pub/databases/ensembl/encode/integration_data_jan2011/hub.txt', genome: 'hg19', mapping: 'hg19ToHg38'}]});


  },

  resize: function(el, width, height, instance) {

  }

});
