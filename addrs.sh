#!/usr/bin/env bash

# The purpose of this script is to replace constant values with label references

set -e

get_label () {
    label_addr=$1
    printf $(grep -nB1 "; $label_addr" main.asm | head -1 | awk -F- '{print $2}' | sed s/://)
    }

apply_high() {
    label_addr=$1
    byte_addr=$2
    label=$3
    # echo high $3 ${1::-2} $2
    echo "/; $byte_addr/s/\$${label_addr::-2}/>$label/;"
    echo "/; $byte_addr/s/\s\{$((${#label}-2))\};/;/;"
    }

apply_low() {
    label_addr=$1
    byte_addr=$2
    label=$3
    # echo low $3 ${1:2} $2
    echo "/; $byte_addr/s/\$${label_addr:2}/<$label/;"
    echo "/; $byte_addr/s/\s\{$((${#label}-2))\};/;/;"
    }

apply_label() {
    label=$(get_label $1)
    label_addr=$1
    low_byte_addr=$2
    high_byte_addr=$3
    apply_low $label_addr $low_byte_addr $label
    apply_high $label_addr $high_byte_addr $label
    }

add_constant() {
    constant=$1
    addrs=${@:2}
    search="${addrs// /\\\| ; }"  # join 2nd arg onward into "arg2\|; arg3\|; arg4"
    echo "/; $search/s/\$..\s\{$((${#constant}-3))\}/$constant/;"
    }

# label, lowloc, highloc
sed -i "$(
apply_label 977B 9C39 9C3D
)" main.asm


# extract_nt () {
#     grep -Pzo "(?sm)${1}:\\n\\K.*?(?=^\\S)" main.asm | grep -a byte > nametables/${1}.asm
#     perl -i -p0e "s/^${1}:\\n\\K.*?(?=^\\S)/.include \"nametables\/${1}.asm\"\n/ms" main.asm
#     }

# extract_nt titleScreenNametable
# extract_nt menuNametable
# extract_nt gameModeNametableCoop
# extract_nt gameModeNametable1P
# extract_nt gameModeNametable2P
