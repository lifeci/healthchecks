# healthchecks
generic scripts for fast healthchecks


# usage
## compose-all
- set delay via env variable
```bash
ScriptUrl=https://raw.githubusercontent.com/lifeci/healthchecks/master/compose-all.sh
export  DelayInput=7; curl -Ssk $ScriptUrl | bash -f --
```
- tmp location
```bash
ScriptUrl=https://raw.githubusercontent.com/lifeci/healthchecks/master/compose-all.sh
curl -Ssk $ScriptUrl > /tmp/hc.sh; bash -f /tmp/hc.sh 6
```

## compose-ps-grep-svc
```bash
ScriptUrl=https://raw.githubusercontent.com/lifeci/healthchecks/master/compose-ps-grep-svc.sh
curl -Ssk $ScriptUrl > /tmp/hc.sh; bash -f /tmp/hc.sh $SvcName $Delay
```
