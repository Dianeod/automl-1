// Collect all the parameters relevant for the generation of reports/graphs etc in the prediction step
// such they can be consolidated into a single node later in the workflow
\d .automl

predictParams.node.inputs  :`bestModel`testScore`predictions`modelMetaData!"<fF!"
predictParams.node.outputs :"!"
predictParams.node.function:{[bmdl;tscore;preds;metaData]
  `bestModel`testScore`predictions!(bmdl;tscore;preds)
  }
