# Internal repo to configure elasticsearch with security
This repo has certificates, keystore and configuration.

## Build 
The command `bash docker_build.sh build` processes the `Dockerfile` to create a container to deploy in kubernetes.

## Steps to generate certificates
- Deploy elastic without security either in a pod or locally. Steps assume a pod.
- Connect to pod: `kubectl exec -it [PODNAME] -- bash`
- Generate three strong passwords: CAPASS, NODEPASS, HTTPASS
- Generate CA: `/usr/share/elasticsearch/bin/elasticsearch-certutil ca -out elastic-stack-ca.p12 --pass [CAPASS]`
- Generate Node certificate `/usr/share/elasticsearch/bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12 --ca-pass [CAPASS] --out /usr/share/elasticsearch/config/certs/cert.p12 --pass [CERTPASS]`
- Generate HTTP certificate  `/usr/share/elasticsearch/bin/elasticsearch-certutil http`
Options: 
```
Generate a CSR? [y/N]n
Use an existing CA? [y/N]y
CA Path: /usr/share/elasticsearch/elastic-stack-ca.p12
[CAPASS]
For how long should your certificate be valid? [5y] 
Generate a certificate per node? [y/N]n
Hostnames:
    *.elasticsearch.default.svc.cluster.local
    *.elasticsearch
    es-cluster-0.elasticsearch
    es-cluster-1.elasticsearch
    es-cluster-2.elasticsearch
You did not enter any IP addresses.
Is this correct [Y/n]y
Do you wish to change any of these options? [y/N]n
Provide a password for the "http.p12" file:  [<ENTER> for none] [HTTPASS]
```
- Copy files to repo: `kubectl cp [PODNAME]:/usr/share/elasticsearch/elasticsearch-ssl-http.zip ./elastic-poppins`

## Add secure settings 
- Connect to pod: `kubectl exec -it [PODNAME] -- bash`
- Add to keystore: `bin/elasticsearch-keystore  add [SETTING_NAME]`
- Update keystore in repo `kubectl cp [PODNAME]:/usr/share/elasticsearch/config/elasticsearch.keystore ./config/elasticsearch.keystore`