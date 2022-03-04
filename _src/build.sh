#!/bin/bash

set -e

help="./$(basename "$0") [options...]
where:
    -t | --target Destination folder for the python artifacts"

topdir="$(pwd)"
target="${topdir}/build/distributions"
package_dependencies="false"

while [ $# -gt 0 ]; do
  case $1 in
  -t | --target)
    target="$2"
    shift
    ;;
  -p | --package-dependencies)
    package_dependencies="true"
    ;;
  *)
    echo "$help"
    exit
    ;;
  esac
  shift
done

branch="$(git branch | grep ^\* | sed 's@.* @@')"
if [ "${branch}" = "master" ]; then
    version="$(grep '<version>' ../pom.xml | head -n1 | sed "s@.*>\(.*\)</.*@\1@")"
elif [ -z "${branch}" ]; then
    version="SNAPSHOT"
else
    version="${branch}-SNAPSHOT"
fi
name="s3-cleanup"

dist="${target}/${name}-${version}.zip"

mkdir -p "$(dirname "${dist}")"

# Setup Python virtual environment
echo "=> Setting up Python virtual environment"
python3.6 -m venv v-env
. "v-env/bin/activate"
echo

# Install dependencies
echo "=> Installing dependencies"
for dep in $(cat dependencies.txt); do
    pip3 install "${dep}"
done
echo

# Deactivate the virtual environment
echo "=> Deactivating Python virtual environment"
deactivate
echo

# Package up the code
echo "=> Archiving the code"
rm -f "${name}.zip"
zip -r9 "${dist}" handler.py > /dev/null
echo

if [ "${package_dependencies}" = "true" ]; then
# Package up the dependencies
echo "=> Archiving dependencies"
cd v-env/lib/python3.6/site-packages
  zip -rg "${dist}" . > /dev/null
cd "${topdir}"
fi
