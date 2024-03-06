# Always failing assertion with a message.
#
# Example:
#     fail "It should have been but it wasn't to be"
function fail() {
    echo -e "$1"
    exit 1
}


function assertStringEqual() {
    if ! diff <(echo "$1") <(echo "$2") ; then
        fail "expecting \"$1\"\nto equal the reference value \"$2\""
    fi
}

function assertStringContains() {
    if ! echo "$1" | grep -q "$2" ; then
        fail "expecting:\n\"$1\"\nto contain the reference value:\n\"$2\""
    fi
}
