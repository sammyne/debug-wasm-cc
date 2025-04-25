# debug WASM with LLDB and GDB

## 0. Requirement
- debian 12
- GNU gdb (Debian 13.1-3) 13.1
- lldb version 18.1.8
- wasi-sdk 22.0
- wasmtime 22.0.0

## 1. Project Layout
### foo.cc: c++ source code
```c++
#include <cstdio>

int main() {
  int a = 123;

  int b = 456;

  int c = a + b;

  printf("c = %d\n", c);

  return 0;
}
```
### Makefile: build script
```makefile
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
```

## 2. Problems of debugging with LLDB

```bash
make lldb
```

Executing `expr (void)__vmctx->set()` would trigger following warnings
```bash
error: Couldn't materialize: couldn't get the value of variable __vmctx: variable not available
error: errored out in DoExecute, couldn't PrepareToExecuteJITExpression
```

**Question**: How to fix this?

## 3. Problems of debugging with GDB

```bash
make gdb
```

We got following warnings

```bash
Reading symbols from wasmtime...
(No debugging symbols found in wasmtime)
```

**Question**: Does it matters?

## References
- [Debugging with gdb and lldb](https://docs.wasmtime.dev/examples-debugging-native-debugger.html)
- [Debugging WebAssembly with LLDB](https://www.youtube.com/watch?v=PevI_Mn-UUE)
