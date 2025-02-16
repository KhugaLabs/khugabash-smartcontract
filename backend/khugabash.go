// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package backend

import (
	"errors"
	"math/big"
	"strings"

	ethereum "github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/event"
)

// Reference imports to suppress errors if they are not otherwise used.
var (
	_ = errors.New
	_ = big.NewInt
	_ = strings.NewReader
	_ = ethereum.NotFound
	_ = bind.Bind
	_ = common.Big1
	_ = types.BloomLookup
	_ = event.NewSubscription
	_ = abi.ConvertType
)

// KhugaBashLeaderboardEntry is an auto generated low-level Go binding around an user-defined struct.
type KhugaBashLeaderboardEntry struct {
	Player common.Address
	Score  *big.Int
}

// KhugaBashPlayer is an auto generated low-level Go binding around an user-defined struct.
type KhugaBashPlayer struct {
	Score        *big.Int
	IsRegistered bool
}

// KhugaBashMetaData contains all meta data concerning the KhugaBash contract.
var KhugaBashMetaData = &bind.MetaData{
	ABI: "[{\"type\":\"constructor\",\"inputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"awardScore\",\"inputs\":[{\"name\":\"player\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"multiplier\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"backendSigner\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"cancelOwnershipHandover\",\"inputs\":[],\"outputs\":[],\"stateMutability\":\"payable\"},{\"type\":\"function\",\"name\":\"completeOwnershipHandover\",\"inputs\":[{\"name\":\"pendingOwner\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[],\"stateMutability\":\"payable\"},{\"type\":\"function\",\"name\":\"getPlayerStats\",\"inputs\":[{\"name\":\"player\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[{\"name\":\"\",\"type\":\"tuple\",\"internalType\":\"structKhugaBash.Player\",\"components\":[{\"name\":\"score\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"isRegistered\",\"type\":\"bool\",\"internalType\":\"bool\"}]}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"getTopPlayers\",\"inputs\":[{\"name\":\"limit\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[{\"name\":\"\",\"type\":\"tuple[]\",\"internalType\":\"structKhugaBash.LeaderboardEntry[]\",\"components\":[{\"name\":\"player\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"score\",\"type\":\"uint256\",\"internalType\":\"uint256\"}]}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"initialize\",\"inputs\":[],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"owner\",\"inputs\":[],\"outputs\":[{\"name\":\"result\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"ownershipHandoverExpiresAt\",\"inputs\":[{\"name\":\"pendingOwner\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[{\"name\":\"result\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"proxiableUUID\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"registerPlayer\",\"inputs\":[{\"name\":\"nonce\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"renounceOwnership\",\"inputs\":[],\"outputs\":[],\"stateMutability\":\"payable\"},{\"type\":\"function\",\"name\":\"requestOwnershipHandover\",\"inputs\":[],\"outputs\":[],\"stateMutability\":\"payable\"},{\"type\":\"function\",\"name\":\"setBackendSigner\",\"inputs\":[{\"name\":\"_backendSigner\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"setPlayerNonce\",\"inputs\":[{\"name\":\"player\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"nonce\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"transferOwnership\",\"inputs\":[{\"name\":\"newOwner\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[],\"stateMutability\":\"payable\"},{\"type\":\"function\",\"name\":\"updateScore\",\"inputs\":[{\"name\":\"score\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"nonce\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"signature\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"upgradeToAndCall\",\"inputs\":[{\"name\":\"newImplementation\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"data\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"payable\"},{\"type\":\"event\",\"name\":\"Initialized\",\"inputs\":[{\"name\":\"version\",\"type\":\"uint64\",\"indexed\":false,\"internalType\":\"uint64\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"LeaderboardUpdated\",\"inputs\":[{\"name\":\"player\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"score\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"OwnershipHandoverCanceled\",\"inputs\":[{\"name\":\"pendingOwner\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"OwnershipHandoverRequested\",\"inputs\":[{\"name\":\"pendingOwner\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"OwnershipTransferred\",\"inputs\":[{\"name\":\"oldOwner\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"newOwner\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"PlayerRegistered\",\"inputs\":[{\"name\":\"player\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"Upgraded\",\"inputs\":[{\"name\":\"implementation\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"scoreEarned\",\"inputs\":[{\"name\":\"player\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"score\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"scoreUpdated\",\"inputs\":[{\"name\":\"score\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"nonce\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"signature\",\"type\":\"bytes\",\"indexed\":false,\"internalType\":\"bytes\"}],\"anonymous\":false},{\"type\":\"error\",\"name\":\"AlreadyInitialized\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"InvalidInitialization\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"NewOwnerIsZeroAddress\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"NoHandoverRequest\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"NotInitializing\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"Reentrancy\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"Unauthorized\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"UnauthorizedCallContext\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"UpgradeFailed\",\"inputs\":[]}]",
}

// KhugaBashABI is the input ABI used to generate the binding from.
// Deprecated: Use KhugaBashMetaData.ABI instead.
var KhugaBashABI = KhugaBashMetaData.ABI

// KhugaBash is an auto generated Go binding around an Ethereum contract.
type KhugaBash struct {
	KhugaBashCaller     // Read-only binding to the contract
	KhugaBashTransactor // Write-only binding to the contract
	KhugaBashFilterer   // Log filterer for contract events
}

// KhugaBashCaller is an auto generated read-only Go binding around an Ethereum contract.
type KhugaBashCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// KhugaBashTransactor is an auto generated write-only Go binding around an Ethereum contract.
type KhugaBashTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// KhugaBashFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type KhugaBashFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// KhugaBashSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type KhugaBashSession struct {
	Contract     *KhugaBash        // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// KhugaBashCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type KhugaBashCallerSession struct {
	Contract *KhugaBashCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts    // Call options to use throughout this session
}

// KhugaBashTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type KhugaBashTransactorSession struct {
	Contract     *KhugaBashTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts    // Transaction auth options to use throughout this session
}

// KhugaBashRaw is an auto generated low-level Go binding around an Ethereum contract.
type KhugaBashRaw struct {
	Contract *KhugaBash // Generic contract binding to access the raw methods on
}

// KhugaBashCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type KhugaBashCallerRaw struct {
	Contract *KhugaBashCaller // Generic read-only contract binding to access the raw methods on
}

// KhugaBashTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type KhugaBashTransactorRaw struct {
	Contract *KhugaBashTransactor // Generic write-only contract binding to access the raw methods on
}

// NewKhugaBash creates a new instance of KhugaBash, bound to a specific deployed contract.
func NewKhugaBash(address common.Address, backend bind.ContractBackend) (*KhugaBash, error) {
	contract, err := bindKhugaBash(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &KhugaBash{KhugaBashCaller: KhugaBashCaller{contract: contract}, KhugaBashTransactor: KhugaBashTransactor{contract: contract}, KhugaBashFilterer: KhugaBashFilterer{contract: contract}}, nil
}

// NewKhugaBashCaller creates a new read-only instance of KhugaBash, bound to a specific deployed contract.
func NewKhugaBashCaller(address common.Address, caller bind.ContractCaller) (*KhugaBashCaller, error) {
	contract, err := bindKhugaBash(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &KhugaBashCaller{contract: contract}, nil
}

// NewKhugaBashTransactor creates a new write-only instance of KhugaBash, bound to a specific deployed contract.
func NewKhugaBashTransactor(address common.Address, transactor bind.ContractTransactor) (*KhugaBashTransactor, error) {
	contract, err := bindKhugaBash(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &KhugaBashTransactor{contract: contract}, nil
}

// NewKhugaBashFilterer creates a new log filterer instance of KhugaBash, bound to a specific deployed contract.
func NewKhugaBashFilterer(address common.Address, filterer bind.ContractFilterer) (*KhugaBashFilterer, error) {
	contract, err := bindKhugaBash(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &KhugaBashFilterer{contract: contract}, nil
}

// bindKhugaBash binds a generic wrapper to an already deployed contract.
func bindKhugaBash(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := KhugaBashMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_KhugaBash *KhugaBashRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _KhugaBash.Contract.KhugaBashCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_KhugaBash *KhugaBashRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _KhugaBash.Contract.KhugaBashTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_KhugaBash *KhugaBashRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _KhugaBash.Contract.KhugaBashTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_KhugaBash *KhugaBashCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _KhugaBash.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_KhugaBash *KhugaBashTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _KhugaBash.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_KhugaBash *KhugaBashTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _KhugaBash.Contract.contract.Transact(opts, method, params...)
}

// BackendSigner is a free data retrieval call binding the contract method 0x65d65e86.
//
// Solidity: function backendSigner() view returns(address)
func (_KhugaBash *KhugaBashCaller) BackendSigner(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _KhugaBash.contract.Call(opts, &out, "backendSigner")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// BackendSigner is a free data retrieval call binding the contract method 0x65d65e86.
//
// Solidity: function backendSigner() view returns(address)
func (_KhugaBash *KhugaBashSession) BackendSigner() (common.Address, error) {
	return _KhugaBash.Contract.BackendSigner(&_KhugaBash.CallOpts)
}

// BackendSigner is a free data retrieval call binding the contract method 0x65d65e86.
//
// Solidity: function backendSigner() view returns(address)
func (_KhugaBash *KhugaBashCallerSession) BackendSigner() (common.Address, error) {
	return _KhugaBash.Contract.BackendSigner(&_KhugaBash.CallOpts)
}

// GetPlayerStats is a free data retrieval call binding the contract method 0x4fd66eae.
//
// Solidity: function getPlayerStats(address player) view returns((uint256,bool))
func (_KhugaBash *KhugaBashCaller) GetPlayerStats(opts *bind.CallOpts, player common.Address) (KhugaBashPlayer, error) {
	var out []interface{}
	err := _KhugaBash.contract.Call(opts, &out, "getPlayerStats", player)

	if err != nil {
		return *new(KhugaBashPlayer), err
	}

	out0 := *abi.ConvertType(out[0], new(KhugaBashPlayer)).(*KhugaBashPlayer)

	return out0, err

}

// GetPlayerStats is a free data retrieval call binding the contract method 0x4fd66eae.
//
// Solidity: function getPlayerStats(address player) view returns((uint256,bool))
func (_KhugaBash *KhugaBashSession) GetPlayerStats(player common.Address) (KhugaBashPlayer, error) {
	return _KhugaBash.Contract.GetPlayerStats(&_KhugaBash.CallOpts, player)
}

// GetPlayerStats is a free data retrieval call binding the contract method 0x4fd66eae.
//
// Solidity: function getPlayerStats(address player) view returns((uint256,bool))
func (_KhugaBash *KhugaBashCallerSession) GetPlayerStats(player common.Address) (KhugaBashPlayer, error) {
	return _KhugaBash.Contract.GetPlayerStats(&_KhugaBash.CallOpts, player)
}

// GetTopPlayers is a free data retrieval call binding the contract method 0xba3c0067.
//
// Solidity: function getTopPlayers(uint256 limit) view returns((address,uint256)[])
func (_KhugaBash *KhugaBashCaller) GetTopPlayers(opts *bind.CallOpts, limit *big.Int) ([]KhugaBashLeaderboardEntry, error) {
	var out []interface{}
	err := _KhugaBash.contract.Call(opts, &out, "getTopPlayers", limit)

	if err != nil {
		return *new([]KhugaBashLeaderboardEntry), err
	}

	out0 := *abi.ConvertType(out[0], new([]KhugaBashLeaderboardEntry)).(*[]KhugaBashLeaderboardEntry)

	return out0, err

}

// GetTopPlayers is a free data retrieval call binding the contract method 0xba3c0067.
//
// Solidity: function getTopPlayers(uint256 limit) view returns((address,uint256)[])
func (_KhugaBash *KhugaBashSession) GetTopPlayers(limit *big.Int) ([]KhugaBashLeaderboardEntry, error) {
	return _KhugaBash.Contract.GetTopPlayers(&_KhugaBash.CallOpts, limit)
}

// GetTopPlayers is a free data retrieval call binding the contract method 0xba3c0067.
//
// Solidity: function getTopPlayers(uint256 limit) view returns((address,uint256)[])
func (_KhugaBash *KhugaBashCallerSession) GetTopPlayers(limit *big.Int) ([]KhugaBashLeaderboardEntry, error) {
	return _KhugaBash.Contract.GetTopPlayers(&_KhugaBash.CallOpts, limit)
}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address result)
func (_KhugaBash *KhugaBashCaller) Owner(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _KhugaBash.contract.Call(opts, &out, "owner")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address result)
func (_KhugaBash *KhugaBashSession) Owner() (common.Address, error) {
	return _KhugaBash.Contract.Owner(&_KhugaBash.CallOpts)
}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address result)
func (_KhugaBash *KhugaBashCallerSession) Owner() (common.Address, error) {
	return _KhugaBash.Contract.Owner(&_KhugaBash.CallOpts)
}

// OwnershipHandoverExpiresAt is a free data retrieval call binding the contract method 0xfee81cf4.
//
// Solidity: function ownershipHandoverExpiresAt(address pendingOwner) view returns(uint256 result)
func (_KhugaBash *KhugaBashCaller) OwnershipHandoverExpiresAt(opts *bind.CallOpts, pendingOwner common.Address) (*big.Int, error) {
	var out []interface{}
	err := _KhugaBash.contract.Call(opts, &out, "ownershipHandoverExpiresAt", pendingOwner)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// OwnershipHandoverExpiresAt is a free data retrieval call binding the contract method 0xfee81cf4.
//
// Solidity: function ownershipHandoverExpiresAt(address pendingOwner) view returns(uint256 result)
func (_KhugaBash *KhugaBashSession) OwnershipHandoverExpiresAt(pendingOwner common.Address) (*big.Int, error) {
	return _KhugaBash.Contract.OwnershipHandoverExpiresAt(&_KhugaBash.CallOpts, pendingOwner)
}

// OwnershipHandoverExpiresAt is a free data retrieval call binding the contract method 0xfee81cf4.
//
// Solidity: function ownershipHandoverExpiresAt(address pendingOwner) view returns(uint256 result)
func (_KhugaBash *KhugaBashCallerSession) OwnershipHandoverExpiresAt(pendingOwner common.Address) (*big.Int, error) {
	return _KhugaBash.Contract.OwnershipHandoverExpiresAt(&_KhugaBash.CallOpts, pendingOwner)
}

// ProxiableUUID is a free data retrieval call binding the contract method 0x52d1902d.
//
// Solidity: function proxiableUUID() view returns(bytes32)
func (_KhugaBash *KhugaBashCaller) ProxiableUUID(opts *bind.CallOpts) ([32]byte, error) {
	var out []interface{}
	err := _KhugaBash.contract.Call(opts, &out, "proxiableUUID")

	if err != nil {
		return *new([32]byte), err
	}

	out0 := *abi.ConvertType(out[0], new([32]byte)).(*[32]byte)

	return out0, err

}

// ProxiableUUID is a free data retrieval call binding the contract method 0x52d1902d.
//
// Solidity: function proxiableUUID() view returns(bytes32)
func (_KhugaBash *KhugaBashSession) ProxiableUUID() ([32]byte, error) {
	return _KhugaBash.Contract.ProxiableUUID(&_KhugaBash.CallOpts)
}

// ProxiableUUID is a free data retrieval call binding the contract method 0x52d1902d.
//
// Solidity: function proxiableUUID() view returns(bytes32)
func (_KhugaBash *KhugaBashCallerSession) ProxiableUUID() ([32]byte, error) {
	return _KhugaBash.Contract.ProxiableUUID(&_KhugaBash.CallOpts)
}

// AwardScore is a paid mutator transaction binding the contract method 0x19d29beb.
//
// Solidity: function awardScore(address player, uint256 multiplier) returns()
func (_KhugaBash *KhugaBashTransactor) AwardScore(opts *bind.TransactOpts, player common.Address, multiplier *big.Int) (*types.Transaction, error) {
	return _KhugaBash.contract.Transact(opts, "awardScore", player, multiplier)
}

// AwardScore is a paid mutator transaction binding the contract method 0x19d29beb.
//
// Solidity: function awardScore(address player, uint256 multiplier) returns()
func (_KhugaBash *KhugaBashSession) AwardScore(player common.Address, multiplier *big.Int) (*types.Transaction, error) {
	return _KhugaBash.Contract.AwardScore(&_KhugaBash.TransactOpts, player, multiplier)
}

// AwardScore is a paid mutator transaction binding the contract method 0x19d29beb.
//
// Solidity: function awardScore(address player, uint256 multiplier) returns()
func (_KhugaBash *KhugaBashTransactorSession) AwardScore(player common.Address, multiplier *big.Int) (*types.Transaction, error) {
	return _KhugaBash.Contract.AwardScore(&_KhugaBash.TransactOpts, player, multiplier)
}

// CancelOwnershipHandover is a paid mutator transaction binding the contract method 0x54d1f13d.
//
// Solidity: function cancelOwnershipHandover() payable returns()
func (_KhugaBash *KhugaBashTransactor) CancelOwnershipHandover(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _KhugaBash.contract.Transact(opts, "cancelOwnershipHandover")
}

// CancelOwnershipHandover is a paid mutator transaction binding the contract method 0x54d1f13d.
//
// Solidity: function cancelOwnershipHandover() payable returns()
func (_KhugaBash *KhugaBashSession) CancelOwnershipHandover() (*types.Transaction, error) {
	return _KhugaBash.Contract.CancelOwnershipHandover(&_KhugaBash.TransactOpts)
}

// CancelOwnershipHandover is a paid mutator transaction binding the contract method 0x54d1f13d.
//
// Solidity: function cancelOwnershipHandover() payable returns()
func (_KhugaBash *KhugaBashTransactorSession) CancelOwnershipHandover() (*types.Transaction, error) {
	return _KhugaBash.Contract.CancelOwnershipHandover(&_KhugaBash.TransactOpts)
}

// CompleteOwnershipHandover is a paid mutator transaction binding the contract method 0xf04e283e.
//
// Solidity: function completeOwnershipHandover(address pendingOwner) payable returns()
func (_KhugaBash *KhugaBashTransactor) CompleteOwnershipHandover(opts *bind.TransactOpts, pendingOwner common.Address) (*types.Transaction, error) {
	return _KhugaBash.contract.Transact(opts, "completeOwnershipHandover", pendingOwner)
}

// CompleteOwnershipHandover is a paid mutator transaction binding the contract method 0xf04e283e.
//
// Solidity: function completeOwnershipHandover(address pendingOwner) payable returns()
func (_KhugaBash *KhugaBashSession) CompleteOwnershipHandover(pendingOwner common.Address) (*types.Transaction, error) {
	return _KhugaBash.Contract.CompleteOwnershipHandover(&_KhugaBash.TransactOpts, pendingOwner)
}

// CompleteOwnershipHandover is a paid mutator transaction binding the contract method 0xf04e283e.
//
// Solidity: function completeOwnershipHandover(address pendingOwner) payable returns()
func (_KhugaBash *KhugaBashTransactorSession) CompleteOwnershipHandover(pendingOwner common.Address) (*types.Transaction, error) {
	return _KhugaBash.Contract.CompleteOwnershipHandover(&_KhugaBash.TransactOpts, pendingOwner)
}

// Initialize is a paid mutator transaction binding the contract method 0x8129fc1c.
//
// Solidity: function initialize() returns()
func (_KhugaBash *KhugaBashTransactor) Initialize(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _KhugaBash.contract.Transact(opts, "initialize")
}

// Initialize is a paid mutator transaction binding the contract method 0x8129fc1c.
//
// Solidity: function initialize() returns()
func (_KhugaBash *KhugaBashSession) Initialize() (*types.Transaction, error) {
	return _KhugaBash.Contract.Initialize(&_KhugaBash.TransactOpts)
}

// Initialize is a paid mutator transaction binding the contract method 0x8129fc1c.
//
// Solidity: function initialize() returns()
func (_KhugaBash *KhugaBashTransactorSession) Initialize() (*types.Transaction, error) {
	return _KhugaBash.Contract.Initialize(&_KhugaBash.TransactOpts)
}

// RegisterPlayer is a paid mutator transaction binding the contract method 0x821644e6.
//
// Solidity: function registerPlayer(uint256 nonce) returns()
func (_KhugaBash *KhugaBashTransactor) RegisterPlayer(opts *bind.TransactOpts, nonce *big.Int) (*types.Transaction, error) {
	return _KhugaBash.contract.Transact(opts, "registerPlayer", nonce)
}

// RegisterPlayer is a paid mutator transaction binding the contract method 0x821644e6.
//
// Solidity: function registerPlayer(uint256 nonce) returns()
func (_KhugaBash *KhugaBashSession) RegisterPlayer(nonce *big.Int) (*types.Transaction, error) {
	return _KhugaBash.Contract.RegisterPlayer(&_KhugaBash.TransactOpts, nonce)
}

// RegisterPlayer is a paid mutator transaction binding the contract method 0x821644e6.
//
// Solidity: function registerPlayer(uint256 nonce) returns()
func (_KhugaBash *KhugaBashTransactorSession) RegisterPlayer(nonce *big.Int) (*types.Transaction, error) {
	return _KhugaBash.Contract.RegisterPlayer(&_KhugaBash.TransactOpts, nonce)
}

// RenounceOwnership is a paid mutator transaction binding the contract method 0x715018a6.
//
// Solidity: function renounceOwnership() payable returns()
func (_KhugaBash *KhugaBashTransactor) RenounceOwnership(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _KhugaBash.contract.Transact(opts, "renounceOwnership")
}

// RenounceOwnership is a paid mutator transaction binding the contract method 0x715018a6.
//
// Solidity: function renounceOwnership() payable returns()
func (_KhugaBash *KhugaBashSession) RenounceOwnership() (*types.Transaction, error) {
	return _KhugaBash.Contract.RenounceOwnership(&_KhugaBash.TransactOpts)
}

// RenounceOwnership is a paid mutator transaction binding the contract method 0x715018a6.
//
// Solidity: function renounceOwnership() payable returns()
func (_KhugaBash *KhugaBashTransactorSession) RenounceOwnership() (*types.Transaction, error) {
	return _KhugaBash.Contract.RenounceOwnership(&_KhugaBash.TransactOpts)
}

// RequestOwnershipHandover is a paid mutator transaction binding the contract method 0x25692962.
//
// Solidity: function requestOwnershipHandover() payable returns()
func (_KhugaBash *KhugaBashTransactor) RequestOwnershipHandover(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _KhugaBash.contract.Transact(opts, "requestOwnershipHandover")
}

// RequestOwnershipHandover is a paid mutator transaction binding the contract method 0x25692962.
//
// Solidity: function requestOwnershipHandover() payable returns()
func (_KhugaBash *KhugaBashSession) RequestOwnershipHandover() (*types.Transaction, error) {
	return _KhugaBash.Contract.RequestOwnershipHandover(&_KhugaBash.TransactOpts)
}

// RequestOwnershipHandover is a paid mutator transaction binding the contract method 0x25692962.
//
// Solidity: function requestOwnershipHandover() payable returns()
func (_KhugaBash *KhugaBashTransactorSession) RequestOwnershipHandover() (*types.Transaction, error) {
	return _KhugaBash.Contract.RequestOwnershipHandover(&_KhugaBash.TransactOpts)
}

// SetBackendSigner is a paid mutator transaction binding the contract method 0x36f95670.
//
// Solidity: function setBackendSigner(address _backendSigner) returns()
func (_KhugaBash *KhugaBashTransactor) SetBackendSigner(opts *bind.TransactOpts, _backendSigner common.Address) (*types.Transaction, error) {
	return _KhugaBash.contract.Transact(opts, "setBackendSigner", _backendSigner)
}

// SetBackendSigner is a paid mutator transaction binding the contract method 0x36f95670.
//
// Solidity: function setBackendSigner(address _backendSigner) returns()
func (_KhugaBash *KhugaBashSession) SetBackendSigner(_backendSigner common.Address) (*types.Transaction, error) {
	return _KhugaBash.Contract.SetBackendSigner(&_KhugaBash.TransactOpts, _backendSigner)
}

// SetBackendSigner is a paid mutator transaction binding the contract method 0x36f95670.
//
// Solidity: function setBackendSigner(address _backendSigner) returns()
func (_KhugaBash *KhugaBashTransactorSession) SetBackendSigner(_backendSigner common.Address) (*types.Transaction, error) {
	return _KhugaBash.Contract.SetBackendSigner(&_KhugaBash.TransactOpts, _backendSigner)
}

// SetPlayerNonce is a paid mutator transaction binding the contract method 0x7271bd7a.
//
// Solidity: function setPlayerNonce(address player, uint256 nonce) returns()
func (_KhugaBash *KhugaBashTransactor) SetPlayerNonce(opts *bind.TransactOpts, player common.Address, nonce *big.Int) (*types.Transaction, error) {
	return _KhugaBash.contract.Transact(opts, "setPlayerNonce", player, nonce)
}

// SetPlayerNonce is a paid mutator transaction binding the contract method 0x7271bd7a.
//
// Solidity: function setPlayerNonce(address player, uint256 nonce) returns()
func (_KhugaBash *KhugaBashSession) SetPlayerNonce(player common.Address, nonce *big.Int) (*types.Transaction, error) {
	return _KhugaBash.Contract.SetPlayerNonce(&_KhugaBash.TransactOpts, player, nonce)
}

// SetPlayerNonce is a paid mutator transaction binding the contract method 0x7271bd7a.
//
// Solidity: function setPlayerNonce(address player, uint256 nonce) returns()
func (_KhugaBash *KhugaBashTransactorSession) SetPlayerNonce(player common.Address, nonce *big.Int) (*types.Transaction, error) {
	return _KhugaBash.Contract.SetPlayerNonce(&_KhugaBash.TransactOpts, player, nonce)
}

// TransferOwnership is a paid mutator transaction binding the contract method 0xf2fde38b.
//
// Solidity: function transferOwnership(address newOwner) payable returns()
func (_KhugaBash *KhugaBashTransactor) TransferOwnership(opts *bind.TransactOpts, newOwner common.Address) (*types.Transaction, error) {
	return _KhugaBash.contract.Transact(opts, "transferOwnership", newOwner)
}

// TransferOwnership is a paid mutator transaction binding the contract method 0xf2fde38b.
//
// Solidity: function transferOwnership(address newOwner) payable returns()
func (_KhugaBash *KhugaBashSession) TransferOwnership(newOwner common.Address) (*types.Transaction, error) {
	return _KhugaBash.Contract.TransferOwnership(&_KhugaBash.TransactOpts, newOwner)
}

// TransferOwnership is a paid mutator transaction binding the contract method 0xf2fde38b.
//
// Solidity: function transferOwnership(address newOwner) payable returns()
func (_KhugaBash *KhugaBashTransactorSession) TransferOwnership(newOwner common.Address) (*types.Transaction, error) {
	return _KhugaBash.Contract.TransferOwnership(&_KhugaBash.TransactOpts, newOwner)
}

// UpdateScore is a paid mutator transaction binding the contract method 0x385aa0d7.
//
// Solidity: function updateScore(uint256 score, uint256 nonce, bytes signature) returns()
func (_KhugaBash *KhugaBashTransactor) UpdateScore(opts *bind.TransactOpts, score *big.Int, nonce *big.Int, signature []byte) (*types.Transaction, error) {
	return _KhugaBash.contract.Transact(opts, "updateScore", score, nonce, signature)
}

// UpdateScore is a paid mutator transaction binding the contract method 0x385aa0d7.
//
// Solidity: function updateScore(uint256 score, uint256 nonce, bytes signature) returns()
func (_KhugaBash *KhugaBashSession) UpdateScore(score *big.Int, nonce *big.Int, signature []byte) (*types.Transaction, error) {
	return _KhugaBash.Contract.UpdateScore(&_KhugaBash.TransactOpts, score, nonce, signature)
}

// UpdateScore is a paid mutator transaction binding the contract method 0x385aa0d7.
//
// Solidity: function updateScore(uint256 score, uint256 nonce, bytes signature) returns()
func (_KhugaBash *KhugaBashTransactorSession) UpdateScore(score *big.Int, nonce *big.Int, signature []byte) (*types.Transaction, error) {
	return _KhugaBash.Contract.UpdateScore(&_KhugaBash.TransactOpts, score, nonce, signature)
}

// UpgradeToAndCall is a paid mutator transaction binding the contract method 0x4f1ef286.
//
// Solidity: function upgradeToAndCall(address newImplementation, bytes data) payable returns()
func (_KhugaBash *KhugaBashTransactor) UpgradeToAndCall(opts *bind.TransactOpts, newImplementation common.Address, data []byte) (*types.Transaction, error) {
	return _KhugaBash.contract.Transact(opts, "upgradeToAndCall", newImplementation, data)
}

// UpgradeToAndCall is a paid mutator transaction binding the contract method 0x4f1ef286.
//
// Solidity: function upgradeToAndCall(address newImplementation, bytes data) payable returns()
func (_KhugaBash *KhugaBashSession) UpgradeToAndCall(newImplementation common.Address, data []byte) (*types.Transaction, error) {
	return _KhugaBash.Contract.UpgradeToAndCall(&_KhugaBash.TransactOpts, newImplementation, data)
}

// UpgradeToAndCall is a paid mutator transaction binding the contract method 0x4f1ef286.
//
// Solidity: function upgradeToAndCall(address newImplementation, bytes data) payable returns()
func (_KhugaBash *KhugaBashTransactorSession) UpgradeToAndCall(newImplementation common.Address, data []byte) (*types.Transaction, error) {
	return _KhugaBash.Contract.UpgradeToAndCall(&_KhugaBash.TransactOpts, newImplementation, data)
}

// KhugaBashInitializedIterator is returned from FilterInitialized and is used to iterate over the raw logs and unpacked data for Initialized events raised by the KhugaBash contract.
type KhugaBashInitializedIterator struct {
	Event *KhugaBashInitialized // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *KhugaBashInitializedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(KhugaBashInitialized)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(KhugaBashInitialized)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *KhugaBashInitializedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *KhugaBashInitializedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// KhugaBashInitialized represents a Initialized event raised by the KhugaBash contract.
type KhugaBashInitialized struct {
	Version uint64
	Raw     types.Log // Blockchain specific contextual infos
}

// FilterInitialized is a free log retrieval operation binding the contract event 0xc7f505b2f371ae2175ee4913f4499e1f2633a7b5936321eed1cdaeb6115181d2.
//
// Solidity: event Initialized(uint64 version)
func (_KhugaBash *KhugaBashFilterer) FilterInitialized(opts *bind.FilterOpts) (*KhugaBashInitializedIterator, error) {

	logs, sub, err := _KhugaBash.contract.FilterLogs(opts, "Initialized")
	if err != nil {
		return nil, err
	}
	return &KhugaBashInitializedIterator{contract: _KhugaBash.contract, event: "Initialized", logs: logs, sub: sub}, nil
}

// WatchInitialized is a free log subscription operation binding the contract event 0xc7f505b2f371ae2175ee4913f4499e1f2633a7b5936321eed1cdaeb6115181d2.
//
// Solidity: event Initialized(uint64 version)
func (_KhugaBash *KhugaBashFilterer) WatchInitialized(opts *bind.WatchOpts, sink chan<- *KhugaBashInitialized) (event.Subscription, error) {

	logs, sub, err := _KhugaBash.contract.WatchLogs(opts, "Initialized")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(KhugaBashInitialized)
				if err := _KhugaBash.contract.UnpackLog(event, "Initialized", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseInitialized is a log parse operation binding the contract event 0xc7f505b2f371ae2175ee4913f4499e1f2633a7b5936321eed1cdaeb6115181d2.
//
// Solidity: event Initialized(uint64 version)
func (_KhugaBash *KhugaBashFilterer) ParseInitialized(log types.Log) (*KhugaBashInitialized, error) {
	event := new(KhugaBashInitialized)
	if err := _KhugaBash.contract.UnpackLog(event, "Initialized", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// KhugaBashLeaderboardUpdatedIterator is returned from FilterLeaderboardUpdated and is used to iterate over the raw logs and unpacked data for LeaderboardUpdated events raised by the KhugaBash contract.
type KhugaBashLeaderboardUpdatedIterator struct {
	Event *KhugaBashLeaderboardUpdated // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *KhugaBashLeaderboardUpdatedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(KhugaBashLeaderboardUpdated)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(KhugaBashLeaderboardUpdated)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *KhugaBashLeaderboardUpdatedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *KhugaBashLeaderboardUpdatedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// KhugaBashLeaderboardUpdated represents a LeaderboardUpdated event raised by the KhugaBash contract.
type KhugaBashLeaderboardUpdated struct {
	Player common.Address
	Score  *big.Int
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterLeaderboardUpdated is a free log retrieval operation binding the contract event 0x24e225604268d6416871b32db1be8e49f497caf8360393b31d71a34a4ce26693.
//
// Solidity: event LeaderboardUpdated(address indexed player, uint256 score)
func (_KhugaBash *KhugaBashFilterer) FilterLeaderboardUpdated(opts *bind.FilterOpts, player []common.Address) (*KhugaBashLeaderboardUpdatedIterator, error) {

	var playerRule []interface{}
	for _, playerItem := range player {
		playerRule = append(playerRule, playerItem)
	}

	logs, sub, err := _KhugaBash.contract.FilterLogs(opts, "LeaderboardUpdated", playerRule)
	if err != nil {
		return nil, err
	}
	return &KhugaBashLeaderboardUpdatedIterator{contract: _KhugaBash.contract, event: "LeaderboardUpdated", logs: logs, sub: sub}, nil
}

// WatchLeaderboardUpdated is a free log subscription operation binding the contract event 0x24e225604268d6416871b32db1be8e49f497caf8360393b31d71a34a4ce26693.
//
// Solidity: event LeaderboardUpdated(address indexed player, uint256 score)
func (_KhugaBash *KhugaBashFilterer) WatchLeaderboardUpdated(opts *bind.WatchOpts, sink chan<- *KhugaBashLeaderboardUpdated, player []common.Address) (event.Subscription, error) {

	var playerRule []interface{}
	for _, playerItem := range player {
		playerRule = append(playerRule, playerItem)
	}

	logs, sub, err := _KhugaBash.contract.WatchLogs(opts, "LeaderboardUpdated", playerRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(KhugaBashLeaderboardUpdated)
				if err := _KhugaBash.contract.UnpackLog(event, "LeaderboardUpdated", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseLeaderboardUpdated is a log parse operation binding the contract event 0x24e225604268d6416871b32db1be8e49f497caf8360393b31d71a34a4ce26693.
//
// Solidity: event LeaderboardUpdated(address indexed player, uint256 score)
func (_KhugaBash *KhugaBashFilterer) ParseLeaderboardUpdated(log types.Log) (*KhugaBashLeaderboardUpdated, error) {
	event := new(KhugaBashLeaderboardUpdated)
	if err := _KhugaBash.contract.UnpackLog(event, "LeaderboardUpdated", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// KhugaBashOwnershipHandoverCanceledIterator is returned from FilterOwnershipHandoverCanceled and is used to iterate over the raw logs and unpacked data for OwnershipHandoverCanceled events raised by the KhugaBash contract.
type KhugaBashOwnershipHandoverCanceledIterator struct {
	Event *KhugaBashOwnershipHandoverCanceled // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *KhugaBashOwnershipHandoverCanceledIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(KhugaBashOwnershipHandoverCanceled)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(KhugaBashOwnershipHandoverCanceled)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *KhugaBashOwnershipHandoverCanceledIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *KhugaBashOwnershipHandoverCanceledIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// KhugaBashOwnershipHandoverCanceled represents a OwnershipHandoverCanceled event raised by the KhugaBash contract.
type KhugaBashOwnershipHandoverCanceled struct {
	PendingOwner common.Address
	Raw          types.Log // Blockchain specific contextual infos
}

// FilterOwnershipHandoverCanceled is a free log retrieval operation binding the contract event 0xfa7b8eab7da67f412cc9575ed43464468f9bfbae89d1675917346ca6d8fe3c92.
//
// Solidity: event OwnershipHandoverCanceled(address indexed pendingOwner)
func (_KhugaBash *KhugaBashFilterer) FilterOwnershipHandoverCanceled(opts *bind.FilterOpts, pendingOwner []common.Address) (*KhugaBashOwnershipHandoverCanceledIterator, error) {

	var pendingOwnerRule []interface{}
	for _, pendingOwnerItem := range pendingOwner {
		pendingOwnerRule = append(pendingOwnerRule, pendingOwnerItem)
	}

	logs, sub, err := _KhugaBash.contract.FilterLogs(opts, "OwnershipHandoverCanceled", pendingOwnerRule)
	if err != nil {
		return nil, err
	}
	return &KhugaBashOwnershipHandoverCanceledIterator{contract: _KhugaBash.contract, event: "OwnershipHandoverCanceled", logs: logs, sub: sub}, nil
}

// WatchOwnershipHandoverCanceled is a free log subscription operation binding the contract event 0xfa7b8eab7da67f412cc9575ed43464468f9bfbae89d1675917346ca6d8fe3c92.
//
// Solidity: event OwnershipHandoverCanceled(address indexed pendingOwner)
func (_KhugaBash *KhugaBashFilterer) WatchOwnershipHandoverCanceled(opts *bind.WatchOpts, sink chan<- *KhugaBashOwnershipHandoverCanceled, pendingOwner []common.Address) (event.Subscription, error) {

	var pendingOwnerRule []interface{}
	for _, pendingOwnerItem := range pendingOwner {
		pendingOwnerRule = append(pendingOwnerRule, pendingOwnerItem)
	}

	logs, sub, err := _KhugaBash.contract.WatchLogs(opts, "OwnershipHandoverCanceled", pendingOwnerRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(KhugaBashOwnershipHandoverCanceled)
				if err := _KhugaBash.contract.UnpackLog(event, "OwnershipHandoverCanceled", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseOwnershipHandoverCanceled is a log parse operation binding the contract event 0xfa7b8eab7da67f412cc9575ed43464468f9bfbae89d1675917346ca6d8fe3c92.
//
// Solidity: event OwnershipHandoverCanceled(address indexed pendingOwner)
func (_KhugaBash *KhugaBashFilterer) ParseOwnershipHandoverCanceled(log types.Log) (*KhugaBashOwnershipHandoverCanceled, error) {
	event := new(KhugaBashOwnershipHandoverCanceled)
	if err := _KhugaBash.contract.UnpackLog(event, "OwnershipHandoverCanceled", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// KhugaBashOwnershipHandoverRequestedIterator is returned from FilterOwnershipHandoverRequested and is used to iterate over the raw logs and unpacked data for OwnershipHandoverRequested events raised by the KhugaBash contract.
type KhugaBashOwnershipHandoverRequestedIterator struct {
	Event *KhugaBashOwnershipHandoverRequested // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *KhugaBashOwnershipHandoverRequestedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(KhugaBashOwnershipHandoverRequested)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(KhugaBashOwnershipHandoverRequested)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *KhugaBashOwnershipHandoverRequestedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *KhugaBashOwnershipHandoverRequestedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// KhugaBashOwnershipHandoverRequested represents a OwnershipHandoverRequested event raised by the KhugaBash contract.
type KhugaBashOwnershipHandoverRequested struct {
	PendingOwner common.Address
	Raw          types.Log // Blockchain specific contextual infos
}

// FilterOwnershipHandoverRequested is a free log retrieval operation binding the contract event 0xdbf36a107da19e49527a7176a1babf963b4b0ff8cde35ee35d6cd8f1f9ac7e1d.
//
// Solidity: event OwnershipHandoverRequested(address indexed pendingOwner)
func (_KhugaBash *KhugaBashFilterer) FilterOwnershipHandoverRequested(opts *bind.FilterOpts, pendingOwner []common.Address) (*KhugaBashOwnershipHandoverRequestedIterator, error) {

	var pendingOwnerRule []interface{}
	for _, pendingOwnerItem := range pendingOwner {
		pendingOwnerRule = append(pendingOwnerRule, pendingOwnerItem)
	}

	logs, sub, err := _KhugaBash.contract.FilterLogs(opts, "OwnershipHandoverRequested", pendingOwnerRule)
	if err != nil {
		return nil, err
	}
	return &KhugaBashOwnershipHandoverRequestedIterator{contract: _KhugaBash.contract, event: "OwnershipHandoverRequested", logs: logs, sub: sub}, nil
}

// WatchOwnershipHandoverRequested is a free log subscription operation binding the contract event 0xdbf36a107da19e49527a7176a1babf963b4b0ff8cde35ee35d6cd8f1f9ac7e1d.
//
// Solidity: event OwnershipHandoverRequested(address indexed pendingOwner)
func (_KhugaBash *KhugaBashFilterer) WatchOwnershipHandoverRequested(opts *bind.WatchOpts, sink chan<- *KhugaBashOwnershipHandoverRequested, pendingOwner []common.Address) (event.Subscription, error) {

	var pendingOwnerRule []interface{}
	for _, pendingOwnerItem := range pendingOwner {
		pendingOwnerRule = append(pendingOwnerRule, pendingOwnerItem)
	}

	logs, sub, err := _KhugaBash.contract.WatchLogs(opts, "OwnershipHandoverRequested", pendingOwnerRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(KhugaBashOwnershipHandoverRequested)
				if err := _KhugaBash.contract.UnpackLog(event, "OwnershipHandoverRequested", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseOwnershipHandoverRequested is a log parse operation binding the contract event 0xdbf36a107da19e49527a7176a1babf963b4b0ff8cde35ee35d6cd8f1f9ac7e1d.
//
// Solidity: event OwnershipHandoverRequested(address indexed pendingOwner)
func (_KhugaBash *KhugaBashFilterer) ParseOwnershipHandoverRequested(log types.Log) (*KhugaBashOwnershipHandoverRequested, error) {
	event := new(KhugaBashOwnershipHandoverRequested)
	if err := _KhugaBash.contract.UnpackLog(event, "OwnershipHandoverRequested", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// KhugaBashOwnershipTransferredIterator is returned from FilterOwnershipTransferred and is used to iterate over the raw logs and unpacked data for OwnershipTransferred events raised by the KhugaBash contract.
type KhugaBashOwnershipTransferredIterator struct {
	Event *KhugaBashOwnershipTransferred // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *KhugaBashOwnershipTransferredIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(KhugaBashOwnershipTransferred)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(KhugaBashOwnershipTransferred)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *KhugaBashOwnershipTransferredIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *KhugaBashOwnershipTransferredIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// KhugaBashOwnershipTransferred represents a OwnershipTransferred event raised by the KhugaBash contract.
type KhugaBashOwnershipTransferred struct {
	OldOwner common.Address
	NewOwner common.Address
	Raw      types.Log // Blockchain specific contextual infos
}

// FilterOwnershipTransferred is a free log retrieval operation binding the contract event 0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0.
//
// Solidity: event OwnershipTransferred(address indexed oldOwner, address indexed newOwner)
func (_KhugaBash *KhugaBashFilterer) FilterOwnershipTransferred(opts *bind.FilterOpts, oldOwner []common.Address, newOwner []common.Address) (*KhugaBashOwnershipTransferredIterator, error) {

	var oldOwnerRule []interface{}
	for _, oldOwnerItem := range oldOwner {
		oldOwnerRule = append(oldOwnerRule, oldOwnerItem)
	}
	var newOwnerRule []interface{}
	for _, newOwnerItem := range newOwner {
		newOwnerRule = append(newOwnerRule, newOwnerItem)
	}

	logs, sub, err := _KhugaBash.contract.FilterLogs(opts, "OwnershipTransferred", oldOwnerRule, newOwnerRule)
	if err != nil {
		return nil, err
	}
	return &KhugaBashOwnershipTransferredIterator{contract: _KhugaBash.contract, event: "OwnershipTransferred", logs: logs, sub: sub}, nil
}

// WatchOwnershipTransferred is a free log subscription operation binding the contract event 0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0.
//
// Solidity: event OwnershipTransferred(address indexed oldOwner, address indexed newOwner)
func (_KhugaBash *KhugaBashFilterer) WatchOwnershipTransferred(opts *bind.WatchOpts, sink chan<- *KhugaBashOwnershipTransferred, oldOwner []common.Address, newOwner []common.Address) (event.Subscription, error) {

	var oldOwnerRule []interface{}
	for _, oldOwnerItem := range oldOwner {
		oldOwnerRule = append(oldOwnerRule, oldOwnerItem)
	}
	var newOwnerRule []interface{}
	for _, newOwnerItem := range newOwner {
		newOwnerRule = append(newOwnerRule, newOwnerItem)
	}

	logs, sub, err := _KhugaBash.contract.WatchLogs(opts, "OwnershipTransferred", oldOwnerRule, newOwnerRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(KhugaBashOwnershipTransferred)
				if err := _KhugaBash.contract.UnpackLog(event, "OwnershipTransferred", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseOwnershipTransferred is a log parse operation binding the contract event 0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0.
//
// Solidity: event OwnershipTransferred(address indexed oldOwner, address indexed newOwner)
func (_KhugaBash *KhugaBashFilterer) ParseOwnershipTransferred(log types.Log) (*KhugaBashOwnershipTransferred, error) {
	event := new(KhugaBashOwnershipTransferred)
	if err := _KhugaBash.contract.UnpackLog(event, "OwnershipTransferred", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// KhugaBashPlayerRegisteredIterator is returned from FilterPlayerRegistered and is used to iterate over the raw logs and unpacked data for PlayerRegistered events raised by the KhugaBash contract.
type KhugaBashPlayerRegisteredIterator struct {
	Event *KhugaBashPlayerRegistered // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *KhugaBashPlayerRegisteredIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(KhugaBashPlayerRegistered)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(KhugaBashPlayerRegistered)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *KhugaBashPlayerRegisteredIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *KhugaBashPlayerRegisteredIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// KhugaBashPlayerRegistered represents a PlayerRegistered event raised by the KhugaBash contract.
type KhugaBashPlayerRegistered struct {
	Player common.Address
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterPlayerRegistered is a free log retrieval operation binding the contract event 0x8cd3331e32cec677d80b82cf0f71496605e7ed6ff864a3ccedc7d5d11d838c83.
//
// Solidity: event PlayerRegistered(address indexed player)
func (_KhugaBash *KhugaBashFilterer) FilterPlayerRegistered(opts *bind.FilterOpts, player []common.Address) (*KhugaBashPlayerRegisteredIterator, error) {

	var playerRule []interface{}
	for _, playerItem := range player {
		playerRule = append(playerRule, playerItem)
	}

	logs, sub, err := _KhugaBash.contract.FilterLogs(opts, "PlayerRegistered", playerRule)
	if err != nil {
		return nil, err
	}
	return &KhugaBashPlayerRegisteredIterator{contract: _KhugaBash.contract, event: "PlayerRegistered", logs: logs, sub: sub}, nil
}

// WatchPlayerRegistered is a free log subscription operation binding the contract event 0x8cd3331e32cec677d80b82cf0f71496605e7ed6ff864a3ccedc7d5d11d838c83.
//
// Solidity: event PlayerRegistered(address indexed player)
func (_KhugaBash *KhugaBashFilterer) WatchPlayerRegistered(opts *bind.WatchOpts, sink chan<- *KhugaBashPlayerRegistered, player []common.Address) (event.Subscription, error) {

	var playerRule []interface{}
	for _, playerItem := range player {
		playerRule = append(playerRule, playerItem)
	}

	logs, sub, err := _KhugaBash.contract.WatchLogs(opts, "PlayerRegistered", playerRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(KhugaBashPlayerRegistered)
				if err := _KhugaBash.contract.UnpackLog(event, "PlayerRegistered", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParsePlayerRegistered is a log parse operation binding the contract event 0x8cd3331e32cec677d80b82cf0f71496605e7ed6ff864a3ccedc7d5d11d838c83.
//
// Solidity: event PlayerRegistered(address indexed player)
func (_KhugaBash *KhugaBashFilterer) ParsePlayerRegistered(log types.Log) (*KhugaBashPlayerRegistered, error) {
	event := new(KhugaBashPlayerRegistered)
	if err := _KhugaBash.contract.UnpackLog(event, "PlayerRegistered", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// KhugaBashUpgradedIterator is returned from FilterUpgraded and is used to iterate over the raw logs and unpacked data for Upgraded events raised by the KhugaBash contract.
type KhugaBashUpgradedIterator struct {
	Event *KhugaBashUpgraded // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *KhugaBashUpgradedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(KhugaBashUpgraded)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(KhugaBashUpgraded)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *KhugaBashUpgradedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *KhugaBashUpgradedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// KhugaBashUpgraded represents a Upgraded event raised by the KhugaBash contract.
type KhugaBashUpgraded struct {
	Implementation common.Address
	Raw            types.Log // Blockchain specific contextual infos
}

// FilterUpgraded is a free log retrieval operation binding the contract event 0xbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b.
//
// Solidity: event Upgraded(address indexed implementation)
func (_KhugaBash *KhugaBashFilterer) FilterUpgraded(opts *bind.FilterOpts, implementation []common.Address) (*KhugaBashUpgradedIterator, error) {

	var implementationRule []interface{}
	for _, implementationItem := range implementation {
		implementationRule = append(implementationRule, implementationItem)
	}

	logs, sub, err := _KhugaBash.contract.FilterLogs(opts, "Upgraded", implementationRule)
	if err != nil {
		return nil, err
	}
	return &KhugaBashUpgradedIterator{contract: _KhugaBash.contract, event: "Upgraded", logs: logs, sub: sub}, nil
}

// WatchUpgraded is a free log subscription operation binding the contract event 0xbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b.
//
// Solidity: event Upgraded(address indexed implementation)
func (_KhugaBash *KhugaBashFilterer) WatchUpgraded(opts *bind.WatchOpts, sink chan<- *KhugaBashUpgraded, implementation []common.Address) (event.Subscription, error) {

	var implementationRule []interface{}
	for _, implementationItem := range implementation {
		implementationRule = append(implementationRule, implementationItem)
	}

	logs, sub, err := _KhugaBash.contract.WatchLogs(opts, "Upgraded", implementationRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(KhugaBashUpgraded)
				if err := _KhugaBash.contract.UnpackLog(event, "Upgraded", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseUpgraded is a log parse operation binding the contract event 0xbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b.
//
// Solidity: event Upgraded(address indexed implementation)
func (_KhugaBash *KhugaBashFilterer) ParseUpgraded(log types.Log) (*KhugaBashUpgraded, error) {
	event := new(KhugaBashUpgraded)
	if err := _KhugaBash.contract.UnpackLog(event, "Upgraded", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// KhugaBashScoreEarnedIterator is returned from FilterScoreEarned and is used to iterate over the raw logs and unpacked data for ScoreEarned events raised by the KhugaBash contract.
type KhugaBashScoreEarnedIterator struct {
	Event *KhugaBashScoreEarned // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *KhugaBashScoreEarnedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(KhugaBashScoreEarned)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(KhugaBashScoreEarned)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *KhugaBashScoreEarnedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *KhugaBashScoreEarnedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// KhugaBashScoreEarned represents a ScoreEarned event raised by the KhugaBash contract.
type KhugaBashScoreEarned struct {
	Player common.Address
	Score  *big.Int
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterScoreEarned is a free log retrieval operation binding the contract event 0x0a402f2cb1cfa0d454fe325d526ea05621e736d0e9a9da53f567663a27fb28f7.
//
// Solidity: event scoreEarned(address indexed player, uint256 score)
func (_KhugaBash *KhugaBashFilterer) FilterScoreEarned(opts *bind.FilterOpts, player []common.Address) (*KhugaBashScoreEarnedIterator, error) {

	var playerRule []interface{}
	for _, playerItem := range player {
		playerRule = append(playerRule, playerItem)
	}

	logs, sub, err := _KhugaBash.contract.FilterLogs(opts, "scoreEarned", playerRule)
	if err != nil {
		return nil, err
	}
	return &KhugaBashScoreEarnedIterator{contract: _KhugaBash.contract, event: "scoreEarned", logs: logs, sub: sub}, nil
}

// WatchScoreEarned is a free log subscription operation binding the contract event 0x0a402f2cb1cfa0d454fe325d526ea05621e736d0e9a9da53f567663a27fb28f7.
//
// Solidity: event scoreEarned(address indexed player, uint256 score)
func (_KhugaBash *KhugaBashFilterer) WatchScoreEarned(opts *bind.WatchOpts, sink chan<- *KhugaBashScoreEarned, player []common.Address) (event.Subscription, error) {

	var playerRule []interface{}
	for _, playerItem := range player {
		playerRule = append(playerRule, playerItem)
	}

	logs, sub, err := _KhugaBash.contract.WatchLogs(opts, "scoreEarned", playerRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(KhugaBashScoreEarned)
				if err := _KhugaBash.contract.UnpackLog(event, "scoreEarned", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseScoreEarned is a log parse operation binding the contract event 0x0a402f2cb1cfa0d454fe325d526ea05621e736d0e9a9da53f567663a27fb28f7.
//
// Solidity: event scoreEarned(address indexed player, uint256 score)
func (_KhugaBash *KhugaBashFilterer) ParseScoreEarned(log types.Log) (*KhugaBashScoreEarned, error) {
	event := new(KhugaBashScoreEarned)
	if err := _KhugaBash.contract.UnpackLog(event, "scoreEarned", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// KhugaBashScoreUpdatedIterator is returned from FilterScoreUpdated and is used to iterate over the raw logs and unpacked data for ScoreUpdated events raised by the KhugaBash contract.
type KhugaBashScoreUpdatedIterator struct {
	Event *KhugaBashScoreUpdated // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *KhugaBashScoreUpdatedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(KhugaBashScoreUpdated)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(KhugaBashScoreUpdated)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *KhugaBashScoreUpdatedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *KhugaBashScoreUpdatedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// KhugaBashScoreUpdated represents a ScoreUpdated event raised by the KhugaBash contract.
type KhugaBashScoreUpdated struct {
	Score     *big.Int
	Nonce     *big.Int
	Signature []byte
	Raw       types.Log // Blockchain specific contextual infos
}

// FilterScoreUpdated is a free log retrieval operation binding the contract event 0xb6a378e35ddeb6f44e2b3209d76cedc379819403ebbcac6a6dc28d4195dd4467.
//
// Solidity: event scoreUpdated(uint256 score, uint256 nonce, bytes signature)
func (_KhugaBash *KhugaBashFilterer) FilterScoreUpdated(opts *bind.FilterOpts) (*KhugaBashScoreUpdatedIterator, error) {

	logs, sub, err := _KhugaBash.contract.FilterLogs(opts, "scoreUpdated")
	if err != nil {
		return nil, err
	}
	return &KhugaBashScoreUpdatedIterator{contract: _KhugaBash.contract, event: "scoreUpdated", logs: logs, sub: sub}, nil
}

// WatchScoreUpdated is a free log subscription operation binding the contract event 0xb6a378e35ddeb6f44e2b3209d76cedc379819403ebbcac6a6dc28d4195dd4467.
//
// Solidity: event scoreUpdated(uint256 score, uint256 nonce, bytes signature)
func (_KhugaBash *KhugaBashFilterer) WatchScoreUpdated(opts *bind.WatchOpts, sink chan<- *KhugaBashScoreUpdated) (event.Subscription, error) {

	logs, sub, err := _KhugaBash.contract.WatchLogs(opts, "scoreUpdated")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(KhugaBashScoreUpdated)
				if err := _KhugaBash.contract.UnpackLog(event, "scoreUpdated", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseScoreUpdated is a log parse operation binding the contract event 0xb6a378e35ddeb6f44e2b3209d76cedc379819403ebbcac6a6dc28d4195dd4467.
//
// Solidity: event scoreUpdated(uint256 score, uint256 nonce, bytes signature)
func (_KhugaBash *KhugaBashFilterer) ParseScoreUpdated(log types.Log) (*KhugaBashScoreUpdated, error) {
	event := new(KhugaBashScoreUpdated)
	if err := _KhugaBash.contract.UnpackLog(event, "scoreUpdated", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
