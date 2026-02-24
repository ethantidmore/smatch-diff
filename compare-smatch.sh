#!/bin/sh

KERN_TREE="linux-smatch-test"
OLD_SMATCH="old_smatch_warns.txt"
BLACKLIST="blacklist.txt"

awk '
NR==FNR {
    sig = $0
    gsub(/:[0-9]+/, "", sig)
    gsub(/line [0-9]+/, "line", sig)
    
    old_warns[sig] = 1
    next
}
{
    sig = $0
    gsub(/:[0-9]+/, "", sig)
    gsub(/line [0-9]+/, "line", sig)
    
    if (!old_warns[sig]) {
        print $0
    }
}' "$OLD_SMATCH" "$KERN_TREE/smatch_warns.txt" | grep -Fvf "$BLACKLIST"
