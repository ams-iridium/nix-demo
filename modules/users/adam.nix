{ home-manager, ... }: 
{
  imports = [
    home-manager.nixosModules.default
  ];
  
  users.users.adam = {
    isNormalUser = true;
    description = "Test account for Adam Schafer";
    # Sudo access
    extraGroups = [
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEIZguw99/6zgkQB92pt/hrnHQ7dUq5st9B3FnvC9aW1XGugx8WUfHRikdjNGRxWm2EtFvZvy+WdQpsJf3bgLP7scybYdOqL1qFhIPPKte7KI8CHKZXCBK/bM0z5plvdoR4XdeYA7ByNKuiCr3WUtv7jFzmK2lh34gmFngObFs1AFN//UCwLxLJcGJR9gjebIJ84it08QjbmnGBUaHGuiOPyRb1YPOzPXSXE6VsFXvbzbCrGCh4IhVP1t5zjsEbQsRtM+A407Cs/VOP7ktEvBa5/RfefvXDzWM5e+AlKILr3gYqDoo8QRzeRXKanWSGiCLnM5iUMBXz1CjyC+Os5EHMcEDo4P8d42EI9bWtbpv7Ek7m/Hc2tGEshYgr7I7b5zQb4+I9n3NaIaMfL0OvtANh1ZpFjJ3Df/sr/HatByqbWDocC0FwI7t2+S39QH04AvE2Nm/9qhtEC+O7Zkz9iNSWSL41Juq/LTCL5+45r67SWJCi/1CeIgk3jSfa71Hzy6YbVE6G4ifHwrqDpNo5BJVk9VwXhVHHu56bEy5ZYk+qMnxAcFyRvCx6AzV8VnqXSfe+4tYcZx4S+fv/PSnM1dTJPn0BXN+/g1ReEghgZVlu7OAC4dnBFUHBd74T9oU/OcAxR2NZDg6L6P+yQsYF4vZFlWI+PO929HA11z4waJWAw=="
    ];
  };

  # Home Manager integration
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.adam = import ../../home/adam.nix;
}