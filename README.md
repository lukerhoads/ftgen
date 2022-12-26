# `ftgen`

A program made in Haskell that helps you generate file trees. 

```
📁 ftgen
├─📁 app
│  ├─ Main.hs
├─📁 src
│  ├─ Lib.hs
├─📁 test
│  ├─ Spec.hs
├─ .ftgenignore
├─ .gitignore
├─ CHANGELOG.md
├─ LICENSE
├─ README.md
├─ Setup.hs
├─ ftgen.cabal
├─ package.yaml
├─ stack.yaml
├─ stack.yaml.lock
├─ test.hs
```

## Install 

### Prerequisites
- [Stack](https://docs.haskellstack.org/en/stable/)

```bash
git clone https://github.com/lukerhoads/ftgen.git 
cd ftgen
stack build --copy-bins
```
Either add the `bin` directory to path, or run 
```bash
sudo ln -s $(eval pwd)/bin/ftgen /usr/local/bin/ftgen
```

## Options 
- `--noToplevel` - Specifies whether you want to show the top level file of the target directory.
- `--noSortByFolder` - Specifies whether you want to sort the files by folder, with folders taking precedence over files. 
- `--noSortByName` - Specifies whether you want the files to be sorted by their name, alphabetically.
- `--ignoreFile={PATH_TO_IGNORE_FILE}` - Path to your ignore file, which lists files by name to ignore.


