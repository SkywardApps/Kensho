#/bin/sh
svn revert --depth infinity html
svn up
cd html
make install
