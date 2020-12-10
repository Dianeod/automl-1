\d .automl

// Definitions of the main callable functions used in the application of .automl.selectModels

// @kind function
// @category selectModels
// @fileoverview Remove keras models if criteria met
// @param mdls {tab} Models which are to be applied to the dataset
// @param tts  {dict} Feature and target data split into train and testing sets
// @param tgt  {(num[];sym[])} numerical or symbol vector containing the target dataset
// @param cfg  {dict} Configuration information assigned by the user and related to the current run
// @return {tab} Keras model removed if needed and removal highlighted
selectModels.targetKeras:{[mdls;tts;tgt;cfg]
  if[not check.keras[];
    :?[mdls;enlist(<>;`lib;enlist `keras);0b;()]
    ];
  multiCheck:`multi in mdls`typ;
  tgtCount:min count@'distinct each tts`ytrain`ytest;
  tgtCheck:count[distinct tgt]>tgtCount;
  if[multiCheck&tgtCheck;
    cfg[`logFunc] utils.printDict`kerasClass;
    :delete from mdls where lib=`keras,typ=`multi
    ];
  mdls
  }

// @kind function
// @category selectModels
// @fileoverview Remove theano models if these are unavailable
// @param mdls {tab} Models which are to be applied to the dataset
// @param cfg  {dict} Configuration information assigned by the user and related to the current run
// @return {tab} Keras model removed if needed and removal highlighted
selectModels.theanoModels:{[mdls;cfg]
  if[0<>checkimport[5];
    cfg[`logFunc] utils.printDict`theanoModels;
    :?[mdls;enlist(<>;`lib;enlist `theano);0b;()]
    ];
  mdls
  }

// @kind function
// @category selectModels
// @fileoverview Update models available for use based on the number of rows in the target set
// @param mdls {tab} Models which are to be applied to the dataset
// @param tgt  {(num[];sym[])} Numerical or symbol vector containing the target dataset
// @param cfg  {dict} Configuration information assigned by the user and related to the current run
// @return {tab} Appropriate models removed if needed and model removal highlighted
selectModels.targetLimit:{[mdls;tgt;cfg]
 if[cfg[`targetLimit]<count tgt;
    if[utils.ignoreWarnings=2;
      cfg[`logFunc](utils.printWarnings[`neuralNetWarning]0),string cfg[`targetLimit];
      :select from mdls where lib<>`keras,not fnc in`neural_network`svm
     ];
    if[utils.ignoreWarnings=1;
      cfg[`logFunc](utils.printWarnings[`neuralNetWarning]1),string cfg[`targetLimit]]];
   mdls
  }
