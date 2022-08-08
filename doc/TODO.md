### @Everyone
- [ ] Refactor features using new metadata properties depending on the assigned maintainer.
      Assignations are in the doc.
- [ ] After capabilities have been renamed using camelCase to avoid spell errors in the code, rename
      the properties that are affected, such as "launcherkeynames", which will be transformed to more
      standard form "launcherKeys"
- [ ] Rename keyNames so they do not have underscores or have spell mistakes. If they have spell
      mistakes write them down into the `.spelling_dictionary.dic` of the project
- [ ] After general metadata refactor, metadata has to be moved to individual `.sh` files for each
      feature into the src/features/FEATUREKEYNAME/FEATUREKEYNAME_metadata.sh
- [ ] After general metadata refactor, commentary has to be moved to individual `.md` files for each
      feature into the src/features/FEATUREKEYNAME/FEATUREKEYNAME_documentation.sh
- [ ] Make all relevant bars local and -r if necessary.
- [ ] AutoFirma should work without explicit decompression paths. 
- [ ] Upgrade anticollisioner with number
- [ ] In Keywords property of desktop launcher load feature keyname, feature arguments, feature keywords

### @AleixMT
- [ ] In uninstall mode, --flush=cache must delete folders of the cache, corresponding to git repositories
- [ ] *After @AleixMT maintained features are trimmed and apt to standards, all the rest of features
      that do not comply with new standards will be deprecated with its further deletion from future
      versions*

### @Axlfc
- [~] Rename caps named features that con bad interpreted in MacOS and Windows (L, B, F, E...)
- [~] Refactor bash functions property in graphical features with silentFunction.
- [ ] openssh feature not working

### DONE
- [x] Create a desktop launcher with Terminal=true option if is terminal interpretation is possible in features that are programming languages.
- [x] Make change to output proxy executioner so it handles the logic of the flag ignore errors,
- [x] Create new flag all warnings are errors that is handled also by output proxy
- [x] Create function isRoot and substitute in all the if that check the euid value
- [x] Add property to dynamic launcher X Ubuntu getext domain. 
- [x] Make dynamicLauncher deduce windowclass property from key name
- [x] Create reading of external file in .customizer to load custom flags and variables
- [x] launchercontents key names metadata input in data_features.sh
