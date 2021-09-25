docker-compose -f ./ca-docker/docker-compose-ca-org1.yaml up -d

export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/tls-ca/tls-cert.pem
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/tls-ca/admin

../bin/fabric-ca-client register -d --id.name peer0-org1 --id.secret peer1PW --id.type peer -u https://192.168.1.115:7052
#../bin/fabric-ca-client register -d --id.name peer1-org1 --id.secret peer2PW --id.type peer -u https://192.168.1.115:7052

# ORG1
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org1/ca/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/org1/ca/admin

../bin/fabric-ca-client enroll -d -u https://rca-org1-admin:rca-org1-adminpw@192.168.1.120:7054

../bin/fabric-ca-client register -d --id.name peer0 --id.secret peer1PW --id.type peer -u https://192.168.1.120:7054
#../bin/fabric-ca-client register -d --id.name peer1 --id.secret peer2PW --id.type peer -u https://192.168.1.121:7054
#../bin/fabric-ca-client register -d --id.name peer2 --id.secret peer3PW --id.type peer -u https://192.168.1.123:7054
../bin/fabric-ca-client register -d --id.name admin --id.secret org1AdminPW --id.type admin -u https://192.168.1.120:7054
../bin/fabric-ca-client register -d --id.name user1 --id.secret org1UserPW --id.type client -u https://192.168.1.120:7054

# enroll
  # preparation
mkdir -p ${PWD}/organizations/fabric-ca/org1/peer0/assets/ca
cp ${PWD}/organizations/fabric-ca/org1/ca/admin/msp/cacerts/192-168-1-120-7054.pem ${PWD}/organizations/fabric-ca/org1/peer0/assets/ca/org1-ca-cert.pem

mkdir -p ${PWD}/organizations/fabric-ca/org1/peer0/assets/tls-ca
cp ${PWD}/organizations/fabric-ca/tls-ca/admin/msp/cacerts/192-168-1-115-7052.pem ${PWD}/organizations/fabric-ca/org1/peer0/assets/tls-ca/tls-ca-cert.pem

  # for identity
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/org1/peer0
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org1/peer0/assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

../bin/fabric-ca-client enroll -d -u https://peer0:peer1PW@192.168.1.120:7054
sleep 5

  # for TLS
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org1/peer0/assets/tls-ca/tls-ca-cert.pem

../bin/fabric-ca-client enroll -d -u https://peer0-org1:peer1PW@192.168.1.115:7052 --enrollment.profile tls --csr.hosts peer0.org1.example.com --csr.hosts 192.168.1.120
sleep 5

cp ${PWD}/organizations/fabric-ca/org1/peer0/tls-msp/keystore/*_sk ${PWD}/organizations/fabric-ca/org1/peer0/tls-msp/keystore/key.pem

cp ${PWD}/organizations/fabric-ca/org1/peer0/tls-msp/tlscacerts/* ${PWD}/organizations/fabric-ca/org1/peer0/tls-msp/ca.crt
cp ${PWD}/organizations/fabric-ca/org1/peer0/tls-msp/signcerts/* ${PWD}/organizations/fabric-ca/org1/peer0/tls-msp/server.crt
cp ${PWD}/organizations/fabric-ca/org1/peer0/tls-msp/keystore/*_sk ${PWD}/organizations/fabric-ca/org1/peer0/tls-msp/server.key

# Admin enroll
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/org1/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org1/peer0/assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

../bin/fabric-ca-client enroll -d -u https://admin:org1AdminPW@192.168.1.120:7054

mkdir -p ${PWD}/organizations/fabric-ca/org1/peer0/msp/admincerts
cp ${PWD}/organizations/fabric-ca/org1/admin/msp/signcerts/cert.pem ${PWD}/organizations/fabric-ca/org1/peer0/msp/admincerts/org1-admin-cert.pem

mkdir -p ${PWD}/organizations/fabric-ca/org1/peer1/msp/admincerts
cp ${PWD}/organizations/fabric-ca/org1/admin/msp/signcerts/cert.pem ${PWD}/organizations/fabric-ca/org1/peer1/msp/admincerts/org1-admin-cert.pem

mkdir -p ${PWD}/organizations/fabric-ca/org1/admin/msp/admincerts
cp ${PWD}/organizations/fabric-ca/org1/admin/msp/signcerts/cert.pem ${PWD}/organizations/fabric-ca/org1/admin/msp/admincerts/org1-admin-cert.pem

mkdir -p ${PWD}/organizations/fabric-ca/org1/msp/{admincerts,cacerts,tlscacerts,users}
cp ${PWD}/organizations/fabric-ca/org1/peer0/assets/ca/org1-ca-cert.pem ${PWD}/organizations/fabric-ca/org1/msp/cacerts/
cp ${PWD}/organizations/fabric-ca/org1/peer0/assets/tls-ca/tls-ca-cert.pem ${PWD}/organizations/fabric-ca/org1/msp/tlscacerts/
cp ${PWD}/organizations/fabric-ca/org1/admin/msp/signcerts/cert.pem ${PWD}/organizations/fabric-ca/org1/msp/admincerts/admin-org1-cert.pem
cp ./org1-config.yaml ${PWD}/organizations/fabric-ca/org1/msp/config.yaml


# user 1
# fabric-ca-client register --caname ca-org1 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
#  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
mkdir -p organizations/fabric-ca/org1/users
mkdir -p organizations/fabric-ca/org1/users/User1@org1.example.com

../bin/fabric-ca-client enroll -u https://user1:org1UserPW@192.168.1.120:7054 --caname rca-org1 -M ${PWD}/organizations/fabric-ca/org1/users/User1@org1.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/ca/tls-cert.pem

cp ${PWD}/organizations/fabric-ca/org1/msp/config.yaml ${PWD}/organizations/fabric-ca/org1/users/User1@org1.example.com/msp/config.yaml


