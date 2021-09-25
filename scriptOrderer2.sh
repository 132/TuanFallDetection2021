
mkdir -p ${PWD}/organizations/fabric-ca/org0/orderer2/assets/ca
cp ${PWD}/organizations/fabric-ca/org0/ca/admin/msp/cacerts/192-168-1-115-7054.pem ${PWD}/organizations/fabric-ca/org0/orderer2/assets/ca/org0-ca-cert.pem

mkdir -p ${PWD}/organizations/fabric-ca/org0/orderer2/assets/tls-ca
cp ${PWD}/organizations/fabric-ca/tls-ca/admin/msp/cacerts/192-168-1-115-7052.pem ${PWD}/organizations/fabric-ca/org0/orderer2/assets/tls-ca/tls-ca-cert.pem

    # enroll identity
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/org0/orderer2
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org0/orderer2/assets/ca/org0-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

../bin/fabric-ca-client enroll -d -u https://orderer2:ordererpw@192.168.1.115:7054

    # enroll TLS
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org0/orderer2/assets/tls-ca/tls-ca-cert.pem

../bin/fabric-ca-client enroll -d -u https://orderer2:ordererPW@192.168.1.115:7052 --enrollment.profile tls --csr.hosts orderer2.example.com --csr.hosts 192.1668.1.117

cp ${PWD}/organizations/fabric-ca/org0/orderer2/tls-msp/tlscacerts/* ${PWD}/organizations/fabric-ca/org0/orderer2/tls-msp/ca.crt
cp ${PWD}/organizations/fabric-ca/org0/orderer2/tls-msp/signcerts/* ${PWD}/organizations/fabric-ca/org0/orderer2/tls-msp/server.crt
cp ${PWD}/organizations/fabric-ca/org0/orderer2/tls-msp/keystore/*_sk ${PWD}/organizations/fabric-ca/org0/orderer2/tls-msp/server.key

cp ${PWD}/organizations/fabric-ca/org0/orderer2/tls-msp/keystore/*_sk ${PWD}/organizations/fabric-ca/org0/orderer2/tls-msp/keystore/key.pem
############################################################################
mkdir -p ${PWD}/organizations/fabric-ca/org0/orderer2/msp/admincerts
cp ${PWD}/organizations/fabric-ca/org0/admin/msp/signcerts/cert.pem ${PWD}/organizations/fabric-ca/org0/orderer2/msp/admincerts/orderer-admin-cert.pem
