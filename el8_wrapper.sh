#!/bin/bash
set -e
export maindir=/isilon/data/users/smondal5/VHcc_gen
export workdir=$maindir/CMSSampleProd/condor/workdir_$1_$2
cd $maindir
echo "I am here"
pwd
export mass=$(( $2 + 20 ))
echo "Doing mass $mass"
export nevs=500
echo "Will produce $nevs events"
source /cvmfs/cms.cern.ch/cmsset_default.sh

export bbfile=/isilon/data/users/smondal5/VHcc_gen/gen/ZHbb_Nano/ZHbb_$1_$2_MH${mass}.root

if [ ! -f "$bbfile" ]; then
    echo "Running bb"
    cmssw-el8 --command-to-run "bash CMSSampleProd/cmsDrive_commands_2023BPix.sh $1 $2 $mass $nevs 5"
    cp -v ${workdir}_5/PFNano.root /isilon/data/users/smondal5/VHcc_gen/gen/ZHbb_PFNano/ZHbb_$1_$2_MH${mass}.root
    cp -v ${workdir}_5/Nano.root $bbfile
    rm -rf ${workdir}_5
fi

cd $maindir
echo "I am here"
pwd

export ccfile=/isilon/data/users/smondal5/VHcc_gen/gen/ZHcc_Nano/ZHcc_$1_$2_MH${mass}.root

if [ ! -f "$ccfile" ]; then
    echo "Running cc"
    cmssw-el8 --command-to-run "bash CMSSampleProd/cmsDrive_commands_2023BPix.sh $1 $2 $mass $nevs 4"
    cp -v ${workdir}_4/PFNano.root /isilon/data/users/smondal5/VHcc_gen/gen/ZHcc_PFNano/ZHcc_$1_$2_MH${mass}.root
    cp -v ${workdir}_4/Nano.root $ccfile
    rm -rf ${workdir}_4
fi