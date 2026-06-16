+++
title = "Unobtrusive Nix Dev Shells"
description = "How to manage Nix development flakes outside of your projects repo for better flake reusability and how to not annoy your team."
date = 2026-06-02
updated = 2026-06-16

[[extra.updates]]
date = 2026-06-16
change_note = "Minor change to code formatting"
+++

# Unobtrusive Nix Dev Shells

## Intro
One of the many, many cool things you can do with Nix is create [dev shells](https://wiki.nixos.org/wiki/Development_environment_with_nix-shell). These allow you to quickly and easily create reproducible environments in which to do your development.

I love this feature a lot. However, I don't love having to create a separate dev shell for each project even if they have the exact same set of dependencies. I also don't love having `flake.nix` and `flake.lock` files cluttering up the root of the project I'm working on. Additionally, if you're working on a project in a team with people who don't use Nix, your team members will likely be less than thrilled at you messing up their wonderfully organised project with files only you see a use in.

So how can we address all these problems? Well the most obvious solution is simply to keep the dev shell `.nix` files *not* in the project your working on. Of course, if your doing that, then you will also want some way of entering the dev shell as easily as if it was in the project's root directory.

In this post, I will write about how I've chosen to go about solving this problem in case it's also useful for you.

> [!NOTE]
> In this post, I assume the use of [flakes](https://wiki.nixos.org/wiki/Flakes). I will not be specifically covering how to do this without fakes, although I'm sure a lot of this could be easily adapted if you want.

## The Dev Shells
So, first things first: Where do we put the dev shell flakes?

Well, I've chosen to put mine in the same repo as the rest of my NixOS system config, but you don't have to do this. Any single central location will do. I recommend laying out the file structure something along these lines:

```
dev_shells/
  rust/
    flake.nix
    flake.lock
  my_other_dev_shell/
    flake.nix
    flake.lock

scripts/
  dev.sh
```

So basically, one flake per directory + somewhere to put a script (we'll cover the script in the next section).

Bellow, I've included an example of a minimal flake for a [Rust](https://rust-lang.org/) development shell. I won't be covering how to write flakes or dev shells in this post, but [here's](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/introduction-to-flakes) a good tutorial.

```nix
{
  description = "Dev shell for writing rust code";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ self, nixpkgs, ... }: let
    system = "x86_64-linux";
  in {
    devShells.${system}.default = let
      pkgs = import nixpkgs { inherit system; };
    in pkgs.mkShell {
      packages = with pkgs; [
        cargo
        rust-analyzer # LSP
        rustc
      ];
    };
  };
}
```

## Easily Accessing Dev Shells
This is the core of this solution. The idea is that you can just `cd` into your project and run a script from your PATH that will automatically dump you in a shell of your choosing.

I've chosen to use [`fzf`](https://github.com/junegunn/fzf) to allow the user to pick a shell from a list. To ensure that `fzf` is available to the script, we can use a [Nix-shell shebang](https://wiki.nixos.org/wiki/Nix-shell_shebang) at the very start of the script.

```bash
#! /usr/bin/env nix-shell
#! nix-shell -i bash -p fzf
```

We now need to give `fzf` a list of all the available shells so it can present them to the user. To do this, we can use the `FZF_DEFAULT_COMMAND` environment variable to show `fzf` how to find the shells. We can then capture the output from `fzf` in a variable.

```bash
DEV_SHELL_DIR=/path/to/your/dev_shells

# Ask user to choose a development shell
FLAKE_NAME=$(FZF_DEFAULT_COMMAND="ls $DEV_SHELL_DIR" fzf)
echo "Chosen flake: $FLAKE_NAME"
```

Next, we can simply pass the chosen flake to `nix develop` like so:

```bash
nix develop "$DEV_SHELL_DIR/$FLAKE_NAME"
```

And for the sake of easy copy paste, here's the complete script (plus an extra check in case the user does not select anything form `fzf`).

```bash
#! /usr/bin/env nix-shell
#! nix-shell -i bash -p fzf
DEV_SHELL_DIR=/etc/nixos/runtime/dev_shells

# Ask user to choose a development shell
FLAKE_NAME=$(FZF_DEFAULT_COMMAND="ls $DEV_SHELL_DIR" fzf)

# If no flake selected by user, then exit
if [[ -z "$FLAKE_NAME" ]]; then
  echo "ERROR: No dev shell selected"
  exit 1
fi

# Enter dev shell
nix develop "$DEV_SHELL_DIR/$FLAKE_NAME"
```

This script is fairly minimal. However, there are a fair few improvements that can be made. For example, adding support for different shells (e.g. Fish) is possible. I won't cover this here though, and will instead just leave it as an exercise for the reader.

### Getting The Script Into Your PATH
So, this script is great and all, but we need an easy way to run it.

If you're using [Home Manager](https://github.com/nix-community/home-manager) and chose to store your flakes in the same directory as your NixOS config, then you can do something along the lines of:

```nix
{
  home.file.".local/bin/dev" = {
    enable = true;
    executable = true;
    source = ./path/to/dev.sh;
  };

  # Make sure files in config.xdg.binHome (~/.local/bin) are in PATH.
  xdg.localBinInPath = true;
}
```

I'm sure there are many other ways of achieving this (with and without Home Manager), but this is the one I use.

With this in place, you should now be able to just `cd` into your projects and simply run `dev` to start a dev shell of your choice.
