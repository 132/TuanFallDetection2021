docker-compose -f ./ca-docker/docker-compose-ca-tls-order.yaml up -d

export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/tls-ca/tls-cert.pem
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/tls-ca/admin/
../bin/fabric-ca-client enroll -d -u https://tls-ca-admin:tls-ca-adminpw@192.168.1.115:7052 --tls.certfiles ${PWD}/organizations/fabric-ca/tls-ca/tls-cert.pem

sleep 5

../bin/fabric-ca-client register -d --id.name orderer0 --id.secret ordererPW --id.type orderer -u https://192.168.1.115:7052 --tls.certfiles ${PWD}/organizations/fabric-ca/tls-ca/tls-cert.pem
../bin/fabric-ca-client register -d --id.name orderer1 --id.secret ordererPW --id.type orderer -u https://192.168.1.115:7052 --tls.certfiles ${PWD}/organizations/fabric-ca/tls-ca/tls-cert.pem
../bin/fabric-ca-client register -d --id.name orderer2 --id.secret ordererPW --id.type orderer -u https://192.168.1.115:7052 --tls.certfiles ${PWD}/organizations/fabric-ca/tls-ca/tls-cert.pem

# "Working on RCA-ORG0"
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org0/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/org0/ca/admin/
../bin/fabric-ca-client enroll -d -u https://rca-org0-admin:rca-org0-adminpw@192.168.1.115:7054

sleep 5

../bin/fabric-ca-client register -d --id.name orderer0 --id.secret ordererpw --id.type orderer -u https://192.168.1.115:7054
../bin/fabric-ca-client register -d --id.name orderer1 --id.secret ordererpw --id.type orderer -u https://192.168.1.115:7054
../bin/fabric-ca-client register -d --id.name orderer2 --id.secret ordererpw --id.type orderer -u https://192.168.1.115:7054

../bin/fabric-ca-client register -d --id.name admin-org0 --id.secret org0adminpw --id.type admin --id.attrs "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert" -u https://192.168.1.115:7054

# "Enroll Orderer 0"
    # preparation
mkdir -p ${PWD}/organizations/fabric-ca/org0/orderer0/assets/ca
cp ${PWD}/organizations/fabric-ca/org0/ca/admin/msp/cacerts/192-168-1-115-7054.pem ${PWD}/organizations/fabric-ca/org0/orderer0/assets/ca/org0-ca-cert.pem

mkdir -p ${PWD}/organizations/fabric-ca/org0/orderer0/assets/tls-ca
cp ${PWD}/organizations/fabric-ca/tls-ca/admin/msp/cacerts/192-168-1-115-7052.pem ${PWD}/organizations/fabric-ca/org0/orderer0/assets/tls-ca/tls-ca-cert.pem

    # enroll identity
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/org0/orderer0
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org0/orderer0/assets/ca/org0-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

../bin/fabric-ca-client enroll -d -u https://orderer0:ordererpw@192.168.1.115:7054

    # enroll TLS
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org0/orderer0/assets/tls-ca/tls-ca-cert.pem

../bin/fabric-ca-client enroll -d -u https://orderer0:ordererPW@192.168.1.115:7052 --enrollment.profile tls --csr.hosts orderer0.example.com --csr.hosts 192.1668.1.115

sleep 5

cp ${PWD}/organizations/fabric-ca/org0/orderer0/tls-msp/keystore/*_sk ${PWD}/organizations/fabric-ca/org0/orderer0/tls-msp/keystore/key.pem

cp ${PWD}/organizations/fabric-ca/org0/orderer0/tls-msp/tlscacerts/* ${PWD}/organizations/fabric-ca/org0/orderer0/tls-msp/ca.crt
cp ${PWD}/organizations/fabric-ca/org0/orderer0/tls-msp/signcerts/* ${PWD}/organizations/fabric-ca/org0/orderer0/tls-msp/server.crt
cp ${PWD}/organizations/fabric-ca/org0/orderer0/tls-msp/keystore/*_sk ${PWD}/organizations/fabric-ca/org0/orderer0/tls-msp/server.key

# "Enroll Admin"
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/org0/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=${PWD}/organizations/fabric-ca/org0/orderer0/assets/ca/org0-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

../bin/fabric-ca-client enroll -d -u https://admin-org0:org0adminpw@192.168.1.115:7054

sleep 5

mkdir -p ${PWD}/organizations/fabric-ca/org0/orderer0/msp/admincerts
cp ${PWD}/organizations/fabric-ca/org0/admin/msp/signcerts/cert.pem ${PWD}/organizations/fabric-ca/org0/orderer0/msp/admincerts/orderer-admin-cert.pem

mkdir -p ${PWD}/organizations/fabric-ca/org0/msp/{admincerts,cacerts,tlscacerts,users}
cp ${PWD}/organizations/fabric-ca/org0/orderer0/assets/ca/org0-ca-cert.pem ${PWD}/organizations/fabric-ca/org0/msp/cacerts/
cp ${PWD}/organizations/fabric-ca/org0/orderer0/assets/tls-ca/tls-ca-cert.pem ${PWD}/organizations/fabric-ca/org0/msp/tlscacerts/
cp ${PWD}/organizations/fabric-ca/org0/admin/msp/signcerts/cert.pem ${PWD}/organizations/fabric-ca/org0/msp/admincerts/admin-org0-cert.pem
cp ./org0-config.yaml ${PWD}/organizations/fabric-ca/org0/msp/config.yaml
