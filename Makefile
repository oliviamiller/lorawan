
BUILD_DIR = ./sx1302
CGO_BUILD_LDFLAGS := -L$(shell pwd)/$(BUILD_DIR)/libloragw -L$(shell pwd)/$(BUILD_DIR)libloragw/lib -L$(shell pwd)/$(BUILD_DIR)/libtools
BIN_OUTPUT_PATH = bin
TOOL_BIN = bin/gotools/$(shell uname -s)-$(shell uname -m)
UNAME_S ?= $(shell uname -s)

lorawan:
	rm -f lorawan
	CGO_LDFLAGS="$$CGO_LDFLAGS $(CGO_BUILD_LDFLAGS)" go build $(GO_BUILD_LDFLAGS) -o $@ main.go

module.tar.gz: lorawan first_run.sh meta.json
	rm -f $(BIN_OUTPUT_PATH)/module.tar.gz
	tar czf $(BIN_OUTPUT_PATH)/module.tar.gz $^

test: sx1302 lorawan
	sudo apt install libnlopt-dev
	CGO_LDFLAGS="$$CGO_LDFLAGS $(CGO_BUILD_LDFLAGS)" go test -race -v ./...


sx1302: submodule
	cd sx1302/libtools && make
	cd sx1302/libloragw && make

submodule:
	git submodule init
	git submodule update

tool-install:
	GOBIN=`pwd`/$(TOOL_BIN) go install github.com/golangci/golangci-lint/cmd/golangci-lint

gofmt:
	gofmt -w -s .

lint: gofmt tool-install
	go mod tidy
	$(TOOL_BIN)/golangci-lint run -v --fix --timeout=10m --config=./etc/.golangci.yaml

