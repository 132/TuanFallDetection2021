package main

import (
	"encoding/json"
	"fmt"
	//"log"
	"strconv"
	//"encoding/base64"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	//"github.com/hyperledger/fabric/protos/peer"
)

// SmartContract provides functions for managing a car
type SmartContract struct {
	contractapi.Contract
}

// Define the Rescuer structure, with 4 properties.  Structure tags are used by encoding/json library
type rescueTeam struct {

 	ID string `json:"ID"`
	//Localtion map[string]interface{} `json:"infoTicket"`
	Location int `json:"location"`
	InMission int `json:mission`
	/*
	 * int : 1 in a mission
	 * 	     0 not in mission
	 */

	Specialist map[string]int `json:specialist`
	/*
	 * string : specialistType/Name 
	 * int 	: 1 available
	 *		  0 not available
	 */
	Hostpitallist map[string]int `json:hospital`
	/*
	* ID vs location
	*/
}

// InitLedger adds a base set of Rescuer to the ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {

	// MapVerify
	sampleSpecialist := map[string]int{"ABC": 1, "b":0}
	sampleHospital := map[string]int{"0":1}

	// Instance Ticket
	rescueTeam_ := rescueTeam{ID: "0", Location: 1, InMission: 1, Specialist: sampleSpecialist, Hostpitallist:sampleHospital}

	rescueTeamAsBytes, _ := json.Marshal(rescueTeam_)
	err := ctx.GetStub().PutState("0", rescueTeamAsBytes)

	if err != nil {
			return fmt.Errorf("Failed to put to world state. %s", err.Error())
		}
	return nil
}

// CreateRescuer adds a new Rescuer to the world state with given details
func (s *SmartContract) CreateRescuer(ctx contractapi.TransactionContextInterface, ID string, location_ int	) error {

	sampleSpecialist := map[string]int{"ABC": 1, "b":0}
	sampleHospital := map[string]int{"0":1}
	mission_ := 1

	// sample Rescuer
	sampleTeam := rescueTeam{ID: ID, Location: location_, InMission: mission_, Specialist: sampleSpecialist, Hostpitallist:sampleHospital}

	// prepate to put to state
	teamAsBytes, _ := json.Marshal(sampleTeam)

	// add info to the 
	locationSample := strconv.Itoa(location_)
	params := []string{"AddRescuer", "0", ID, locationSample}

	parameterBytes := make([][]byte, len(params))
	for i, arg := range params {
		parameterBytes[i] = []byte(arg)
	}
	ctx.GetStub().InvokeChaincode("TuanDrone3", parameterBytes, "channel1")

	return ctx.GetStub().PutState(ID, teamAsBytes)
}

// QueryRescuer returns the Rescuer stored in the world state with given id
func (s *SmartContract) QueryRescuer(ctx contractapi.TransactionContextInterface, ID string) (*rescueTeam, error) {

	teamAsBytes, err := ctx.GetStub().GetState(ID)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if teamAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", ID)
	}

	sampleTeam := new(rescueTeam)
	_ = json.Unmarshal(teamAsBytes, sampleTeam)

	return sampleTeam, nil
}

// Contact Rescuer returns the drone stored in the world state with given id
func (s *SmartContract) ContactHospital(ctx contractapi.TransactionContextInterface) error {

	request := "blood"

	params := []string{"RequestHospital", "0", request}

	parameterBytes := make([][]byte, len(params))
	for i, arg := range params {
		parameterBytes[i] = []byte(arg)
	}

	ctx.GetStub().InvokeChaincode("TuanHospital2", parameterBytes, "channel1")

	return nil
}

func main() {

	chaincode, err := contractapi.NewChaincode(new(SmartContract))

	if err != nil {
		fmt.Printf("Error create fabcar chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting fabcar chaincode: %s", err.Error())
	}
}
