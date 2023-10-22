-include .env

# Clean the repo
clean  :; forge clean

# Update Dependencies
update:; forge update

build:; forge build

test-contract :; forge test --watch -vvv

snapshot :; forge snapshot

slither :; slither . 

anvil :; anvil -m 'test test test test test test test test test test test junk'
