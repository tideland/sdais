SHELL := /bin/bash

VERSION := $(shell sed -n 's/^- \*\*Version:\*\* //p' SDAIS.md | head -1)

.PHONY: help check release release-force verify

help:
	@echo "SDAIS developer commands:"
	@echo "  make check                         Run all repository checks"
	@echo "  make release [VERSION=vX.Y.Z]     Build and verify dist/sdais-vX.Y.Z.tgz"
	@echo "  make release-force VERSION=vX.Y.Z Rebuild an existing archive"
	@echo "  make verify ARCHIVE=<path>         Verify an existing release archive"

check:
	./scripts/check.sh

release:
	./scripts/build-release.sh "$(VERSION)"

release-force:
	./scripts/build-release.sh --force "$(VERSION)"

verify:
	@test -n "$(ARCHIVE)" || { echo "ARCHIVE is required" >&2; exit 1; }
	./scripts/verify-release.sh "$(ARCHIVE)"
