package main

import (
	"context"
	"encoding/json"
	"log"
	"math/big"
	"math/rand"
	"net/http"
	"os"

	"khugabash/backend"

	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/joho/godotenv"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

type Server struct {
	client  *ethclient.Client
	game    *backend.KhugaBash
	chainID *big.Int
}

type RegisterResponse struct {
	TxHash string `json:"txHash"`
}

type PlayerStatsResponse struct {
	Score        *big.Int `json:"score"`
	IsRegistered bool     `json:"isRegistered"`
}

type LeaderboardEntry struct {
	Player common.Address `json:"player"`
	Points *big.Int       `json:"points"`
}

func main() {
	if err := godotenv.Load(); err != nil {
		log.Fatal("Error loading .env file")
	}

	// Connect to Ethereum network (e.g., Base Goerli testnet)
	client, err := ethclient.Dial(os.Getenv("RPC_URL"))
	if err != nil {
		log.Fatal(err)
	}

	// Load contract
	gameAddress := common.HexToAddress(os.Getenv("CONTRACT_ADDRESS"))
	game, err := backend.NewKhugaBash(gameAddress, client)
	if err != nil {
		log.Fatal(err)
	}

	chainID, err := client.ChainID(context.Background())
	if err != nil {
		log.Fatal(err)
	}

	server := &Server{
		client:  client,
		game:    game,
		chainID: chainID,
	}

	// Initialize Echo
	e := echo.New()

	// Middleware
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Use(middleware.CORS())

	// Routes
	e.POST("/register", server.handleRegister)
	e.GET("/stats/:address", server.handleGetStats)
	e.GET("/leaderboard", server.handleGetLeaderboard)
	e.POST("/award-score/:address", server.handleAwardScore)
	e.POST("/update-score/:address", server.handleUpdateScore)

	// Start server
	e.Logger.Fatal(e.Start(":8080"))
}

func (s *Server) handleRegister(c echo.Context) error {
	privateKey, err := crypto.HexToECDSA(os.Getenv("PRIVATE_KEY"))
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	auth, err := bind.NewKeyedTransactorWithChainID(privateKey, s.chainID)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	// generate random nonce
	nonce := rand.Intn(100)

	tx, err := s.game.RegisterPlayer(auth, big.NewInt(int64(nonce)))
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	return c.JSON(http.StatusOK, RegisterResponse{
		TxHash: tx.Hash().Hex(),
	})
}

func (s *Server) handleGetStats(c echo.Context) error {
	address := common.HexToAddress(c.Param("address"))

	stats, err := s.game.GetPlayerStats(&bind.CallOpts{}, address)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	return c.JSON(http.StatusOK, PlayerStatsResponse{
		Score:        stats.Score,
		IsRegistered: stats.IsRegistered,
	})
}

func (s *Server) handleGetLeaderboard(c echo.Context) error {
	entries, err := s.game.GetTopPlayers(&bind.CallOpts{}, big.NewInt(10))
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	return c.JSON(http.StatusOK, entries)
}

func (s *Server) handleAwardScore(c echo.Context) error {
	privateKey, err := crypto.HexToECDSA(os.Getenv("PRIVATE_KEY"))
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	auth, err := bind.NewKeyedTransactorWithChainID(privateKey, s.chainID)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	address := common.HexToAddress(c.Param("address"))

	var body struct {
		Multiplier *big.Int `json:"multiplier"`
	}

	if err := json.NewDecoder(c.Request().Body).Decode(&body); err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, err.Error())
	}

	tx, err := s.game.AwardScore(auth, address, body.Multiplier)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	return c.JSON(http.StatusOK, map[string]string{
		"txHash": tx.Hash().Hex(),
	})
}

func (s *Server) handleUpdateScore(c echo.Context) error {
	privateKey, err := crypto.HexToECDSA(os.Getenv("PRIVATE_KEY"))
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	auth, err := bind.NewKeyedTransactorWithChainID(privateKey, s.chainID)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	var body struct {
		Score     *big.Int `json:"score"`
		Nonce     *big.Int `json:"nonce"`
		Signature []byte   `json:"signature"`
	}

	if err := json.NewDecoder(c.Request().Body).Decode(&body); err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, err.Error())
	}

	tx, err := s.game.UpdateScore(auth, body.Score, body.Nonce, body.Signature)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	return c.JSON(http.StatusOK, map[string]string{
		"txHash": tx.Hash().Hex(),
	})
}
