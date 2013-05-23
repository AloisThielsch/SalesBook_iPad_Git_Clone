#!/bin/sh
diff "${PODS_ROOT}/../Podfile.lock" "${PODS_ROOT}/Manifest.lock" > /dev/null
if [[ $? != 0 ]] ; then
    cat << EOM
error: The sanbox is not in sync with the Podfile.lock. Run 'pod install'.
EOM
    exit 1
fi

