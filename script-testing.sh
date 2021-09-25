#!/bin/bash
for i in {1..10}

do
	peer chaincode query -C channel1 -n TuanDrone2 -c '{"function":"QueryDrone","Args":["0"]}'
done