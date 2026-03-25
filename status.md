Current status:

* Able to boot to NVME with addition encrypted LUKS data partition
* Using lazy 12345 hardcoded password

Next step:

* Modify luks `preOpenCommands` to load the device unique private key into /run
  * You'll need to figure out how to inject [rpi-otp-private-key](https://github.com/raspberrypi/rpi-eeprom/blob/master/tools/rpi-otp-private-key) and vcmailbox into initrd.
* Check if EFI System Partition (ESP) is necessary
  * IDK if NixOS needs it at all to boot.  This is all stuff you'll need to figure out for the secureboot impelmentation, but it'll be nice to know now if we need this partition.