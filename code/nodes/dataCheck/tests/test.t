\l automl.q
.automl.loadfile`:init.q

// The following utilities are used to test that a function is returning the expected
// error message or data, these functions will likely be provided in some form within
// the test.q script provided as standard for the testing of q and embedPy code

// @kind function
// @category tests
// @fileoverview Ensure that a test that is expected to fail, 
//   does so with an appropriate message
// @param function {(func;proj)} The function or projection to be tested
// @param data {any} The data to be applied to the function as an individual item for
//   unary functions or a list of variables for multivariant functions
// @param applyType {boolean} Is the function to be applied unary(1b) or multivariant(0b)
// @param expectedError {string} The expected error message on failure of the function
// @return {boolean} Function errored with appropriate message (1b), function failed
//   inappropriately or passed (0b)
failingTest:{[function;data;applyType;expectedError]
  // Is function to be applied unary or multivariant
  applyType:$[applyType;@;.];
  failureFunction:{[err;ret](`TestFailing;ret;err~ret)}[expectedError;];
  functionReturn:applyType[function;data;failureFunction];
  $[`TestFailing~first functionReturn;last functionReturn;0b]
  }

// @kind function
// @category tests
// @fileoverview Ensure that a test that is expected to pass, 
//   does so with an appropriate return
// @param function {(func;proj)} The function or projection to be tested
// @param data {any} The data to be applied to the function as an individual item for
//   unary functions or a list of variables for multivariant functions
// @param applyType {boolean} Is the function to be applied unary(1b) or multivariant(0b)
// @param expectedReturn {string} The data expected to be returned on 
//   execution of the function with the supplied data
// @return {boolean} Function returned the appropriate output (1b), function failed 
//   or executed with incorrect output (0b)
passingTest:{[function;data;applyType;expectedReturn]
  // Is function to be applied unary or multivariant
  applyType:$[applyType;@;.];
  functionReturn:applyType[function;data];
  expectedReturn~functionReturn
  }


// Suitable feature data and configuration for testing of configuration update
featData:([]100?1f;100?1f)
startDateTime:`startDate`startTime!(.z.D;.z.T)
configNLPReg     :startDateTime,`featExtractType`problemType!`nlp`reg
configNLPClass   :startDateTime,`featExtractType`problemType!`nlp`class
configFRESHReg   :startDateTime,`featExtractType`problemType!`fresh`reg
configFRESHClass :startDateTime,`featExtractType`problemType!`fresh`class
configNormalReg  :startDateTime,`featExtractType`problemType!`normal`reg
configNormalClass:startDateTime,`featExtractType`problemType!`normal`class

// Projection shortcut for generation of relevant config
configGen:.automl.dataCheck.updateConfig[featData]

-1"\nTesting all appropriate default combinations for updating configuration";

configList:(configNLPReg;configNLPClass;configFRESHReg;
            configFRESHClass;configNormalReg;configNormalClass)
all 99h=/:type each .automl.dataCheck.updateConfig[featData]each configList


-1"\nTesting inappropriate configuration updates";

// unimplemented form of feature extraction
inapprFeatType:configNormalReg,enlist[`featExtractType]!enlist `NYI
featExtractError:"Inappropriate feature extraction type"
failingTest[.automl.dataCheck.updateConfig;(featData;inapprFeatType);0b;featExtractError]

// Inappropriate input configuration for base configuration information
failingTest[.automl.dataCheck.updateConfig;(featData;enlist 1f);0b;"type"]


-1"\nTesting inappropriate function inputs to overwrite default behaviour";
configGen:.automl.dataCheck.updateConfig[featData]
normalConfig:configGen configNormalReg
freshConfig :configGen configFRESHReg
nlpConfig   :configGen configNLPReg

// Test inappropriately typed input
inapprTypeFunc:{"The function",x," not defined in your process\n"}

inapprTTS         :normalConfig,enlist[`tts]!enlist`notafunc
inapprTTSPrint    :inapprTypeFunc[" notafunc is"]
inapprFuncPrf     :normalConfig,`funcs`prf!`notafunc1`notafunc2
inapprFuncPrfPrint:inapprTypeFunc["s notafunc1, notafunc2 are"]

failingTest[.automl.dataCheck.functions;inapprTTS    ;1b;inapprTTSPrint]
failingTest[.automl.dataCheck.functions;inapprFuncPrf;1b;inapprFuncPrfPrint]


-1"\nTest appropriate function inputs to overwrite default behaviour";

apprFunc :normalConfig,enlist[`xv]!enlist (`.ml.xv.pcsplit;0.2)
apprFuncs:normalConfig,`xv`gs!((`.ml.xv.pcsplit;0.2);(`.ml.gs.mcsplit;0.2))

passingTest[.automl.dataCheck.functions;apprFunc;1b;(::)]
passingTest[.automl.dataCheck.functions;apprFuncs;1b;(::)]


-1"\nTest inappropriate schema provided for an NLP problem";

inapprTab:([]100?1f;100?1f)
schemaErr:"User wishing to apply nlp functionality must pass a table containing a character column."
failingTest[.automl.dataCheck.NLPSchema;(nlpConfig;inapprTab);0b;schemaErr]


-1"\nTest appropriate NLP schema and application in non NLP cases";

apprTab:([]100?1f;100?1f;100?("testing";"character data"))
passingTest[.automl.dataCheck.NLPSchema;(nlpConfig;apprTab)   ;0b;(::)]
passingTest[.automl.dataCheck.NLPSchema;(freshConfig;apprTab) ;0b;()]
passingTest[.automl.dataCheck.NLPSchema;(normalConfig;apprTab);0b;()]


-1"\nTest inappropriate target lengths";

// Variables required for target length testing
normNLPTab:([]100?1f;100?1f;100?1f)
freshTab:([]5000?100?0t;5000?1f;5000?1f)
// Inappropriate length target
inapprTarget:99?1f

freshError  :"Target count must equal count of unique agg values for fresh";
normNLPError:"Must have the same number of targets as values in table";
failingTest[.automl.dataCheck.length;(normNLPTab;inapprTarget;normalConfig);0b;normNLPError]
failingTest[.automl.dataCheck.length;(normNLPTab;inapprTarget;nlpConfig)   ;0b;normNLPError]

// Update FRESH config to retrieve the correct columns
updFreshConfig:freshConfig,enlist[`aggcols]!enlist `x
failingTest[.automl.dataCheck.length;(freshTab  ;inapprTarget;updFreshConfig);0b;freshError]

// Provide an inappropriately feature extraction type
updConfigType:normalConfig,enlist[`featExtractType]!enlist `NYI
nyiError:"Input for typ must be a supported type"
failingTest[.automl.dataCheck.length;(normNLPTab;inapprTarget;updConfigType);0b;nyiError]

// Provide an inappropriate type in feature extraction for config
updConfigType:normalConfig,enlist[`featExtractType]!enlist 1f
typError:"Input for typ must be a supported symbol"
failingTest[.automl.dataCheck.length;(normNLPTab;inapprTarget;updConfigType);0b;typError]


-1"\nTest appropriate target lengths";

// Appropriate target length 
apprTarget:100?1f

passingTest[.automl.dataCheck.length;(normNLPTab;apprTarget;normalConfig)  ;0b;(::)]
passingTest[.automl.dataCheck.length;(normNLPTab;apprTarget;nlpConfig)     ;0b;(::)]
passingTest[.automl.dataCheck.length;(freshTab  ;apprTarget;updFreshConfig);0b;(::)]


-1"\nTest inappropriate target distribution";

// Generate a target with one unique value and outline expected error
inapprTgt:100#0
tgtError:"Target must have more than one unique value"
failingTest[.automl.dataCheck.target;inapprTgt;1b;tgtError]


-1"\nTest appropriate target distribution";

// Generate a target appropriate for ML
apprTgt:100?1f
passingTest[.automl.dataCheck.target;apprTgt;1b;(::)]


