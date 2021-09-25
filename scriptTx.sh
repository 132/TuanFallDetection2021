
#mkdir channel-artifacts
../bin/configtxgen -profile SampleMultiNodeEtcdRaft -channelID system-channel -outputBlock ./channel-artifacts/genesis.block

../bin/configtxgen -profile ChannelAll -outputCreateChannelTx ./channel-artifacts/channelall.tx -channelID channelall

../bin/configtxgen -profile Channel12 -outputCreateChannelTx ./channel-artifacts/channel12.tx -channelID channel12

../bin/configtxgen -profile Channel3 -outputCreateChannelTx ./channel-artifacts/channel3.tx -channelID channel3

# need anchor peer for later use
../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID channel12 -asOrg Org1MSP
../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID channel12 -asOrg Org2MSP
../bin/configtxgen -profile OneOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors.tx -channelID channel3 -asOrg Org3MSP
