#!/bin/bash

SDK_PATH=$(xcode-select --print-path)
echo $SDK_PATH
OS_VERSION=$(sw_vers -productVersion | cut -c 1-5)
echo $OS_VERSION

if [ -e /Applications/Xcode.app ]; then
  SDK_PATH=${SDK_PATH}/Platforms/MacOSX.platform/Developer/SDKs
  echo ${SDK_PATH}
  cd ${SDK_PATH}
  sudo ln -sF MacOSX.sdk MacOSX${OS_VERSION}.sdk
  cd -; ls -la ${SDK_PATH}
fi

