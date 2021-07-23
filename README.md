# Tinypeg
Transforms [Amnesty International's Pegasus domain IOCs](https://github.com/AmnestyTech/investigations/tree/master/2021-07-18_nso) to a TinyCheck watcher source format. As so, by simply adding a URL to your TinyCheck configuration, you can require your TinyCheck instance to automatically retrieve, update and check for Pegasus IOCs.

## How to use
Add the `https://raw.githubusercontent.com/securechicken/tinypeg/main/tinypeg.json` URL to your TinyCheck watchers' sources. That's all.  

While TinyCheck does not allow you to simply copy/paste the URL in the "Manage IOCs" section of the backend Web UI (this capability has been prepared and [proposed to the project](https://github.com/KasperskyLab/TinyCheck/pull/77)):

- On your TinyCheck install, edit the TinyCheck configuration file at `/usr/share/tinycheck/config.yaml`. Add the URL as a new source in a new line under `watchers` / `iocs` section, just like in this example:
```
watchers:
  iocs:
  - https://raw.githubusercontent.com/KasperskyLab/TinyCheck/main/assets/iocs.json
  - https://raw.githubusercontent.com/Te-k/stalkerware-indicators/master/indicators-for-tinycheck.json
  - https://raw.githubusercontent.com/securechicken/tinypeg/main/tinypeg.json
```
- Then restart the watchers on TinyCheck (optional) to get an immediate update: `sudo service tinycheck-watchers restart`.

## How to build the TinyCheck-formatted IOCs list
This is not required to use the Pegasus IOCs. This is just published as a way for the community to check how the IOCs file is generated. 

Just clone the repository, and run `tinypeg.sh` (requires Bash 4+, as well as wget, grep, cut and diff in path). It will write a `tinypeg.json` file as a result.
