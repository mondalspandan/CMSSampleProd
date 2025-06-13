#!/bin/bash
# 1: cluster 2: process 3: H Mass 4: nEvents 5: Had Flav
set -e
source /cvmfs/cms.cern.ch/cmsset_default.sh
export maindir=/isilon/data/users/smondal5/VHcc_gen/CMSSampleProd
export workdir=$maindir/condor/workdir_$1_$2_$5
export x509_cert_dir=$maindir/certificates
export X509_USER_PROXY=$maindir/x509up_user.pem
export NCPU=$(nproc)

export CMSSW_13_0_14_PATH=/isilon/data/users/smondal5/VHcc_gen/CMSSampleProd/condor/CMSSW_13_0_14/src

voms-proxy-info
mkdir -p $workdir
cd $workdir

#------------------------------ step LHE,GEN,SIM
export SCRAM_ARCH=el8_amd64_gcc11

if [ ! -f "RAWSIM.root" ]; then
    scram p CMSSW CMSSW_13_0_17
    cd CMSSW_13_0_17/src
    eval `scram runtime -sh`
    cp -r $maindir/Configuration .
    sed -i "s/HMASS/$3/g; s/HADFLAV/$5/g" Configuration/GenProduction/python/ZHjj.py
    scram b -j $NCPU
    cd ../..

    cmsDriver.py Configuration/GenProduction/python/ZHjj.py --python_filename makeRAWSIM.py --eventcontent RAWSIM,LHE --customise Configuration/DataProcessing/Utils.addMonitoring --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int($1)"\\nprocess.source.numberEventsInLuminosityBlock="cms.untracked.uint32(250)" --datatier GEN-SIM,LHE --conditions 130X_mcRun3_2023_realistic_postBPix_v6 --beamspot Realistic25ns13p6TeVEarly2023Collision --step LHE,GEN,SIM --geometry DB:Extended --era Run3_2023 --fileout file:RAWSIM.root --number $4 --number_out $4 --no_exec --mc
    cmsRun makeRAWSIM.py
fi

echo "ls:"
ls

# #------------------------------ step DIGI,DATAMIX,L1,DIGI2RAW,HLT+AOD+Mini+Nano
# scram p CMSSW CMSSW_13_0_14
# cd CMSSW_13_0_14/src
# eval `scram runtime -sh`
# git cms-merge-topic Ming-Yan:130X-fixPuppi_NanoV12
# cat << 'EOF' >> PhysicsTools/NanoAOD/python/custom_btv_cff.py

# def PrepBTVCustomNanoAOD_MC_all(process):
#     addPFCands(process, True, True,nanoAOD_addbtagAK4_switch,nanoAOD_addbtagAK8_switch)
#     add_BTV(process, True,nanoAOD_addbtagAK4_switch,nanoAOD_addbtagAK8_switch)
#     return process
# EOF
# scram b -j $NCPU
# cd ../..

cd $CMSSW_13_0_14_PATH
eval `scram runtime -sh`
cd $workdir

if [ ! -f "RAW.root" ]; then
    cmsDriver.py  --eventcontent PREMIXRAW --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --conditions 130X_mcRun3_2023_realistic_postBPix_v6 --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2023v12 --procModifiers premix_stage2 --geometry DB:Extended --datamix PreMix --era Run3_2023 --python_filename makeRAW.py --fileout file:RAW.root --filein file:RAWSIM.root -n -1 --pileup_input "root://eoscms.cern.ch//eos/cms/store/mc/Run3Summer21PrePremix/Neutrino_E-10_gun/PREMIX/Summer23BPix_130X_mcRun3_2023_realistic_postBPix_v1-v1/40000/00ad9cc6-a041-4d9c-acbb-a9d724e878a9.root" --no_exec --mc

    cmsRun makeRAW.py
fi
echo "ls:"
ls

if [ ! -f "AOD.root" ]; then
    cmsDriver.py  --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --conditions 130X_mcRun3_2023_realistic_postBPix_v6 --step RAW2DIGI,L1Reco,RECO,RECOSIM --geometry DB:Extended --era Run3_2023 --python_filename makeAOD.py --fileout file:AOD.root --filein file:RAW.root -n -1 --no_exec --mc
    cmsRun makeAOD.py
fi
echo "ls:"
ls

if [ ! -f "Mini.root" ]; then
    cmsDriver.py  --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --conditions 130X_mcRun3_2023_realistic_postBPix_v6 --step PAT --geometry DB:Extended --era Run3_2023 --python_filename makeMini.py --fileout file:Mini.root --filein file:AOD.root -n -1 --no_exec --mc
    cmsRun makeMini.py
fi
echo "ls:"
ls

if [ ! -f "PFNano.root" ]; then
    cmsDriver.py  --scenario pp --era Run3_2023 --step NANO --conditions 130X_mcRun3_2023_realistic_postBPix_v6 --datatier NANOAODSIM --eventcontent NANOAODSIM --python_filename makePFNano.py --fileout file:PFNano.root --filein file:Mini.root -n -1 --no_exec --mc --customise PhysicsTools/NanoAOD/custom_btv_cff.PrepBTVCustomNanoAOD_MC_all
    cmsRun makePFNano.py
fi

if [ ! -f "Nano.root" ]; then
    cmsDriver.py  --scenario pp --era Run3_2023 --step NANO --conditions 130X_mcRun3_2023_realistic_postBPix_v6 --datatier NANOAODSIM --eventcontent NANOAODSIM --python_filename makeNano.py --fileout file:Nano.root --filein file:Mini.root -n -1 --no_exec --mc 
    cmsRun makeNano.py
fi
echo "ls:"
ls

cd $maindir