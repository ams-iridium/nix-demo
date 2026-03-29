{
  writeShellScriptBin,
  lib,
  rpi-otp-private-key
}:
writeShellScriptBin "rpi-otp-luks-key" ''
  export PATH="${
    lib.makeBinPath ([
      rpi-otp-private-key
    ])
  }:$PATH"

  # Exit on any error
  set -e
  # The '-c' flag ensures the key is not all 0s.
  rpi-otp-private-key -c 
  RPI_OTP_SECRET=$(rpi-otp-private-key)
  echo "${luksKeySalt}$RPI_OTP_SECRET" | sha256sum | tr -d ' -'
  echo 'this is the package directory'
''