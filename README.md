# CertGen
Shell script to generate CA and wildcard certificate for testing purposes.

One can find a million other similar projects, but this script works for me.


# How to use
### 1) Generate certs
```
./certgen.sh test.local
```
### 2) Add generated CA to trusted certificates
#### Linux / Ubuntu
```
sudo mkdir -p  /usr/share/ca-certificates/local/
sudo cp CA.crt /usr/share/ca-certificates/local/
sudo dpkg-reconfigure ca-certificates
```
#### Windows
Right Click on CA.crt file in explorer -> Install Certificate
* Current User
* Place all certificates in the following store: Trusted Root Certification Authorities
* Finish
