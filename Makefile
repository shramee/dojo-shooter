

build:
	sozo build

test:
	cd ./src; sozo test

start:
	node

indexer:
	@WORLD_ADDR=$$(tail -n1 ./last_deployed_world); \
	torii -w $$WORLD_ADDR --rpc http://127.0.0.1:5050

deploy:
	@cd ./autonomous-agents; \
	SOZO_OUT="$$(sozo migrate)"; echo "$$SOZO_OUT"; \
	WORLD_ADDR="$$(echo "$$SOZO_OUT" | grep "World at address" | rev | cut -d " " -f 1 | rev)"; \
	[ -n "$$WORLD_ADDR" ] && \
		echo "$$WORLD_ADDR" > ../last_deployed_world && \
		echo "$$SOZO_OUT" > ../deployed.log;
	# sozo execute $(s) --world $$WORLD_ADDR

# Usage: make ecs_exe s=Spawn
ecs_exe:
	@WORLD_ADDR=$$(tail -n1 ./last_deployed_world); \
	cd ./autonomous-agents; echo "sozo execute $(s) --world $$WORLD_ADDR"; \
	sozo execute $(s) --world $$WORLD_ADDR

# Usage: make ecs_ntt c=Acc e=1
ecs_ntt:
	@WORLD_ADDR=$$(tail -n1 ./last_deployed_world); \
	cd ./autonomous-agents; echo "sozo component entity $(c) $(e) --world $$WORLD_ADDR"; \
	sozo component entity $(c) $(e) --world $$WORLD_ADDR

serve:
	@cd ./client; \
	rustup override set nightly; \
	WORLD_ADDR=$$(tail -n1 ../last_deployed_world) cargo run --release;

deploy_and_run: deploy indexer serve

loop:
	@WORLD_ADDR=$$(tail -n1 ./last_deployed_world); \
	cd ./autonomous-agents; echo "sozo execute $(s) --world $$WORLD_ADDR"; \
	node ../run-sozo.js;