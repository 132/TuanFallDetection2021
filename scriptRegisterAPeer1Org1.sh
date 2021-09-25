# ORG1 register
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org1/ca/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/org1/ca/admin
#../bin/fabric-ca-client register -d --id.name  peer0 --id.secret peer1PW --id.type peer -u https://192.168.1.121:7054
../bin/fabric-ca-client register -d --id.name  peer1 --id.secret peer2PW --id.type peer -u https://192.168.1.121:7054
#../bin/fabric-ca-client register -d --id.name admin --id.secret org2AdminPW --id.type admin -u https://192.168.1.121:7054
#../bin/fabric-ca-client register -d --id.name user --id.secret org2UserPW --id.type user -u https://192.168.1.121:7054

# ENROLL
# Peer 1
# preparation
mkdir -p ${PWD}/organizations/fabric-ca/org1/peer1/assets/ca
cp ${PWD}/organizations/fabric-ca/org1/ca/admin/msp/cacerts/192-168-1-120-7054.pem ${PWD}/organizations/fabric-ca/org1/peer1/assets/ca/org1-ca-cert.pem
mkdir -p ${PWD}/organizations/fabric-ca/org1/peer1/assets/tls-ca
cp ${PWD}/organizations/fabric-ca/tls-ca/admin/msp/cacerts/192-168-1-115-7052.pem ${PWD}/organizations/fabric-ca/org1/peer1/assets/tls-ca/tls-ca-cert.pem

# for identity
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/org1/peer1
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org1/peer1/assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
../bin/fabric-ca-client enroll -d -u https://peer1:peer2PW@192.168.1.120:7054
sleep 5

# for TLS
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org1/peer1/assets/tls-ca/tls-ca-cert.pem
../bin/fabric-ca-client enroll -d -u https://peer1-org1:peer2PW@192.168.1.115:7052 --enrollment.profile tls --csr.hosts  peer1.org1.example.com --csr.hosts 192.168.1.121
sleep 5
cp ${PWD}/organizations/fabric-ca/org1/peer1/tls-msp/keystore/*_sk ${PWD}/organizations/fabric-ca/org1/peer1/tls-msp/keystore/key.pem
cp ${PWD}/organizations/fabric-ca/org1/peer1/tls-msp/tlscacerts/* ${PWD}/organizations/fabric-ca/org1/peer1/tls-msp/ca.crt
cp ${PWD}/organizations/fabric-ca/org1/peer1/tls-msp/signcerts/* ${PWD}/organizations/fabric-ca/org1/peer1/tls-msp/server.crt
cp ${PWD}/organizations/fabric-ca/org1/peer1/tls-msp/keystore/*_sk ${PWD}/organizations/fabric-ca/org1/peer1/tls-msp/server.key
