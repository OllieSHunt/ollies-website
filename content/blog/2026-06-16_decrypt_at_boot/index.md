+++
title = "Automatically Decrypting Drives at Boot in NixOS via External Keyfile"
description = "How to automatically decrypt a drive at boot using a keyfile located on an external device with password fallback. Compatible with NixOS Systemd stage 1 boot. (+ bonus stuff I leaned while doing this)"
date = 2026-06-16
+++

# Automatically Decrypting Drives at Boot in NixOS via External Keyfile
In this post, I will briefly summarise how to automatically decrypt an encrypted drive at boot in NixOS using a keyfile located on an external drive/USB stick. I will also show how to fall back to a password if this drive can't be found.

The [NixOS Wiki's](https://wiki.nixos.org/wiki/Full_Disk_Encryption#Unattended_Boot_via_USB) current example for doing this assumes that `boot.initrd.systemd.enable` is set to `false` (as of 2026-06-16). However, as the default for this option is now `true` and the wiki's example no longer works, I thought I'd make this.

## The Solution

In case you just want something to copy-paste, here it is:

```nix
{
  # Kernel modules needed for mounting USB ext4 devices in initrd stage.
  # (modified from wiki's vfat example)
  # (not sure if all these are necessary, feel free to test and email me)
  boot.initrd.kernelModules = ["uas" "usbcore" "usb_storage" "ext4" "nls_cp437" "nls_iso8859_1"];

  # This assumes that "my_drive" has been setup correctly somewhere else
  # (e.g. has `boot.initrd.luks.devices."my_drive".device` set).
  boot.initrd.luks.devices."my_drive" = {
    # Will auto mount partition if it can't be found.
    # Please note that the path to keyfile is relative to the root of the drive,
    # not the root of your main filesystem!
    keyFile = "/my_key:PARTUUID=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";

    # Time to wait before falling back to manual password input.
    # I find 2 seconds is too short, but 5 works for me. You may need to play
    # around with this value.
    keyFileTimeout = 5;
  };
}
```

## Some More Detail
### Finding this Solution
My first assumption when figuring this out was to mount the keyfile containing drive using `boot.initrd.systemd.mounts`. And I *was* able to get this to mount the external USB stick and decrypt my drive... But unfortunately, I could not get rid of the 90 second wait before falling back to a manual password input if the keyfile drive was not plugged in.

I think this might be due to some implicit dependency created between the drive decryption unit and the USB stick mounting unit, but I'm not sure about this.

Whatever the reason, `boot.initrd.systemd.mounts` turned out not to be the way forward anyway, and removing it solved all my problems. I also experimented with creating a custom service triggered by a udev rule, but this was also a dead end and also very much over-complicating things.[^1]

As it turns out, Systemd will automatically mount keyfile containing drives specified in [`crypttab`](https://www.man7.org/linux/man-pages/man5/crypttab.5.html) with no manual intervention needed.[^2]

### The Keyfile
In the example given above, you will notice this line:

```nix,hide_lines=1 3
{
keyFile = "/my_key:PARTUUID=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
}
```

Here, there are two important things to note:
1. The keyfile path is relative to the root of your drive, and **not** the root of your main filesystem.
2. The section after the colon can be any [fstab style identifier](https://www.man7.org/linux/man-pages/man5/fstab.5.html) (e.g. `PARTLABEL`, `LABEL`, etc...)

I've chosen to use partition UUID (`PARTUUID`) to locate my drive. You can find a drive's partition as well as a whole load of other useful info (such as label) by using this command.

```bash
# Replace `sdb1` with your drive/partition
udevadm info /dev/sdb1
```

You could also look through the subdirectories of `/dev/disk` to find a lot of the same stuff.

### Debugging Initrd Environments
Figuring out what is going on inside the initrd environment can be a bit challenging. One option for debugging would be to setup SSH access it and remotely (see [this article](https://wiki.nixos.org/wiki/Remote_disk_unlocking) on the NixOS Wiki), but it was sufficient for my use case to simply manually inspect the contents of the initrd image instead:

```bash
# List all images
sudo find /boot -type f -name "*-initrd-linux-*-initrd" -printf "%T+\t%p\n"

# Print contents of your chosen image
sudo nix shell nixpkgs#dracut --command lsinitrd <PATH_TO_YOUR_CHOSEN_IMAGE> |& less
```

This should give you a list of all files available in the initrd environment. Most of these will be symlinks to files in the nix store which you can simply view with `cat`/`bat` or your favourite editor.

For example, this file:

```
lrwxrwxrwx 1 root root 59 Jan 1 1970 etc/crypttab -> /nix/store/v0i2m45wp3wqd65pyk46d9bfbcj3qzam-initrd-crypttab
```

Can be viewed using:

```bash
cat /nix/store/v0i2m45wp3wqd65pyk46d9bfbcj3qzam-initrd-crypttab
```

> [!warning]
> At one point while messing around inside `/boot`, I managed to end up with an unbootable system and had to recover it
> manually. I'm still not sure what exactly I did, but be careful.
>
> **Mess with `/boot` at your own risk.**

[^1]: The [`man bootup`](https://www.freedesktop.org/software/systemd/man/latest/bootup.html) page was very helpful during the development and debugging process.

[^2]: NixOS will use the `boot.initrd.luks.devices` option to build you a `crypttab` file.
