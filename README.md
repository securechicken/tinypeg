# Tinypeg
Transforms [Amnesty International's Pegasus domain IOCs](https://github.com/AmnestyTech/investigations/tree/master/2021-07-18_nso) to a TinyCheck watcher source format.

## How to use
On your TinyCheck install, edit the TinyCheck configuration file at `/usr/share/tinycheck/config.yaml`. Add the `https://raw.githubusercontent.com/securechicken/tinypeg/main/tinypeg.json` URL as a new source in a new line under `watchers`'s `iocs` section, just like in this example:
```
watchers:
  iocs:
  - https://raw.githubusercontent.com/KasperskyLab/TinyCheck/main/assets/iocs.json
  - https://raw.githubusercontent.com/Te-k/stalkerware-indicators/master/indicators-for-tinycheck.json
  - https://raw.githubusercontent.com/securechicken/tinypeg/main/tinypeg.json
```
Then restart the watchers on TinyCheck (optional) to get an immediate update: `sudo service tinycheck-watchers restart`.

## How to build the TinyCheck-formatted IOCs list

Just clone the repository, and run `tinypeg.sh` (requires Bash 4+, as well as wget, grep, cut and diff in path). It will write a `tinypeg.iocs` file as a result.
