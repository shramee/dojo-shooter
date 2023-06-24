

build:
	cd contracts;sozo build

test:
	cd contracts; sozo test

budep: build deploy

deploy:
	@cd contracts; \
	SOZO_OUT="$$(sozo migrate)"; echo "$$SOZO_OUT"; \
	WORLD_ADDR="$$(echo "$$SOZO_OUT" | grep "Successfully migrated World at address" | rev | cut -d " " -f 1 | rev)"; \
	[ -n "$$WORLD_ADDR" ] && \
		echo "$$WORLD_ADDR" > ../last_deployed_world && \
		echo "$$SOZO_OUT" > ../deployed.log; \
	sozo execute SpawnDummyZombies --world $$WORLD_ADDR
	
# Usage: make ecs_exe s=Spawn
ecs_exe:
	@WORLD_ADDR=$$(tail -n1 ./last_deployed_world); \
	@WORLD_ADDR=$$(tail -n1 ./last_deployed_world); \
	cd contracts; echo "sozo execute $(s) --world $$WORLD_ADDR"; \
	sozo execute $(s) --world $$WORLD_ADDR

# Usage: make ecs_ntt c=Acc e=1
ecs_ntt:
	@WORLD_ADDR=$$(tail -n1 ./last_deployed_world); \
	cd contracts; echo "sozo component entity $(c) $(e) --world $$WORLD_ADDR"; \
	sozo component entity $(c) $(e) --world $$WORLD_ADDR

serve:
	@cd ./client; \
	rustup override set nightly; \
	WORLD_ADDR=$$(tail -n1 ../last_deployed_world) cargo run --release;

deploy_and_run: deploy indexer serve

loop_update:
	@WORLD_ADDR=$$(tail -n1 ./last_deployed_world); cd contracts; \
	while true; do sleep .1 &\
	sozo execute Update -c 0 --world $$WORLD_ADDR;\
	wait; done;


