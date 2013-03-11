#!/bin/bash

SCRIPTDIR=$(dirname $0)

# Enter parent of scriptdir
cd $SCRIPTDIR/.. || {
    echo "Failed to cd into $SCRIPTDIR"
    exit 1
    }

# Why use perl instead of sed? Portability and the ugliness that is
# Basic Regular Expressions vs Extended Regular Expressions and GNU extensions
#
# 1. Simple PCRE regex:
#     "[a-zA-Z/.-]+(([\d]+\.)+([\d]+)?)"
#
# 2. GNU sed (less readable)
#     "[a-zA-Z/.-]\+\(\([0-9]\+\.\)\+\([0-9]\+\)\)"
#
# 3. BSD sed (even less readable)
#     "[a-zA-Z/.-]\{1,\}\(\([0-9]\{1,\}\.\)\{1,\}\([0-9]\{1,\}\)\)"
#
# You could argue to use Extended Regular Expressions, but unfortunately the
# switches for gnu sed and bsd sed are different, -r and -E respectively,
# requiring a conditional to determine OS.
REGEX='([a-zA-Z/.-]+)(([\d]+\.)+([\d]+)?)'

DIR=`pwd`

if echo $DIR | grep -qP $REGEX; then
  NAME=$(basename $(echo $DIR | perl -pe "s#${REGEX}#\$1#") | perl -pe 's/-$//')
  VERSION=$(echo $DIR | perl -pe "s#${REGEX}#\$2#")
else
  echo "ERROR: Directory ${DIR} does not have a valid version number"
  echo "Please rename the directory to something like the following:"
  echo "  ${DIR}-1.2.3"
  exit 1
fi

{
cd .. &&
tar -c -z --exclude='*/.git*' --exclude='*/debian*' \
    -f ${NAME}_${VERSION}.orig.tar.gz ${NAME}-${VERSION}/ &&
echo "Created original source tarball at `pwd`/${NAME}_${VERSION}.orig.tar.gz"
}
