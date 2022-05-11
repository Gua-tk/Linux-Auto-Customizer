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


### @AleixMT
- [x] Create reading of external file in .customizer to load custom flags and variables
- [ ] In uninstall mode, --flush=cache must delete folders of the cache, corresponding to git repositories
- [ ] *After @AleixMT maintained features are trimmed and apt to standards, all the rest of features
      that do not comply with new standards will be deprecated with its further deletion from future
      versions*

### @Axlfc
- [ ] Rename caps named features that con bad interpreted in MacOS and Windows (L, B, F, E...)
- [ ] launchercontents key names metadata input in data_features.sh