{
  writeShellScriptBin,
  lib,
  rpi-otp-private-key,
  openssl
}:
writeShellScriptBin "rpi-otp-provision-private-key" ''
  export PATH="${
    lib.makeBinPath ([
      rpi-otp-private-key
      openssl
    ])
  }:$PATH"
  
  # Generate a random key...
  RANDOM_KEY=$(openssl rand -hex 32)
  if [ "''${#RANDOM_KEY}" -ne "32" ]; then
    echo "Failed to generate random key"
    exit 2
  fi
  # And write it to OTP.
  rpi-otp-private-key -w "$RANDOM_KEY"
''
