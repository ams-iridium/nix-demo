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
  OPTIONAL_SALT="$1"
  # The '-c' flag ensures the key is not all 0s.
  rpi-op-private-key -c 
  RPI_OTP_SECRET=$(rpi-otp-private-key)
  echo "''${OPTIONAL_SALT}$RPI_OTP_SECRET" | sha256sum | tr -d ' -'
  echo 'this is the package directory'
''