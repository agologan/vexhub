# VEX Hub repository

VEX Hub repository contains a collection of [VEX]
(Vulnerability-Exploitability eXchange) related reports for various tools.


## Using reports with trivy-operator

The first thing that's required is having the reports loaded into the cluster.

To do this we'll load them as a ConfigMap.

```sh
kubectl create configmap merged-openvex -n trivy --from-file=merged.openvex.json --dry-run -o yaml | kubectl apply -f -
```
This assumes the reports fit into a single ConfigMap otherwise you'll need to load them into a volume via other means.

Then tell trivy to use the files via `trivy.yaml`
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: trivy-config
  namespace: trivy
data:
  trivy.yaml: |
    vulnerability:
      vex:
        - /tmp/vex/merged.openvex.json
```
This may be fixed in the future and not require defining another config.

And finally make them available to the scanner by mapping the configs as volumes:
```yaml
scanJobCustomVolumesMount:
  - name: openvex
    mountPath: /tmp/vex
    readOnly: true
  - name: config
    mountPath: /trivy.yaml
    subPath: trivy.yaml

scanJobCustomVolumes:
  - name: openvex
    configMap:
      name: merged-openvex
  - name: config
    configmap:
      name: trivy-config
```
