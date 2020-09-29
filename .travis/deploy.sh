#!/bin/bash -ex

ls -al artifacts/
wget -c https://github.com/tcnksm/ghr/releases/download/v0.13.0/ghr_v0.13.0_linux_amd64.tar.gz
tar xfv ghr_v0.13.0_linux_amd64.tar.gz      
version=$(ls artifacts/version |grep Yuzu-EA | cut -d "-" -f 3 | cut -d "." -f 1) 
ghr_v0.13.0_linux_amd64/ghr -recreate -n 'Continous build' -b "Travis CI build log ${TRAVIS_BUILD_WEB_URL}" continuous artifacts/
ghr_v0.13.0_linux_amd64/ghr -n "Continuous build (EA-$version)" -b "Travis CI build log ${TRAVIS_BUILD_WEB_URL}" EA-$version artifacts/version/
