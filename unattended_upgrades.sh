#!/usr/bin/env bash

sudo apt install -y unattended-upgrades
systemctl status unattended-upgrades

# configure unattended upgrades

cat > 50unattended-upgrades << 'EOM'
Unattended-Upgrade::Allowed-Origins {
        "${distro_id}:${distro_codename}";
        "${distro_id}:${distro_codename}-security";
        // Extended Security Maintenance; doesn't necessarily exist for
        // every release and this system may not have it installed, but if
        // available, the policy for updates is such that unattended-upgrades
        // should also install from here by default.
        "${distro_id}ESMApps:${distro_codename}-apps-security";
        "${distro_id}ESM:${distro_codename}-infra-security";
        "${distro_id}:${distro_codename}-updates";
//      "${distro_id}:${distro_codename}-proposed";
//      "${distro_id}:${distro_codename}-backports";
};

// List of packages to not update (regexp are supported)
Unattended-Upgrade::Package-Blacklist {
};

// This option will controls whether the development release of Ubuntu will be
// upgraded automatically.
Unattended-Upgrade::DevRelease "false";

// Do automatic removal of new unused dependencies after the upgrade
// (equivalent to apt-get autoremove)
Unattended-Upgrade::Remove-Unused-Dependencies "true";

// Remove unused automatically installed kernel-related packages
// (kernel images, kernel headers and kernel version locked tools).
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";

// Automatically reboot *WITHOUT CONFIRMATION*
//  if the file /var/run/reboot-required is found after the upgrade
//Unattended-Upgrade::Automatic-Reboot "true";

// If automatic reboot is enabled and needed, reboot at the specific
// time instead of immediately
//  Default: "now"
//Unattended-Upgrade::Automatic-Reboot-Time "04:00";
EOM
sudo mv 50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades

# enable autoupgrades

cat > 20auto-upgrades << 'EOM'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradable-Packages "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOM
sudo mv 20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades

# test automatic upgrades

sudo unattended-upgrades --dry-run --debug
