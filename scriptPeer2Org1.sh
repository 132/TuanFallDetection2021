export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/tls-ca/tls-cert.pem
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/tls-ca/admin

#../bin/fabric-ca-client register -d --id.name peer0-org1 --id.secret peer1PW --id.type peer -u https://192.168.1.115:7052
../bin/fabric-ca-client register -d --id.name peer2-org1 --id.secret peer3PW --id.type peer -u https://192.168.1.115:7052

# ORG1
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org1/ca/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/org1/ca/admin
#../bin/fabric-ca-client register -d --id.name peer1 --id.secret peer2PW --id.type peer -u https://192.168.1.121:7054
../bin/fabric-ca-client register -d --id.name peer2 --id.secret peer3PW --id.type peer -u https://192.168.1.120:7054
#../bin/fabric-ca-client register -d --id.name admin --id.secret org1AdminPW --id.type admin -u https://192.168.1.120:7054
#../bin/fabric-ca-client register -d --id.name user1 --id.secret org1UserPW --id.type client -u https://192.168.1.120:7054

# enroll
# Peer 2
# preparation
mkdir -p ${PWD}/organizations/fabric-ca/org1/peer2/assets/ca
cp ${PWD}/organizations/fabric-ca/org1/ca/admin/msp/cacerts/192-168-1-120-7054.pem ${PWD}/organizations/fabric-ca/org1/peer2/assets/ca/org1-ca-cert.pem

mkdir -p ${PWD}/organizations/fabric-ca/org1/peer2/assets/tls-ca
cp ${PWD}/organizations/fabric-ca/tls-ca/admin/msp/cacerts/192-168-1-115-7052.pem ${PWD}/organizations/fabric-ca/org1/peer2/assets/tls-ca/tls-ca-cert.pem

  # for identity
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/org1/peer2
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org1/peer2/assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

../bin/fabric-ca-client enroll -d -u https://peer2:peer3PW@192.168.1.120:7054
sleep 5

  # for TLS
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org1/peer2/assets/tls-ca/tls-ca-cert.pem
../bin/fabric-ca-client enroll -d -u https://peer2-org1:peer3PW@192.168.1.115:7052 --enrollment.profile tls --csr.hosts peer2.org1.example.com --csr.hosts 192.168.1.123
sleep 5

cp ${PWD}/organizations/fabric-ca/org1/peer2/tls-msp/keystore/*_sk ${PWD}/organizations/fabric-ca/org1/peer2/tls-msp/keystore/key.pem
cp ${PWD}/organizations/fabric-ca/org1/peer2/tls-msp/tlscacerts/* ${PWD}/organizations/fabric-ca/org1/peer2/tls-msp/ca.crt
cp ${PWD}/organizations/fabric-ca/org1/peer2/tls-msp/signcerts/* ${PWD}/organizations/fabric-ca/org1/peer2/tls-msp/server.crt
cp ${PWD}/organizations/fabric-ca/org1/peer2/tls-msp/keystore/*_sk ${PWD}/organizations/fabric-ca/org1/peer2/tls-msp/server.key
