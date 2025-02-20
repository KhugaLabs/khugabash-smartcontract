package service

import (
	"encoding/hex"
	"fmt"
	"khugabash/backend"
	"math/big"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
	"golang.org/x/exp/rand"
)

type SmartContractService interface {
	SignRegister(address string) (string, uint, error)
}

type SmartContract struct {
	KhugaBash *backend.KhugaBash
}

func NewSmartContractService(khugaBash *backend.KhugaBash) SmartContractService {
	return &SmartContract{
		KhugaBash: khugaBash,
	}
}

func (s *SmartContract) SignRegister(address string) (string, uint, error) {
	nonce := rand.Uint32() % 100
	playerAddress := common.HexToAddress(address)

	privateKey, err := crypto.HexToECDSA("1124360643ae21e1a5c1e6ce58512df686abf1139944bccc97b34627ef3445c0")
	if err != nil {
		return "", 0, err
	}

	// Create the typed data hash structure
	typeHash := []byte("EIP712Domain(string name,string version)")
	nameHash := crypto.Keccak256([]byte("KhugaBash"))
	versionHash := crypto.Keccak256([]byte("1"))

	// Create domain separator
	domainSeparator := crypto.Keccak256(
		append(
			typeHash,
			append(
				nameHash,
				versionHash...,
			)...,
		),
	)

	// Create the message hash
	messageHash := crypto.Keccak256(
		append(
			playerAddress.Bytes(),
			common.LeftPadBytes(big.NewInt(int64(nonce)).Bytes(), 32)...,
		),
	)

	// Create the final digest
	digest := crypto.Keccak256(
		append(
			[]byte("\x19\x01"),
			append(
				domainSeparator,
				messageHash...,
			)...,
		),
	)

	// Sign the digest
	signature, err := crypto.Sign(digest, privateKey)
	if err != nil {
		return "", 0, fmt.Errorf("failed to sign message: %v", err)
	}

	// Adjust v value for Ethereum compatibility
	signature[64] += 27

	// Convert signature to hex string with 0x prefix
	signatureHex := "0x" + hex.EncodeToString(signature)

	return signatureHex, uint(nonce), nil
}
