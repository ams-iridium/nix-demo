{ ... }: 
{
  users.users.adam = {
    isNormalUser = true;
    description = "Test account for Adam Schafer";
    # Sudo access
    extraGroups = [
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJMjtOqSWLDq79t/9XljmBrfBVm8deQJdOQmTV7c45Ni adam" # content of authorized_keys file
    ];
  };
}