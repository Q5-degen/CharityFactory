-include .env

Deploy:; forge script script/DeployCharityFactory.s.sol:DeployCharityFactory --rpc-url $(SEPOLIA) --account defaultKey --sender $(ADDR) --broadcast --verify --etherscan-api-key $(KEY)
Register:; forge script script/Interactions.s.sol:RegisterCharity --rpc-url $(SEPOLIA) --account secondAccount --sender $(ADDR0) --broadcast 
Withdraw:; forge script script/Interactions.s.sol:WithdrawDonation --rpc-url $(SEPOLIA) --account secondAccount --sender $(ADDR0) --broadcast 
Donate:; forge script script/Interactions.s.sol:Donate --rpc-url $(SEPOLIA) --account thirdAccount --sender $(ADDR1) --broadcast 
