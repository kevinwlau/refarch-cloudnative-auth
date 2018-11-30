#!/bin/bash
sed -i -E  's|location="'"$TRAVIS_BUILD_DIR"'/BCKeyStoreFile.jks"|location="/etc/keystorevol/BCKeyStoreFile.jks"|g' ./src/main/liberty/config/server.xml
echo done!
