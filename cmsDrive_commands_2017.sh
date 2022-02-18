#!/bin/bash
export X509_USER_PROXY=$(pwd)/x509up_user.pem
export HOME=/afs/cern.ch/user/s/spmondal
source /cvmfs/cms.cern.ch/cmsset_default.sh

#------------------------------ step LHE,GEN
export SCRAM_ARCH=slc7_amd64_gcc700
scram p CMSSW CMSSW_10_6_28
cd CMSSW_10_6_28/src
eval `scram runtime -sh`
cp -r /afs/cern.ch/work/s/spmondal/private/gcHc/gen/211216/privateprod/Configuration .
scram b
cd ../..
cmsDriver.py Configuration/GenProduction/python/$2 --python_filename makeLHE.py --eventcontent RAWSIM,LHE --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN,LHE --fileout file:LHE.root --conditions 106X_mc2017_realistic_v6 --beamspot Realistic25ns13TeVEarly2017Collision --step LHE,GEN --geometry DB:Extended --era Run2_2017 --no_exec --mc -n $1 --customise_commands "from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper;randSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService);randSvc.populate()"
cmsRun makeLHE.py

#------------------------------ step SIM + step DIGI,DATAMIX,L1,DIGI2RAW
export SCRAM_ARCH=slc7_amd64_gcc700
scram p CMSSW CMSSW_10_6_17_patch1
cd CMSSW_10_6_17_patch1/src
eval `scram runtime -sh`
scram b
cd ../..
cmsDriver.py  --python_filename makeSIM.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:SIM.root --conditions 106X_mc2017_realistic_v6 --beamspot Realistic25ns13TeVEarly2017Collision --step SIM --geometry DB:Extended --filein file:LHE.root --era Run2_2017 --runUnscheduled --no_exec --mc -n $1
cmsRun makeSIM.py

cmsDriver.py  --python_filename makeFEVT.py --eventcontent PREMIXRAW --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-DIGI --fileout file:FEVT.root --pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer20ULPrePremix-UL17_106X_mc2017_realistic_v6-v3/PREMIX" --conditions 106X_mc2017_realistic_v6 --step DIGI,DATAMIX,L1,DIGI2RAW --procModifiers premix_stage2 --geometry DB:Extended --filein file:SIM.root --datamix PreMix --era Run2_2017 --runUnscheduled --no_exec --mc -n $1
cmsRun makeFEVT.py


#------------------------------ step HLT
export SCRAM_ARCH=slc7_amd64_gcc630
scram p CMSSW CMSSW_9_4_14_UL_patch1
cd CMSSW_9_4_14_UL_patch1/src
eval `scram runtime -sh`
scram b
cd ../..
cmsDriver.py  --python_filename makeHLT.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --fileout file:HLT.root --conditions 94X_mc2017_realistic_v15 --customise_commands 'process.source.bypassVersionCheck = cms.untracked.bool(True)' --step HLT:2e34v40 --geometry DB:Extended --filein file:FEVT.root --era Run2_2017 --no_exec --mc -n $1
cmsRun makeHLT.py


#------------------------------ step RAW2DIGI,L1Reco,RECO,RECOSIM
export SCRAM_ARCH=slc7_amd64_gcc700
cd CMSSW_10_6_17_patch1/src
eval `scram runtime -sh`
scram b
cd ../..
cmsDriver.py  --python_filename makeAOD.py --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:AOD.root --conditions 106X_mc2017_realistic_v6 --step RAW2DIGI,L1Reco,RECO,RECOSIM --geometry DB:Extended --filein file:HLT.root --era Run2_2017 --runUnscheduled --no_exec --mc -n $1
cmsRun makeAOD.py

#------------------------------ step PAT
export SCRAM_ARCH=slc7_amd64_gcc700
scram p CMSSW CMSSW_10_6_20
cd CMSSW_10_6_20/src
eval `scram runtime -sh`
scram b
cd ../..
cmsDriver.py  --python_filename makeMini.py --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:Mini.root --conditions 106X_mc2017_realistic_v9 --step PAT --procModifiers run2_miniAOD_UL --geometry DB:Extended --filein file:AOD.root --era Run2_2017 --runUnscheduled --no_exec --mc -n $1
cmsRun makeMini.py

#------------------------------ step Nano
export SCRAM_ARCH=slc7_amd64_gcc700
scram p CMSSW CMSSW_10_6_26
cd CMSSW_10_6_26/src
eval `scram runtime -sh`
cp -r /afs/cern.ch/work/s/spmondal/private/gcHc/gen/211216/privateprod/PhysicsTools .
scram b
cd ../..
cmsDriver.py  --python_filename makeNano.py --eventcontent NANOAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier NANOAODSIM --fileout file:Nano.root --conditions 106X_mc2017_realistic_v9 --step NANO --filein file:Mini.root --era Run2_2017,run2_nanoAOD_106Xv2 --no_exec --mc -n $1
cmsRun makeNano.py

mkdir -p /eos/user/s/spmondal/gcHc/NanoAOD/$3/
cp Nano.root /eos/user/s/spmondal/gcHc/NanoAOD/$3/$3_$4_$5.root