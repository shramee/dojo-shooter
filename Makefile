W_ADDR = $$(tail -n1 ./last_deployed_world)
W_ADDR_ = $$(tail -n1 ../last_deployed_world)

ADMIN_AC = 0x06d48c7a2a1d0471bfd699ff3e166aa86bf7439ff3eb2c22101cef04b2ba60cb
ADMIN_PK = $$(tail -n1 ../admin.key)

PLAYER_AC = 0x07b4f1cf0d52d910b955973da0319519a1e2596070e905926f175a2d13d502ee
PLAYER_PK = $$(tail -n1 ../player.key)

RPC_URL = http://54.252.157.63:5050

play:
	echo "$(PK) $(W_ADDR)"

build:
	cd contracts; sozo build

test:
	cd contracts; sozo test

redeploy:
	@cd contracts; \
	sozo migrate --world $(W_ADDR_) --rpc-url $(RPC_URL) --account-address $(ADMIN_AC) --private-key $(ADMIN_PK);


deploy:
	@cd contracts; \
	SOZO_OUT="$$(sozo migrate --rpc-url $(RPC_URL) --account-address $(ADMIN_AC) --private-key $(ADMIN_PK))"; echo "$$SOZO_OUT"; \
	W_ADDR="$$(echo "$$SOZO_OUT" | grep "Successfully migrated World at address" | rev | cut -d " " -f 1 | rev)"; \
	[ -n "$$W_ADDR" ] && \
		echo "$$W_ADDR" > ../last_deployed_world && \
		echo "$$SOZO_OUT" > ../deployed.log; \
	sozo execute SpawnDummyZombies --world $(W_ADDR_) --rpc-url $(RPC_URL) --account-address $(ADMIN_AC) --private-key $(ADMIN_PK); \
	sozo execute SpawnPlayer --world $(W_ADDR_) --rpc-url $(RPC_URL) --account-address $(ADMIN_AC) --private-key $(ADMIN_PK);
	
# Usage: make ecs_exe s=Spawn
ecs_exe:
	cd contracts; echo "sozo execute $(s) --world $(W_ADDR_)"; \
	sozo execute $(s) --world $(W_ADDR_) --rpc-url $(RPC_URL) --account-address $(ADMIN_AC) --private-key $(ADMIN_PK)

# Usage: make ecs_ntt c=Acc e=1
ecs_ntt:
	cd contracts; echo "sozo component entity $(c) $(e) --world $(W_ADDR_) --rpc-url $(RPC_URL) --account-address $(ADMIN_AC) --private-key $(ADMIN_PK)"; \
	sozo component entity $(c) $(e) --world $(W_ADDR_) --rpc-url $(RPC_URL) --account-address $(ADMIN_AC) --private-key $(ADMIN_PK)

serve:

	@cd ./client; \
	rustup override set nightly; \
	ADMIN_AC=$(PLAYER_PK) \
	PK=$(PLAYER_AC) \
	W_ADDR=$(W_ADDR_) \
	RPC_URL=$(RPC_URL) \
	  cargo run --release;

deploy_and_run: deploy indexer serve

loop_tick:
	while true; do sleep .2 &\
	sozo execute Update -c 0 --world $(W_ADDR_) --rpc-url $(RPC_URL) --account-address $(ADMIN_AC) --private-key $(ADMIN_PK);\
	wait; done;


