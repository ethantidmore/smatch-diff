#!/bin/sh

CORES="$(nproc)"
KERN_TREE="linux-smatch-test"
OLD_SMATCH="old_smatch_warns.txt"
SMATCH_REPO="https://github.com/error27/smatch.git"
KERN_REPO="https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git"

if [ -f "$KERN_TREE/smatch_warns.txt" ];
then
	mv "$KERN_TREE/smatch_warns.txt" "$OLD_SMATCH"
fi

rm -rf "$KERN_TREE"

git clone --depth 1 "$KERN_REPO" "$KERN_TREE"

cd "$KERN_TREE" || exit

(
git clone --depth 1 "$SMATCH_REPO"
cd smatch || exit
make -j"$CORES"
)

make allmodconfig

./smatch/smatch_scripts/build_kernel_data.sh
./smatch/smatch_scripts/test_kernel.sh --endian
