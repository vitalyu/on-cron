.PHONY: help
help: ## Show this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

install-githooks:
	@echo "[~] Install git hooks"
	@git config core.hooksPath .githooks

install-goreleaser:
	@echo "[~] Install goreleaser"
	@test -x /usr/local/bin/goreleaser && exit 0; \
	version=2.12.7 && \
    arch=$$(uname -m) && \
    [ "$$arch" = "aarch64" ] && arch="arm64"; \
    [ "$$arch" = "amd64" ] && arch="x86_64"; \
    curl -L -o /tmp/goreleaser.tar.gz https://github.com/goreleaser/goreleaser/releases/download/v$$version/goreleaser_Linux_$$arch.tar.gz && \
    tar -xzvf /tmp/goreleaser.tar.gz -C /tmp/ && \
    mv /tmp/goreleaser /usr/local/bin/

##@ Dev

format: ## Run formatter
	go fmt ./...

tidy: ## Run tidy
	go mod tidy -v

test: ## Run unit tests
	go clean -testcache
	go test -v -covermode=count ./...

##@ Build

.PHONY: build
build: ## Build binary locally with version info
	@echo "Building on-cron with version info"
	@VERSION=$$(git describe --tags --always --dirty 2>/dev/null || echo "dev"); \
	BRANCH=$$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown"); \
	COMMIT=$$(git rev-parse --short HEAD 2>/dev/null || echo "unknown"); \
	go build -ldflags "-s -w \
		-X main.version=$$VERSION \
		-X main.branch=$$BRANCH \
		-X main.commit=$$COMMIT" \
		-o on-cron ./cmd/on-cron

.PHONY: release
release: install-goreleaser ## Build via goreleaser
	@echo "Build release via goreleaser"
	goreleaser release --snapshot --clean
