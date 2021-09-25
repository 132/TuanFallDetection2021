docker-compose -f ./ca-docker/docker-compose-ca-org3.yaml up -d

#
# register
# TLS
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/tls-ca/tls-cert.pem
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/tls-ca/admin

../bin/fabric-ca-client register -d --id.name peer0-org3 --id.secret peer1PW --id.type peer -u https://192.168.1.115:7052
../bin/fabric-ca-client register -d --id.name peer1-org3 --id.secret peer2PW --id.type peer -u https://192.168.1.115:7052

# ORG3
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org3/ca/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/org3/ca/admin
  # enroll  admin for CA
../bin/fabric-ca-client enroll -d -u https://rca-org3-admin:rca-org3-adminpw@192.168.1.122:7054
  # register peers, admin, user for ORG
../bin/fabric-ca-client register -d --id.name peer0 --id.secret peer1PW --id.type peer -u https://192.168.1.122:7054
../bin/fabric-ca-client register -d --id.name peer1 --id.secret peer2PW --id.type peer -u https://192.168.1.122:7054
../bin/fabric-ca-client register -d --id.name admin --id.secret org3AdminPW --id.type admin -u https://192.168.1.122:7054
../bin/fabric-ca-client register -d --id.name user1 --id.secret org3UserPW --id.type client -u https://192.168.1.122:7054

# enroll
  # preparation
mkdir -p ${PWD}/organizations/fabric-ca/org3/peer0/assets/ca
cp ${PWD}/organizations/fabric-ca/org3/ca/admin/msp/cacerts/192-168-1-122-7054.pem ${PWD}/organizations/fabric-ca/org3/peer0/assets/ca/org3-ca-cert.pem

mkdir -p ${PWD}/organizations/fabric-ca/org3/peer0/assets/tls-ca
cp ${PWD}/organizations/fabric-ca/tls-ca/admin/msp/cacerts/192-168-1-115-7052.pem ${PWD}/organizations/fabric-ca/org3/peer0/assets/tls-ca/tls-ca-cert.pem

  # for identity
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/org3/peer0
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org3/peer0/assets/ca/org3-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

../bin/fabric-ca-client enroll -d -u https://peer0:peer1PW@192.168.1.122:7054
sleep 5

  # for TLS
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org3/peer0/assets/tls-ca/tls-ca-cert.pem

../bin/fabric-ca-client enroll -d -u https://peer0-org3:peer1PW@192.168.1.115:7052 --enrollment.profile tls --csr.hosts peer0.org3.example.com --csr.hosts 192.168.1.122
sleep 5

cp ${PWD}/organizations/fabric-ca/org3/peer0/tls-msp/keystore/*_sk ${PWD}/organizations/fabric-ca/org3/peer0/tls-msp/keystore/key.pem

cp ${PWD}/organizations/fabric-ca/org3/peer0/tls-msp/tlscacerts/* ${PWD}/organizations/fabric-ca/org3/peer0/tls-msp/ca.crt
cp ${PWD}/organizations/fabric-ca/org3/peer0/tls-msp/signcerts/* ${PWD}/organizations/fabric-ca/org3/peer0/tls-msp/server.crt
cp ${PWD}/organizations/fabric-ca/org3/peer0/tls-msp/keystore/*_sk ${PWD}/organizations/fabric-ca/org3/peer0/tls-msp/server.key

# Admin enroll
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/org3/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org3/peer0/assets/ca/org3-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

../bin/fabric-ca-client enroll -d -u https://admin:org3AdminPW@192.168.1.122:7054

mkdir -p ${PWD}/organizations/fabric-ca/org3/peer0/msp/admincerts
cp ${PWD}/organizations/fabric-ca/org3/admin/msp/signcerts/cert.pem ${PWD}/organizations/fabric-ca/org3/peer0/msp/admincerts/org3-admin-cert.pem

mkdir -p ${PWD}/organizations/fabric-ca/org3/peer1/msp/admincerts
cp ${PWD}/organizations/fabric-ca/org3/admin/msp/signcerts/cert.pem ${PWD}/organizations/fabric-ca/org3/peer1/msp/admincerts/org3-admin-cert.pem

mkdir -p ${PWD}/organizations/fabric-ca/org3/admin/msp/admincerts
cp ${PWD}/organizations/fabric-ca/org3/admin/msp/signcerts/cert.pem ${PWD}/organizations/fabric-ca/org3/admin/msp/admincerts/org3-admin-cert.pem

mkdir -p ${PWD}/organizations/fabric-ca/org3/msp/{admincerts,cacerts,tlscacerts,users}
cp ${PWD}/organizations/fabric-ca/org3/peer0/assets/ca/org3-ca-cert.pem ${PWD}/organizations/fabric-ca/org3/msp/cacerts/
cp ${PWD}/organizations/fabric-ca/org3/peer0/assets/tls-ca/tls-ca-cert.pem ${PWD}/organizations/fabric-ca/org3/msp/tlscacerts/
cp ${PWD}/organizations/fabric-ca/org3/admin/msp/signcerts/cert.pem ${PWD}/organizations/fabric-ca/org3/msp/admincerts/admin-org3-cert.pem
cp ./org3-config.yaml ${PWD}/organizations/fabric-ca/org3/msp/config.yaml

# user 1
# fabric-ca-client register --caname ca-org3 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
#  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-org3 -M ${PWD}/organizations/peerOrganizations/org3.example.com/users/User1@org3.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
mkdir -p organizations/fabric-ca/org3/users
mkdir -p organizations/fabric-ca/org3/users/User1@org3.example.com

../bin/fabric-ca-client enroll -u https://user1:org3UserPW@192.168.1.122:7054 --caname rca-org3 -M ${PWD}/organizations/fabric-ca/org3/users/User1@org3.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org3/ca/tls-cert.pem

cp ${PWD}/organizations/fabric-ca/org3/msp/config.yaml ${PWD}/organizations/fabric-ca/org3/users/User1@org3.example.com/msp/config.yaml
