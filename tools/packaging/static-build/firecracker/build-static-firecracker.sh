#!/usr/bin/env bash
#
# Copyright (c) 2018 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0

set -o errexit
set -o nounset
set -o pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${script_dir}/../../scripts/lib.sh"

config_dir="${script_dir}/../../scripts/"

firecracker_repo="${firecracker_repo:-}"
firecracker_dir="firecracker"
firecracker_version="${firecracker_version:-}"

if [ -z "$firecracker_repo" ]; then
	info "Get firecracker information from runtime versions.yaml"
	firecracker_url=$(get_from_kata_deps "assets.hypervisor.firecracker.url")
	[ -n "$firecracker_url" ] || die "failed to get firecracker url"
	firecracker_repo="${firecracker_url}.git"
fi
[ -n "$firecracker_repo" ] || die "failed to get firecracker repo"

[ -n "$firecracker_version" ] || firecracker_version=$(get_from_kata_deps "assets.hypervisor.firecracker.version")
[ -n "$firecracker_version" ] || die "failed to get firecracker version"

info "Build ${firecracker_repo} version: ${firecracker_version}"

[ -d "${firecracker_dir}" ] || git clone ${firecracker_repo}
cd "${firecracker_dir}"
git fetch
git checkout ${firecracker_version}
sudo ./tools/devtool --unattended build --release

ln -sf ./build/cargo_target/x86_64-unknown-linux-musl/release/firecracker ./firecracker-static
ln -sf ./build/cargo_target/x86_64-unknown-linux-musl/release/jailer ./jailer-static
