package main

import (
	"encoding/json"
	"fmt"
	//"log"
	//"strconv"
	//"encoding/base64"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	//"github.com/hyperledger/fabric/protos/peer"
)

// SmartContract provides functions for managing a car
type SmartContract struct {
	contractapi.Contract
}

// Define the car structure, with 4 properties.  Structure tags are used by encoding/json library
type Hospital struct {
 	//ID [32]byte `json:"ID"`
 	ID string `json:"ID"`
	//Name string `json:"name"`
	//Localtion map[string]interface{} `json:"infoTicket"`
	Location int `json:"location"`
	Accommodation int `json:accommodation`
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
	Request map[string]string `json:request`
}

// InitLedger adds a base set of hospital to the ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {

	specialist_ := map[string]int{"a":1, "b":0, "c":1}
	requestList := map[string]string{"None": "None"}

	// Instance hospital
	hospital_ := Hospital{ID: "0", Location: 1, Accommodation: 1, Specialist: specialist_, Request: requestList}
	

	hospitalAsBytes, _ := json.Marshal(hospital_)
	err := ctx.GetStub().PutState("0", hospitalAsBytes)
	if err != nil {
			return fmt.Errorf("Failed to put to world state. %s", err.Error())
		}
	return nil
}

// Createhospital adds a new hospital to the world state with given details
func (s *SmartContract) CreateHospital(ctx contractapi.TransactionContextInterface, ID string, location_ int, accommodation_ int) error {

	// mapVerify field
	//sampleMapVerify := createMapVerify(jsonData)
	specialist_ := map[string]int{"a":1, "b":0, "c":1}
	requestList := map[string]string{"None": "None"}

	// sample Ticket
	sampleHospital := Hospital{ID: ID, Location: location_, Accommodation: accommodation_, Specialist: specialist_, Request: requestList}

	// prepate to put to state
	hospitalAsBytes, _ := json.Marshal(sampleHospital)

	return ctx.GetStub().PutState(ID, hospitalAsBytes)
}

// QueryCar returns the ticket stored in the world state with given id
func (s *SmartContract) QueryHospital(ctx contractapi.TransactionContextInterface, ID string) (*Hospital, error) {

	hospitalAsBytes, err := ctx.GetStub().GetState(ID)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if hospitalAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", ID)
	}

	hospital_ := new(Hospital)
	_ = json.Unmarshal(hospitalAsBytes, hospital_)

	return hospital_, nil
}

// Contact Rescuer returns the drone stored in the world state with given id
func (s *SmartContract) RequestHospital(ctx contractapi.TransactionContextInterface, rescuerID string, request string) error {

	//request := "blood"

	hospital_, err := s.QueryHospital(ctx, "0")

	if err != nil {
		return err
	}

	hospital_.Request[rescuerID] = request

	hospitalAsBytes, _ := json.Marshal(hospital_)
	
	return ctx.GetStub().PutState(rescuerID, hospitalAsBytes)
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
