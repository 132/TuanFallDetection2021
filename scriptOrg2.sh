docker-compose -f ./ca-docker/docker-compose-ca-org2.yaml up -d

export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/tls-ca/tls-cert.pem
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/tls-ca/admin
../bin/fabric-ca-client register -d --id.name  peer0-org2 --id.secret peer1PW --id.type peer -u https://192.168.1.115:7052
../bin/fabric-ca-client register -d --id.name  peer1-org2 --id.secret peer2PW --id.type peer -u https://192.168.1.115:7052

  # ORG2 register
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org2/ca/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/org2/ca/admin

../bin/fabric-ca-client enroll -d -u https://rca-org2-admin:rca-org2-adminpw@192.168.1.121:7054
sleep 5

../bin/fabric-ca-client register -d --id.name  peer0 --id.secret peer1PW --id.type peer -u https://192.168.1.121:7054
../bin/fabric-ca-client register -d --id.name  peer1 --id.secret peer2PW --id.type peer -u https://192.168.1.121:7054
../bin/fabric-ca-client register -d --id.name admin --id.secret org2AdminPW --id.type admin -u https://192.168.1.121:7054
../bin/fabric-ca-client register -d --id.name user --id.secret org2UserPW --id.type user -u https://192.168.1.121:7054

# ENROLL
# Peer 0
# preparation
mkdir -p ${PWD}/organizations/fabric-ca/org2/peer0/assets/ca
cp ${PWD}/organizations/fabric-ca/org2/ca/admin/msp/cacerts/192-168-1-121-7054.pem ${PWD}/organizations/fabric-ca/org2/peer0/assets/ca/org2-ca-cert.pem

mkdir -p ${PWD}/organizations/fabric-ca/org2/peer0/assets/tls-ca
cp ${PWD}/organizations/fabric-ca/tls-ca/admin/msp/cacerts/192-168-1-115-7052.pem ${PWD}/organizations/fabric-ca/org2/peer0/assets/tls-ca/tls-ca-cert.pem

# for identity
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/org2/peer0
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org2/peer0/assets/ca/org2-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

../bin/fabric-ca-client enroll -d -u https://peer0:peer1PW@192.168.1.121:7054
sleep 5

# for TLS
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org2/peer0/assets/tls-ca/tls-ca-cert.pem

../bin/fabric-ca-client enroll -d -u https://peer0-org2:peer1PW@192.168.1.115:7052 --enrollment.profile tls --csr.hosts  peer0.org2.example.com --csr.hosts 192.168.1.121
sleep 5

cp ${PWD}/organizations/fabric-ca/org2/peer0/tls-msp/keystore/*_sk ${PWD}/organizations/fabric-ca/org2/peer0/tls-msp/keystore/key.pem

cp ${PWD}/organizations/fabric-ca/org2/peer0/tls-msp/tlscacerts/* ${PWD}/organizations/fabric-ca/org2/peer0/tls-msp/ca.crt
cp ${PWD}/organizations/fabric-ca/org2/peer0/tls-msp/signcerts/* ${PWD}/organizations/fabric-ca/org2/peer0/tls-msp/server.crt
cp ${PWD}/organizations/fabric-ca/org2/peer0/tls-msp/keystore/*_sk ${PWD}/organizations/fabric-ca/org2/peer0/tls-msp/server.key

"Enroll Admin"

export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/org2/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org2/peer0/assets/ca/org2-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

../bin/fabric-ca-client enroll -d -u https://admin:org2AdminPW@192.168.1.121:7054

mkdir -p ${PWD}/organizations/fabric-ca/org2/peer0/msp/admincerts
cp ${PWD}/organizations/fabric-ca/org2/admin/msp/signcerts/cert.pem ${PWD}/organizations/fabric-ca/org2/peer0/msp/admincerts/org2-admin-cert.pem

mkdir -p ${PWD}/organizations/fabric-ca/org2/peer1/msp/admincerts
cp ${PWD}/organizations/fabric-ca/org2/admin/msp/signcerts/cert.pem ${PWD}/organizations/fabric-ca/org2/peer1/msp/admincerts/org2-admin-cert.pem

mkdir -p ${PWD}/organizations/fabric-ca/org2/admin/msp/admincerts
cp ${PWD}/organizations/fabric-ca/org2/admin/msp/signcerts/cert.pem ${PWD}/organizations/fabric-ca/org2/admin/msp/admincerts/org2-admin-cert.pem

mkdir -p ${PWD}/organizations/fabric-ca/org2/msp/{admincerts,cacerts,tlscacerts,users}
cp ${PWD}/organizations/fabric-ca/org2/peer0/assets/ca/org2-ca-cert.pem ${PWD}/organizations/fabric-ca/org2/msp/cacerts/
cp ${PWD}/organizations/fabric-ca/org2/peer0/assets/tls-ca/tls-ca-cert.pem ${PWD}/organizations/fabric-ca/org2/msp/tlscacerts/
cp ${PWD}/organizations/fabric-ca/org2/admin/msp/signcerts/cert.pem ${PWD}/organizations/fabric-ca/org2/msp/admincerts/admin-org2-cert.pem
cp ./org2-config.yaml ${PWD}/organizations/fabric-ca/org2/msp/config.yaml
