\d .automl

// The purpose of this file is to house  utilities that are useful across more
// than one node or as part of the automl run/new/savedefault functionality and graph

// @kind function
// @category utility
// @fileoverview Extraction of an appropriately valued dictionary from a non complex flat file
// @param nameMap  {sym} Name mapping to appropriate text file
// @param filePath {str} File path relative to .automl.path
// @return {dict} Parsed from an appropriate flat file
utils.txtParse:{[nameMap;filePath]
  fileName:`$path,filePath,utils.files nameMap;
  utils.readFile each(!).("S*";"|")0:hsym fileName
  }

// @kind function
// @category utility
// @fileoverview Extraction of data from a file
// @param filePath {str} File path from which to extract the data from 
// @return {dict} parsed from file
utils.readFile:{[filePath]
  key(!).("S=;")0:filePath
  }

// @kind function
// @category utility
// Text files that can be parsed from within the models folder
utils.files:`class`reg`score!("models/modelConfig/classmodels.txt";"models/modelConfig/regmodels.txt";"scoring/scoring.txt")

// @kind function
// @category utility
//List of models to exclude
utils.excludeList:`GaussianNB`LinearRegression;

// @kind function
// @category Utility
// @fileoverview Defaulted fitting and prediction functions for automl cross-validation 
//  and grid search, both models fit on a training set and return the predicted scores based 
//  on supplied scoring function.
// @param func {<} Function taking in parameters and data as input, returns appropriate score
// @param hyperParam {dict} hyperparameters on which to complete hyperparameter search
// @data {float[]} data as a ((xtrn;ytrn);(xval;yval)), this structure is defined from the data
// @return {(bool[];float[])} Value predicted on the validation set and the true value 
utils.fitPredict:{[func;hyperParam;data]
  predicts:$[0h~type hyperParam;
    func[data;hyperParam 0;hyperParam 1];
    @[.[func[][hyperParam]`:fit;data 0]`:predict;data[1]0]`
    ];
  (predicts;data[1]1)
  }

// @kind function
// @category Utility
// @fileoverview Load function from q. If function not found, try python 
// @param funcName {sym} Name of function to retrieve
// @return {function} Loaded function
utils.qpyFuncSearch:{[funcName]
  func:@[get;funcName;()];
  $[()~func;.p.get[funcName;<];func]
  }

// @kind function
// @category Utility
// @fileoverview Load NLP library if requirements met
// @params {null}
// @return {null} Library loaded if requirements met or statement printed to terminal
utils.loadNLP:{
  $[(0~checkimport[3])&(::)~@[{system"l ",x};"nlp/nlp.q";{0b}];
    .nlp.loadfile`:init.q;
    -1"Requirements for NLP models are not satisfied. gensim must be installed. NLP module will not be available.";
    ]
  }

// @kind function
// @category Utility
// @fileoverview Used throughout the library to convert linux/mac file names to windows equivalent
// @param path {str} the linux 'like' path
// @retutn {str} path modified to be suitable for windows systems
utils.ssrWindows:{[path]
  $[.z.o like "w*";ssr[path;"/";"\\"];path]
  }

// Python plot functionality
utils.plt:.p.import`matplotlib.pyplot;

// @kind function
// @category Utility
// @fileoverview Used throughout when printing directory of saved objects.
//  this is to keep linux/windows consistent
// @param path {str} the linux 'like' path
// @retutn {str} path modified to be suitable for windows systems
utils.ssrsv:{[path]
  ssr[path;"\\";"/"]
  }

// @kind function
// @category Utility
// @fileoverview Split data into train and testing set without shuffling
// @param feat {tab}   The feature data as a table 
// @param tgt  {num[]} Numerical vector containing target data
// @param size {float} Proportion of data to be left as testing
// @retutn {dict}  Data separated into training and testing sets
utils.ttsNonShuff:{[feat;tgt;size]
  `xtrain`ytrain`xtest`ytest!raze(feat;tgt)@\:/:(0,floor n*1-size)_til n:count feat
  }

// @kind function
// @category Utility
// @fileoverview Return column value based on best model
// @param mdls      {tab} Models to be applied to feature data
// @param modelName {sym} The name of the model
// @param col       {sym} Column to search
// @return {sym} Column value
utils.bestModelDef:{[mdls;modelName;col]
  first?[mdls;enlist(=;`model;enlist modelName);();col]
  }

// @kind function
// @category Utility
// @fileoverview Dictionary with mappings for console printing to reduce clutter
utils.printDict:(!) . flip(
  (`describe  ;"The following is a breakdown of information for each of the relevant columns in the dataset");
  (`preproc   ;"Data preprocessing complete, starting feature creation");
  (`sigFeat   ;"Feature creation and significance testing complete");
  (`totalFeat ;"Total number of significant features being passed to the models = ");
  (`select    ;"Starting initial model selection - allow ample time for large datasets");
  (`scoreFunc ;"Scores for all models using ");
  (`bestModel ;"Best scoring model = ");
  (`modelFit  ;"Continuing to final model fitting on testing set");
  (`hyperParam;"Continuing to hyperparameter search and final model fitting on testing set");
  (`score     ;"Best model fitting now complete - final score on testing set = ");
  (`confMatrix;"Confusion matrix for testing set:");
  (`graph     ;"Saving down graphs to ");
  (`report    ;"Saving down procedure report to ");
  (`meta      ;"Saving down model parameters to ");
  (`model     ;"Saving down model to "))


// @kind function
// @category automl
// @fileoverview Retrieve the feature and target data from a user defined
//   json file containing data retrieval information.
// @param method {dict} A dictionary outlining the methods to be used for
//   retrieval of the command line data. i.e. `featureData`targetData!("csv";"ipc")
// @return       {dict} A dictionary containing the feature and target data
//   retrieved based on user instructions
utils.getCommandLineData:{[method]
  methodSpecification:cli.input`retrievalMethods;
  dict:key[method]!methodSpecification'[value method;key method];
  if[count idx:where `ipc=method;dict[idx]:("J";"c";"c")$/:3#'dict[idx]];
  dict:dict,'([]typ:value method);
  featureData:.ml.i.loaddset dict`featureData;
  featurePath:dict[`featureData]utils.dataType method`featureData;
  targetPath :dict[`targetData]utils.dataType method`targetData;
  targetName :`$dict[`targetData]`targetColumn;
  // If the data retrieval methods are the same for target and feature
  // only load the data once and retrieve the target from the table otherwise
  // retrieve the target data using i.loaddset
  data:$[featurePath~targetPath;
      (flip targetName _ flip featureData;featureData targetName);
      (featureData;.ml.i.loaddset[dict`targetData]$[`~targetName;::;targetName])
      ];
  `features`target!data
  }

// @kind function
// @category Utility
// @fileoverview Create the prediction function used when applying the model to new data
//   this function is used as the '`predict' value off the fit model and retrieved model
//   as a projection with feature data provided on calls to the function.
// @param config {dict} Configuration information related to a run of automl. This contains
//   information about the feature extraction procedure and the embedPy model (sklearn/keras)
//   used to make predictions
// @param feats  {tab}   Feature data based on which predictions are to be made.
// @returns      {num[]} Predictions
utils.generatePredict:{[config;feats]
  bestModel:config`bestModel;
  feats:utils.featureCreation[config;feats];
  modelLibrary:config`modelLib;
  $[`sklearn~modelLibrary;
    bestModel[`:predict;<]feats;
    modelLibrary in`keras`torch;
    [feats:enlist[`xtest]!enlist feats;
    customName:"." sv string config`modelLib`mdlFunc;
     get[".automl.models.",customName,".predict"][feats;bestModel]];
    '"NotYetImplemented"]
  }

// @kind function
// @category Utility
// @fileoverview Apply feature extraction/creation and feature selection on provided data
//   for based on a previous run
// @param config {dict} Configuration information related to a run of automl. This contains
//   information about the feature extraction procedure
// @param feats  {tab} Feature data based on which predictions are to be made.
// @returns      {tab} Table with feature extraction procedures applied to
//   retrieve appropriate features
utils.featureCreation:{[config;feats]
  sigFeats     :config`sigFeats;
  extractType  :config`featureExtractionType;
  if[`nlp  ~extractType;config[`savedWord2Vec]:1b];
  if[`fresh~extractType;
    relevantFuncs:raze`$distinct{("_" vs string x)1}each sigFeats;
    appropriateFuncs:1!select from 0!.ml.fresh.params where f in relevantFuncs;
    config[`functions]:appropriateFuncs];
  feats:dataPreprocessing.node.function[config;feats;config`symEncode];
  feats:featureCreation.node.function[config;feats]`features;
  if[not all newFeats:sigFeats in cols feats;
    newColumns:sigFeats where not newFeats;
    feats:flip flip[feats],newColumns!((count newColumns;count feats)#0f),()];
  flip value flip sigFeats#"f"$0^feats
  }

// @kind function
// @category Utility
// @fileoverview Retrieve model from disk generated previously from
// @param config {dict} Configuration information related to a run of automl. This contains
//   information about the feature extraction procedure
// @returns      {tab} Table with feature extraction procedures applied to
//   retrieve appropriate features
utils.loadModel:{[config]
  modelLibrary:config`modelLib;
  loadFunction:$[modelLibrary~`sklearn;
    .p.import[`joblib][`:load];
    modelLibrary~`keras;
    $[0~checkimport[0];.p.import[`keras.models][`:load_model];'"Keras model could not be loaded"];
    modelLibrary~`torch;
    $[0~checkimport[1];.p.import[`torch][`:load];'"Torch model could not be loaded"];
    '"Model Library must be one of 'sklearn', 'keras' or 'torch'"
   ];
  modelPath:config[`modelsSavePath],string config`modelName;
  modelFile:$[modelLibrary~`sklearn;
    modelPath;
    modelLibrary in`keras;modelPath,".h5";
    modelLibrary~`torch;modelPath,".pt";
    '"Unsupported model type provided"];
  loadFunction modelFile
  }

// @kind function
// @category Utility
// @fileoverview Generate the path to a model based on user defined dictionary input.
//   This assumes no knowledge of the configuration rather this is the gateway to
//   retrieve the configuration and models
// @param dict {dict}   Configuration detailing where to retrieve the model.
//   This must contain one of the following:
//     1. Dictionary mapping `startDate`startTime to the date and time associated with the model run
//     2. Dictionary mapping `savedModelName to a model named for a run previously executed
// @returns    {char[]} Path to the model detail information
utils.modelPath:{[dict]
  pathStem:path,"/outputs/";
  model:$[all `startDate`startTime in key dict;utils.nearestModel[dict];dict];
  keyDict:key model;
  pathStem,$[all `startDate`startTime in keyDict;
    $[all(-14h;-19h)=type each dict`startDate`startTime;
       ssr[string[model`startDate],"/run_",string[model`startTime],"/";":";"."];
      '"Types provided for date/time retrieval must be a date and time respectively"];
    `savedModelName in keyDict;
    $[10h=type model`savedModelName;
      "namedModels/",model[`savedModelName],"/";
      '"Types provided for model name based retrieval must be a string"];
    '"A user must define model start date/time or model name.";
    ]
  }

// @kind function
// @category Utility
// @fileoverview Extract model meta while checking that the directory for the specified model exists
// @param pathToMeta {hsym} Path to previous model meta data
// @returns Either returns extracted model meta data or errors out
utils.extractModelMeta:{[modelDetails;pathToMeta]
  errFunc:{[modelDetails;err]'"Model ",sv[" - ";string value modelDetails]," does not exist\n"}modelDetails;
  @[get;pathToMeta;errFunc]
  }

// @kind function
// @category Utility
// @fileoverview Dictionary outlining the keys which must be equivalent for data retrieval
//   in order for a dataset not to be loaded twice (assumes tabular return under equivalence)
utils.dataType:`ipc`binary`csv!(`port`select;`directory`fileName;`directory`fileName)

// Printing and logging functionality

// @kind function
// @category Utility
// @fileoverview Default printing and logging functionality
utils.printing:1b
utils.logging:0b

// @kind function
// @category api
// @fileoverview
// @param filename {sym} Name of the file which can be used to save a log of outputs to file
// @param val      {str} Item that is to be displayed to standard out of any type
// @param nline1   {int} Number of new line breaks before the text that are needed to 'pretty print' the display
// @param nline2   {int} Number of new line breaks after the text that are needed to 'pretty print' the display
utils.printFunction:{[filename;val;nline1;nline2]
  if[not 10h~type val;val:.Q.s[val]];
  newLine1:nline1#"\n";
  newLine2:nline2#"\n";
  printString :newLine1,val,newLine2;
  if[utils.logging;
    h:hopen hsym`$filename;
    h printString;
    hclose h;
    ];
  if[utils.printing;-1 printString];
  }

// @kind function
// @category Utility
// @fileoverview Retrieve the model which is closest in time to
//   the user specified `startDate`startTime where nearest is
//   here defined at the closest preceding model
// @param dict {dict} information about the start date and
//   start time of the model to be retrieved mapping `startDate`startTime
//   to their associated values
// @returns {dict} The model whose start date and time most closely matches
//   the input
utils.nearestModel:{[dict]
  timeMatch:sum dict`startDate`startTime;
  datedTimed :utils.getTimes[];
  namedModels:utils.parseNamedFiles[];
  allTimes:raze datedTimed,key namedModels;
  binLoc:bin[allTimes;timeMatch];
  if[-1=binLoc;binLoc:binr[allTimes;timeMatch]];
  nearestTime:allTimes binLoc;
  modelName:namedModels nearestTime;
  if[not (""~modelName)|()~modelName;
    :enlist[`savedModelName]!enlist neg[1]_2_modelName];
  `startDate`startTime!("d";"t")$\:nearestTime
  }

// @kind function
// @category Utility
// @fileoverview Retrieve the timestamp associated
//   with all dated/timed models generated historically
// @return {timestamp[]} The timestamps associated with
//   each of the previously generated non named models
utils.getTimes:{
  folders:key hsym`$path,"/outputs/";
  namedModels:folders=`namedModels;
  mappingFile:folders=`timeNameMapping.txt;
  dateTimeFiles:folders where not namedModels|mappingFile;
  if[(not any namedModels)&not count dateTimeFiles;
    '"No named or dated and timed models in outputs folder,",
     " please generate models prior to model retrieval"];
  $[count dateTimeFiles;utils.parseModelTimes each dateTimeFiles;()]
  }

// @kind function
// @category Utility
// @fileoverview Generate a timestamp for each timed file within the
//   outputs folder
// @param folder {symbol} name of a dated folder within the outputs directory
// @return {timestamp} an individual timestamp denoting the date+time of a run
utils.parseModelTimes:{[folder]
  fileNames:string key hsym`$path,"/outputs/",string folder;
  "P"$string[folder],/:"D",/:{@[;2 5;:;":"] 4_x}each fileNames,\:"000000"
  }

// @kind function
// @category Utility
// @fileoverview Retrieve the dictionary mapping timestamp of 
//   model generation to the name of the associated model
// @return {dict} A mapping between the timestamp associated with start date/time
//   and the name of the model produced
utils.parseNamedFiles:{
  (!).("P*";"|")0:hsym`$path,"/outputs/timeNameMapping.txt"
  }

// @kind function
// @category Utility
// @fileoverview delete models based on user provided information 
//   surrounding the date and time of model generation
// @param config {dict} User provided config containing, start date/time
//   information these can be date/time types in the former case or a
//   wildcarded string
// @param allFiles {symbol[]} list of all folders contained within the
//   .automl.path,"/outputs/" folder
// @param pathStem {string} the start of all paths to be constructed, this
//   is in the general case .automl.path,"/outputs/"
// @return {null} returns an error if attempting to delete folders which do
//   not have a match
utils.deleteDateTimeModel:{[config;allFiles;pathStem]
  dateInfo:config`startDate;
  timeInfo:config`startTime;
  relevantDates:utils.getRelevantDates[dateInfo;allFiles];
  relevantDates:string $[1=count relevantDates;enlist;]relevantDates;
  datePaths:(pathStem,/:relevantDates),\:"/";
  fileList:raze{x,/:string key hsym`$x}each datePaths;
  relevantFiles:utils.getRelevantFiles[timeInfo;fileList];
  {system"rm -r ",x}each relevantFiles
  }

// @kind function
// @category Utility
// @fileoverview Retrieve all files/models which meet the criteria
//   set out by the date/time information provided by the user
// @param dateInfo {date|string} user provided string (for wildcarding)
//   or individual date
// @param allFiles {symbol[]} list of all folders contained within the 
//   .automl.path,"/outputs/" folder
// @return all dates matching the user provided criteria
utils.getRelevantDates:{[dateInfo;allFiles]
  allDates:allFiles except `namedModels`timeNameMapping.txt;
  if[0=count allDates;'"No dated models available"];
  relevantDates:$[-14h=type dateInfo;
      $[(`$string dateInfo)in allDates;
        dateInfo;
        '"startDate provided was not present within the list of available dates"];
    10h=abs type dateInfo;
      $["*"~dateInfo;
        allDates;
        allDates where allDates like dateInfo
       ];
    '"startDate provided must be an individual date or regex string"
    ];
  if[0=count relevantDates;'"No dates requested matched a presently saved model folder"];
  relevantDates
  }

// @kind function
// @category Utility
// @fileoverview Retrieve all files/models which meet the criteria
//   set out by the date/time information provided by the user
// @param timeInfo {time|string} user provided string (for wildcarding)
//   or individual time
// @param fileList {string[]} list of all folders matching the requested
//   dates supplied by the user
// @return {string[]} all files meeting both the date and time criteria
//   provided by the user.
utils.getRelevantFiles:{[timeInfo;fileList]
  relevantFiles:$[-19h=type timeInfo;
     $[any timedString:fileList like ("*",ssr[string[timeInfo];":";"."]);
       fileList where timedString;
       '"startTime provided was not present within the list of available times"
       ];
    10h=abs type timeInfo;
     $["*"~timeInfo;
       fileList;
       fileList where fileList like ("*",ssr[timeInfo;":";"."])
       ];
    '"startTime provided must be an individual time or regex string"
    ];
  if[0=count relevantFiles;
    '"No files matching the user provided date and time were found for deletion"
    ];
  relevantFiles
  }

// @kind function
// @category Utility
// @fileoverview Delete models pased on named input, this may be a direct match
//   or a regex matching string
// @param config {dict} User provided config containing, a mapping from 
//   the save model name to the defined name as a string (direct match/wildcard)
// @param allFiles {symbol[]} list of all folders contained within the
//   .automl.path,"/outputs/" folder
// @param pathStem {string} the start of all paths to be constructed, this
//   is in the general case .automl.path,"/outputs/"
// @return {null} returns an error if attempting to delete folders which do
//   not have a match
utils.deleteNamedModel:{[config;allFiles;pathStem]
  nameInfo:config[`savedModelName];
  namedPathStem:pathStem,"namedModels/";
  relevantNames:utils.getRelevantNames[nameInfo;allFiles;namedPathStem];
  namedPaths:namedPathStem,/:string relevantNames;
  utils.deleteFromNameMapping[relevantNames;pathStem];
  {system "rm -r ",x}each namedPaths
  }

// @kind function
// @category Utility
// @fileoverview Retrieve all named models matching the user supplied
//   string representation of the search
// @param nameInfo {string} string used to compare all named models to
//   during a search
// @param allFiles {symbol[]} list of all folders contained within the
//   .automl.path,"/outputs/" folder
// @param namedPathStem {string} the start of all paths to be constructed,
//   in this case .automl.path,"/outputs/namedModels"
// @return {symbol[]} the names of all named models which match the user
//   provided string pattern
utils.getRelevantNames:{[nameInfo;allFiles;namedPathStem]
  allNamedModels:key hsym`$namedPathStem;
  if[0=count allNamedModels;'"No named models available"];
  relevantModels:$[10h=abs type nameInfo;
    $["*"~nameInfo;
      allNamedModels;
      allNamedModels where allNamedModels like nameInfo
     ];
    '"savedModelName must be a string"
    ];
  if[0=count relevantModels;
    '"No files matching the user provided savedModelName were found for deletion"
    ];
  relevantModels
  }

// @kind function
// @category Utility
// @fileoverview In the case that a named model is to be deleted, in order to
//   facilitate retrieval 'nearest' timed model a text file mapping timestamp
//   to model name is provided. If a model is to be deleted then this timestamp
//   also needs to be removed from the mapping. This function is used to
//   facilitate this by rewriting the timeNameMapping.txt file following
//   model deletion.
// @param relevantNames {symbol[]} the names of all named models which match the
//   user provided string pattern
// @param pathStem {string} the start of all paths to be constructed,
//   this is in the general case .automl.path,"/outputs"
// @return {null} On successful execution will return null, otherwise raises 
//   an error indicating that the timeNameMapping.txt file contains
//   no information.
utils.deleteFromNameMapping:{[relevantNames;pathStem]
  timeMapping:hsym`$pathStem,"timeNameMapping.txt";
  fileInfo:("P*";"|")0:timeMapping;
  if[all 0=count each fileInfo;
    '"timeNameMapping.txt contains no information"
    ];
  originalElements:til count first fileInfo;
  modelNames:{trim x except ("\"";"\\")}each last fileInfo;
  relevantNames:string relevantNames;
  locs:raze{where x like y}[modelNames]each relevantNames;
  relevantLocs:originalElements except locs;
  relevantData:(first fileInfo;modelNames)@\:relevantLocs;
  writeData:$[count relevantData;(!). relevantData;""];
  hdel timeMapping;
  h:hopen timeMapping;
  if[not writeData~"";{x each .Q.s[y]}[h;writeData]];
  hclose h;
  }
