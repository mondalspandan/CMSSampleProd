# CMSSampleProd
HTCondor based production of CMS MC samples, from LHE to Nano.

Currently `cmsDrive_commands_2017.sh` contains commands suitable for UL2017.
Update: `cmsDrive_commands_2023BPix.sh` contains example for 2023BPix. `el8_wrapper` wraps commands in `cmssw-el8`.

1. Place your Pythia fragments inside `Configuration/GenProduction/python/`. Each of them must contain the absolute path to the gridpack (L4). Some examples are included (gridpacks not included).

2. Open `cmsDrive_commands_2017.sh` and edit the paths to point to your home and the location you cloned the repository. E.g., L3, L11, L66. Edit last 2 lines to provide an output directory.

3. Open `submit.sub` and edit "argument" line using the syntax `argument = EventsPerFile FragmentName OutputSubdirectory $(Cluster) $(Process)`. Then queue the number of output files you want to produce.

4. Activate voms-proxy.

5. Run `python getproxy.py`

6. Submit using `condor_submit submit.sub`.

Note: This modifies NanoAOD config to include AK4 PN tagger. To skip, comment out L66 in `cmsDrive_commands_2017.sh`.
