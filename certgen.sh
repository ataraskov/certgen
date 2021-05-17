#!/usr/bin/env bash
################################################################################
# Version: 0.1.20210517
# Usage  : certgen.sh <domain.name>
# Descr  : Generate CA and wildcard certificate for testing purposes
#          Script skips exising files, remove them if new cert is needed
################################################################################
set -e          # exit on failed commands
set -u          # check for unbound variables
set -o pipefail # fail in pipelines

domain="${1:-test.local}"

echo "# creating private CA key"
test -f CA.key || \
openssl genrsa -out CA.key 4096

echo "# creating private CA cert"
test -f CA.crt || \
openssl req -x509 -new \
  -key CA.key \
  -out CA.crt \
  -days 730 \
  -subj "/CN=${domain} CA"

echo "# creating key"
test -f ${domain}.key || \
openssl genrsa -out ${domain}.key 4096

echo "# creating req"
test -f ${domain}.req || \
openssl req -new \
  -out ${domain}.req \
  -key ${domain}.key \
  -nodes -sha256 \
  -subj "/CN=${domain}" \
  -addext "subjectAltName = DNS:${domain},DNS:*.${domain}" \
  -addext "certificatePolicies = 1.2.3.4"
#openssl req -in ${domain}.req -text -noout | grep -A1 Alternativ

echo "# signing req"
test -f ${domain}.crt || \
openssl x509 -req \
  -in ${domain}.req \
  -out ${domain}.crt \
  -CAkey CA.key \
  -CA CA.crt \
  -days 365 \
  -sha256 \
  -extensions v3_req \
  -CAcreateserial \
  -CAserial serial \
  -extfile <(echo "
[req]
distinguished_name = dn
req_extensions = v3_req
x509_extensions = v3_req
prompt = no

[dn]
CN = ${domain}

[v3_req]
subjectKeyIdentifier = hash
basicConstraints = critical,CA:FALSE
keyUsage = critical,digitalSignature,keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = www.${domain}
DNS.2 = ${domain}
DNS.3 = *.${domain}
")

# echo "# printing crt"
# openssl x509 -in ${domain}.crt -text -noout
echo "# printing crt (altnames)"
openssl x509 -in ${domain}.crt -text -noout | grep -A1 Alternative

# echo "# adding to cacerts"
# sudo mkdir -p  /usr/share/ca-certificates/local/
# sudo cp CA.crt /usr/share/ca-certificates/local/
# sudo dpkg-reconfigure ca-certificates
# grep local /etc/ca-certificates.conf
echo "# done"
