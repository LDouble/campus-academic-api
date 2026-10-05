BUF ?= go run github.com/bufbuild/buf/cmd/buf@v1.61.0

.PHONY: generate generate-check test
generate:
	$(BUF) lint proto
	$(BUF) generate proto

generate-check: generate
	git diff --exit-code -- pkg
	@test -z "$$(git ls-files --others --exclude-standard pkg)"

test:
	go test ./...
