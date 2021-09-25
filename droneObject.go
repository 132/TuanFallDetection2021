package main

import (
	"encoding/json"
	"fmt"
	//"log"
	// "strconv"
	//"encoding/base64"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	//"github.com/hyperledger/fabric/protos/peer"
)

// SmartContract provides functions for managing a car
type SmartContract struct {
	contractapi.Contract
}

// Define the car structure, with 4 properties.  Structure tags are used by encoding/json library
type droneObject struct {
 	//ID [32]byte `json:"ID"`
 	ID string `json:"ID"`
	//Name string `json:"name"`
	//Localtion map[string]interface{} `json:"infoTicket"`
	Localtion int `json:"location"`
	InMission int `json:mission`
	/*
	 * int : 1 in a mission
	 * 	     0 not in mission
	 */

	SmallDrone map[string]string `json:smallDrone`
	/*
	 * string : smallDroneID 
	 * string : base64 Img
	 */

	LocationRecuerTeam map[string]int `json:locationRecuerTeam`
	// /*
	//  * string : smallDroneID 
	//  * int : location
	//  */
}

// InitLedger adds a base set of drones to the ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {

	// smallDrones
	smallDrones_ := map[string]string {"0":"abc"}
	LocationRecuerTeam_ := map[string]int {"0":1}

	// Instance Ticket
	droneObject := droneObject{ID: "0", Localtion: 10, InMission: 1, SmallDrone: smallDrones_, LocationRecuerTeam: LocationRecuerTeam_}
	//ticket := Ticket{ID: "0", Passenger: "Tri", InfoTicket: jsonData}

	droneObjectAsBytes, _ := json.Marshal(droneObject)

	err := ctx.GetStub().PutState("0", droneObjectAsBytes)

	if err != nil {
			return fmt.Errorf("Failed to put to world state. %s", err.Error())
		}

	return nil
}

// CreateCar adds a new drone to the world state with given details
func (s *SmartContract) CreateDrone(ctx contractapi.TransactionContextInterface, ID string, locationDrone int, listSmallDrone map[string]string, listHospital map[string]int) error {

	// sample Drone
	sampleDrone := droneObject{ID: ID, Localtion: locationDrone, InMission: 0, SmallDrone: listSmallDrone, LocationRecuerTeam: listHospital}

	// prepate to put to state
	droneAsBytes, _ := json.Marshal(sampleDrone)
	return ctx.GetStub().PutState(ID, droneAsBytes)
}

// QueryCar returns the drone stored in the world state with given id
func (s *SmartContract) QueryDrone(ctx contractapi.TransactionContextInterface, ID string) (*droneObject, error) {

	droneAsBytes, err := ctx.GetStub().GetState(ID)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if droneAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", ID)
	}

	droneSample := new(droneObject)
	_ = json.Unmarshal(droneAsBytes, droneSample)

	return droneSample, nil
}

// Contact Rescuer returns the drone stored in the world state with given id
func (s *SmartContract) AddRescuer(ctx contractapi.TransactionContextInterface, droneID string, rescueTeamID string, location int) error {

	drone_, err := s.QueryDrone(ctx, droneID)

	if err != nil {
		return err
	}

	drone_.LocationRecuerTeam[rescueTeamID] = location

	droneAsBytes, _ := json.Marshal(drone_)
	
	return ctx.GetStub().PutState(droneID, droneAsBytes)
}

// process data 
// func (s *SmartContract) UpdateInfo(ctx contractapi.TransactionContextInterface, droneID string, smallDroneID string, location int) string {
// 	drone_, _ := s.QueryDrone(ctx, droneID)

// 	// if err != nil {
// 	// 	return err
// 	// }

// 	drone_.location = location

// 	min := 250
// 	var temp string

// 	for key, value := range drone_.LocationRecuerTeam {
		
// 		if (value - location) < (min - location) {
// 			min = value
// 			temp = key
// 		}
// 	}
// 	return temp
// }

func (s *SmartContract) AddImg(ctx contractapi.TransactionContextInterface, droneID string, smallDroneID string, base64Img string) error {
	drone_, err := s.QueryDrone(ctx, droneID)
	if err != nil {
		return err
	}

	drone_.SmallDrone[smallDroneID] = base64Img

	droneAsBytes, _ := json.Marshal(drone_)
	
	return ctx.GetStub().PutState(droneID, droneAsBytes)
}

// Contact Rescuer returns the drone stored in the world state with given id
// func (s *SmartContract) ContactRescuer(ctx contractapi.TransactionContextInterface, ID string) (*droneObject, error) {

// 	params := []string{"DecreaseBalance", location}

// 	parameterBytes := make([][]byte, len(params))
// 	for i, arg := range params {
// 		parameterBytes[i] = []byte(arg)
// 	}

// 	ctx.GetStub().InvokeChaincode("travelerMaaS10", parameterBytes, "channel12")
// }

func (s *SmartContract) ContactRescuer(ctx contractapi.TransactionContextInterface) error {

	request := "blood"

	params := []string{"ContactHospital", "0", request}

	parameterBytes := make([][]byte, len(params))
	for i, arg := range params {
		parameterBytes[i] = []byte(arg)
	}

	ctx.GetStub().InvokeChaincode("droneRescue2", parameterBytes, "channel1")

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

// /*
//  * 	function  analyzeJSON
//  * 	@Description recursive function for read/analyze JSON
//  * 	@Parameters map[int]int 						sampleMapVerify
//  * 	@Parameters map[string]interface{} 	jsonDATA
//  * 	@Return    	void
// */
// func analyzeJSON(sampleMapVerify map[string]int, jsonData map[string]interface{}) (){
// 	// create an array definie transportation requires verify
// 	requireVerify := [2]string{"BUS","TRAIN"}

// 	for k, v := range jsonData {

// 				switch v := v.(type) {
// 				case string:
// 						if k == "mode" {
// 							for _, meansTransport := range requireVerify {
// 								if v == meansTransport{
// 									i := len(sampleMapVerify) + 1
// 									sampleMapVerify[strconv.Itoa(i)] = 1
// 									break
// 								}
// 							}
// 							if v == "WALK"	{
// 								i := len(sampleMapVerify) + 1
// 								sampleMapVerify[strconv.Itoa(i)] = -1
// 							}
// 						}

// 				case float64:
// 				case map[string]interface{}:
// 						analyzeJSON(sampleMapVerify, v)

// 				case []interface{}:
// 						 for _, ival := range v {
// 								 switch ival := ival.(type) {
// 									case map[string]interface{}:
// 											analyzeJSON(sampleMapVerify, ival)
// 							 }
// 						 }
// 				default:
// 				}
// 		}
// }

// func (s *SmartContract) AskPolice (ctx contractapi.TransactionContextInterface, policeID string) (){
// 	params := []string{"BorderSchengenCheck", , }

// 	parameterBytes := make([][]byte, len(params))
// 	for i, arg := range params {
// 		parameterBytes[i] = []byte(arg)
// 	}

// 	ctx.GetStub().InvokeChaincode("policeMaaS", parameterBytes, "channel12")
// }

// func (s *SmartContract) VerifyTicket (ctx contractapi.TransactionContextInterface, ticketID string, verifierID string) error {
// 	ticket_, err := s.QueryTicket(ctx, ticketID)

// 	if err != nil {
// 		return err
// 	}

// 	ticket_.MapVerify[verifierID] = 0

// 	// prepate to put to state
// 	ticketAsBytes, _ := json.Marshal(ticket_)

// 	return ctx.GetStub().PutState(ticketID, ticketAsBytes)
// }


// func (s *SmartContract) WithInsurance (ctx contractapi.TransactionContextInterface, issue string) () {
// 	switch issue {
// 	case "cancel":
// 		params := []string{"ClaimInsurance", insuranceID, amountTicket}

// 		parameterBytes := make([][]byte, len(params))
// 		for i, arg := range params {
// 			parameterBytes[i] = []byte(arg)
// 		}

// 		ctx.GetStub().InvokeChaincode("insuranceMaaS", parameterBytes, "channel12")

// 	case "delay":

// 	default:
// 	}
// }