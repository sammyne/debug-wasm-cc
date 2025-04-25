APP = foo.wasm

CXX = /opt/wasi-sdk/bin/clang++

.PHONY: all
all: $(APP)

$(APP): foo.cc
	$(CXX) $< -g -o $@

# 添加 -O opt-level=0 选项会触发 '$1 = <optimized out>' 告警。
gdb: $(APP)
	gdb -ex 'set disable-randomization off' \
		-ex 'b main' \
		-ex 'r' \
		-ex 'n' \
		-ex 'n' \
		-ex 'n' \
		-ex 'p a' \
		--args wasmtime run -D debug-info $<

lldb: $(APP)
	lldb-18 -O 'settings set target.disable-aslr false' \
		-o 'breakpoint set -n main' \
		-o 'r' \
		-o 'c' \
		-o 'expr (void)__vmctx->set()' \
		-- wasmtime run -D debug-info -O opt-level=0 $<

.PHONY: clean
clean:
	rm -rf $(APP)

	