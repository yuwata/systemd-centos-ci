#!/usr/bin/sh

set -e

# Workaround for older ninja-build versions
if [ ! -f /usr/bin/ninja ]; then
    ln -s /usr/bin/ninja-build /usr/bin/ninja
fi

if [ $(cat /proc/sys/user/max_user_namespaces) -le 0 ]; then
    echo >&2 "user.max_user_namespaces must be > 0"
    exit 1
fi

yum -q -y install net-tools strace nc busybox e2fsprogs quota net-tools strace

cd systemd

# Run the internal unit tests (make check)
ninja -C build test

# Run the internal integration testsuite
test/run-integration-tests.sh

# Other integration tests
TEST_LIST=(
    "test/test-exec-deserialization.py"
)

for t in "${TEST_LIST[@]}"; do
    echo "--- RUNNING $t ---"
    ./$t
done