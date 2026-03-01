#!/bin/bash

# cross compile options: loongarch, riscv
ARCH_TARGET=""

if [[ "$ARCH_TARGET" == "loongarch" ]];
then
	export ARCH="loongarch"
	export CROSS_COMPILE="loongarch64-linux-"
elif [[ "$ARCH_TARGET" == "riscv" ]];
then
	export ARCH="riscv"
	export CROSS_COMPILE="riscv64-linux-"
fi

CORES="$(nproc)"
KERN_TREE="linux-smatch-test"
OLD_SMATCH="old_smatch_warns.txt"
SMATCH_REPO="https://github.com/error27/smatch.git"
KERN_REPO="https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git"

if [[ -f "$KERN_TREE/smatch_warns.txt" ]];
then
	mv "$KERN_TREE/smatch_warns.txt" "$OLD_SMATCH"
fi

rm -rf "$KERN_TREE"

git clone --depth 1 "$KERN_REPO" "$KERN_TREE"

cd "$KERN_TREE" || exit

(
git clone --depth 1 "$SMATCH_REPO"
cd smatch || exit
if [[ "$ARCH_TARGET" == "loongarch" || "$ARCH_TARGET" == "riscv" ]];
then
	sed -i 's/bzImage/vmlinux/g' "smatch_scripts/test_kernel.sh"
fi
make -j"$CORES"
)

if [[ "$ARCH_TARGET" == "loongarch" || "$ARCH_TARGET" == "riscv" ]];
then
	make defconfig
else
	make allmodconfig
fi

./smatch/smatch_scripts/build_kernel_data.sh
./smatch/smatch_scripts/test_kernel.sh --endian
