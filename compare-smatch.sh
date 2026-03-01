#!/bin/bash

KERN_TREE="linux-smatch-test"
OLD_SMATCH="old_smatch_warns.txt"
BLACKLIST="blacklist.txt"

awk '
function get_sig(line_str) {
    sig = line_str
    
    gsub(/:[0-9]+/, "", sig)
    
    gsub(/lines?: [0-9, ]+/, "lines:", sig)
    
    gsub(/line [0-9]+/, "line", sig)
    
    return sig
}

NR==FNR {
    old_warns[get_sig($0)] = 1
    next
}
{
    if (!old_warns[get_sig($0)]) {
        print $0
    }
}' "$OLD_SMATCH" "$KERN_TREE/smatch_warns.txt" | grep -Fvf "$BLACKLIST"
