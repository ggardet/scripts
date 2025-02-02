#!/usr/bin/env bash

set -e

dir=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)

TEST_MORE_PATH=$dir/../test-more-bash
BASHLIB="`
    find $TEST_MORE_PATH -type d |
    grep -E '/(bin|lib)$' |
    xargs -n1 printf "%s:"`"
PATH=$BASHLIB$PATH

source bash+ :std
use Test::More
plan tests 5

rc=0
output=$(script_dir=$dir/scripts ./openqa-label-known-issues-and-investigate-hook 123 2>&1) || rc=$?
is "$rc" 0 'successful hook'

like "$output" 'https://openqa.opensuse.org/tests/123 | openqa-investigate' 'correct output 1'
like "$output" 'openqa-trigger-bisect-jobs .--url https://openqa.opensuse.org/tests/123.' 'correct output 2'

export INVESTIGATE_FAIL=true
rc=0
output=$(script_dir=$dir/scripts ./openqa-label-known-issues-and-investigate-hook 123 2>&1) || rc=$?
is "$rc" 1 'openqa-investigate failed'

export INVESTIGATE_FAIL=false
export INVESTIGATE_RETRIGGER_HOOK=true
rc=0
output=$(script_dir=$dir/scripts ./openqa-label-known-issues-and-investigate-hook 123 2>&1) || rc=$?
is "$rc" 142 'openqa-investigate exit code for retriggering hook script'
