# PassiveElasticSwimmers
Optimizer for SE(2) swimmers  in a perfect inertial fluid with passive-elastic shape modes 

# Quick Start

## Make sure MatLab knows where everything is

Write initializeWorkspace.m and add to core repository so that the code knows where you have sysplotter installed

This should look like 

```
path(pathdef);
addpath('DataFiles');
addpath('FigureGenerators');
addpath([pathToSysplotter,'\ProgramFiles']);
```
## Run one of the optimization files

'optimizeFishTailConstants.m' will optimize a fish-tail swimmer as modeled in my intertial swimming paper for both the input gait and the passive parameters
