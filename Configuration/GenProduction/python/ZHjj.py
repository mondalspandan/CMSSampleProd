import FWCore.ParameterSet.Config as cms

# link to cards:
# https://github.com/alintulu/genproductions/blob/7625d99f760709a3609d2c5796cdc71ce9b8a8f6/bin/Powheg/production/Run3/13p6TeV/Higgs/HZJ_HanythingJ_NNPDF31_13p6TeV/HZJ_HanythingJ_NNPDF31_13p6TeV_M125_Vleptonic.input

externalLHEProducer = cms.EDProducer("ExternalLHEProducer",
    args = cms.vstring('/isilon/data/users/smondal5/VHcc_gen/CMSSW_13_0_14/src/genproductions/bin/Powheg/HZJ_el8_amd64_gcc11_CMSSW_13_0_14_HZJ_HMASS.tgz'),
    nEvents = cms.untracked.uint32(5000),
    generateConcurrently = cms.untracked.bool(True),
    numberOfParameters = cms.uint32(1),
    outputFile = cms.string('cmsgrid_final.lhe'),
    scriptName = cms.FileInPath('GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs.sh')
)

import FWCore.ParameterSet.Config as cms
from Configuration.Generator.Pythia8CommonSettings_cfi import *
from Configuration.Generator.MCTunesRun3ECM13p6TeV.PythiaCP5Settings_cfi import *
from Configuration.Generator.Pythia8PowhegEmissionVetoSettings_cfi import *
from Configuration.Generator.PSweightsPythia.PythiaPSweightsSettings_cfi import *

generator = cms.EDFilter("Pythia8ConcurrentHadronizerFilter",
                         maxEventsToPrint = cms.untracked.int32(1),
                         pythiaPylistVerbosity = cms.untracked.int32(1),
                         filterEfficiency = cms.untracked.double(1.0),
                         pythiaHepMCVerbosity = cms.untracked.bool(False),
                         comEnergy = cms.double(13600.),
                         PythiaParameters = cms.PSet(
        pythia8CommonSettingsBlock,
        pythia8CP5SettingsBlock,
        pythia8PSweightsSettingsBlock,
        pythia8PowhegEmissionVetoSettingsBlock,
        processParameters = cms.vstring(
            'POWHEG:nFinal = 3',   ## Number of final state particles
                                   ## (BEFORE THE DECAYS) in the LHE
                                   ## other than emitted extra parton
            '25:m0 = HMASS.0',
            '25:onMode = off',
            '25:onIfMatch = HADFLAV -HADFLAV',
        ),
        parameterSets = cms.vstring('pythia8CommonSettings',
                                    'pythia8CP5Settings',
                                    'pythia8PSweightsSettings',
                                    'pythia8PowhegEmissionVetoSettings',
                                    'processParameters'
                                    )
        )
                         )

ProductionFilterSequence = cms.Sequence(generator)