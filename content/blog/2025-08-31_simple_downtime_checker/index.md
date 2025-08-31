+++
title = "Super Simple Downtime Checker"
description = "A ridiculously simple downtime checker in only 6 lines of Bash (with optional NixOS and Systemd integration). It runs on your desktop, so no self-hosting needed."
date = 2025-08-31
+++

# Super Simple Downtime Checker

## Why?
So, recently I made a website. I would like an automated way to make sure it's still online. Nothing fancy, I just want to make sure it hasn't self-destructed.

There are plenty of services that can do this, however I don't need any of the fancy features that these services offer. And, for my purposes, most of them are just overkill.

The solution I have come up with is a simple 6-line bash script that just checks the [HTTP response code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status) of my website to make sure it is [200 OK](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/200).

## Making The Script
So, the core part of this program will be something that sends a request to the server and gets a response back. One option would be to use the `ping` command. However, while this would tell us if the server was switched on or not, it would not allow us to receive HTTP response codes such as [404 Not Found](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/404), [418 I'm a teapot](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/418), or other similarity critical errors.

The solution I found uses `curl` with the `-I` (or `--head`) option. This allows us to view HTTP response codes (like 404 not found), along with a lot of other miscellaneous information that I don't need for this particular script.

```bash
curl -I "https://olliehunt.dev/"

HTTP/2 200
server: GitHub.com
content-type: text/html; charset=utf-8
last-modified: Wed, 27 Aug 2025 20:33:10 GMT
---OUTPUT TRUNCATED---
```

As we don't need most of this information, we can extract just the response code from this command's output by piping `curl`'s output through some other commands:

```bash
$ curl -Is "https://olliehunt.dev/" | head -n 1 | xargs

HTTP/2 200
```

Let's break that line down: Firstly, the `-s` option on `curl` is used to suppress its loading bar. Secondly, the `head` command is used to extract just the first line from `curl`'s output. Finally, `xargs` is used to strip any whitespace that could mess up a string comparison in an if statement. And speaking of if statements...

```bash
if [[ $(curl -Is "https://olliehunt.dev/" | head -n 1 | xargs) == "HTTP/2 200" ]]; then
  echo "Success!"
else
  echo "Failure :("
fi
```

We now have a functional script! There are still a couple of improvements we could make though...

Right now, this script will only work with one URL. The simplest, and easiest way I could think to solve this was to use Bash's `$@` variable. This variable simply contains all the arguments passed to the script. This is not perfect and is probably not how you are meant to handle arguments, but it does get the job done.

```bash
if [[ $(curl -Is "$@" | head -n 1 | xargs) == "HTTP/2 200" ]]; then
  echo "Success!"
else
  echo "Failure :("
fi
```

We can now simply call our script from the command line, specifying any URL we want to check:

```bash
$ bash ./path/to/script.sh "https://olliehunt.dev/"

Success!
```

```bash
$ bash ./path/to/script.sh "https://example.com/"

Failure :(
```

```bash
$ bash ./path/to/script.sh "https://www.wikipedia.org/"

Success!
```

## Automating
So obviously we don't want to have to manually run this script all the time, so how do we automate it?

Well there are many great options for this, and you can pick your favourite. I'm going to be using [systemd timers](https://wiki.archlinux.org/title/Systemd/Timers) (although [cron](https://en.wikipedia.org/wiki/Cron) is a great alternative if you don't like systemd). Additionally, as I'm running a [NixOS](https://nixos.org/) system, I will be setting everything up using the Nix programming language instead of manually creating `.service` and `.timer` files. Most general concepts I talk about here should still be applicable if you are not using NixOS, however.

### Notifications
Before we get to creating our systemd unit and timer, there is one last change that needs to be made to the script.

Currently, the success or failure is just echoed to stdout. For a script run in the commandline, this is fine. However, if we plan on running this script automatically in the background, the user won't be able to see stdout. For this we need to notify the user of issues some other way. Luckily, [libnotify](https://gitlab.gnome.org/GNOME/libnotify) provides an [excellent utility]((https://man.archlinux.org/man/notify-send.1)) called `notify-send` that allows us to send notifications from the command line. To use it, simply pass your message as an argument to the command. For example:

```bash
$ notify-send "Hello World!"
```

Here is the final script with `notify-send` added + some slightly more detailed error messages:

```bash
if [[ $(curl -Is "$@" | head -n 1 | xargs) == "HTTP/2 200" ]]; then
  echo "Success: $@ returned response code 200."
else
  echo "Failure: $@ did not return a response code of 200. Use 'curl -Is \"$@\"' for more info."
  notify-send "WARNING: $@ has returned a response code that is not 200!"
fi
```

### Systemd/NixOS Integration
As I mentioned earlier, I will be using systemd and NixOS for automatically running the script.

I don't really have much to talk about in this section. Just copy this into your NixOS system config and it *should* just work. I'll let the code comments do the explaining:

> [!NOTE]
> In case you are not familiar with the process of turning a script into a
> systemd unit using NixOS, here is an excellent article that I used to learn:
> [https://blog.withsam.org/blog/nixos-systemd-local-script/](https://blog.withsam.org/blog/nixos-systemd-local-script/)

```nix
{
  # This is the timer will run `downtime-check.service` every hour
  systemd.user.timers."downtime-check" = {
    wantedBy = [ "timers.target" ];

    timerConfig = {
      # Timer runs every hour
      OnActiveSec = "1h";
      OnUnitActiveSec = "1h";

      # This service will be activated every time the timer triggers
      Unit = "downtime-check.service";
    };
  };

  # This is the service that will actually call the script we made earlier
  systemd.user.services."downtime-check" = {
    # List of packages this unit needs access to
    path = with pkgs; [
      bash
      libnotify
      curl
      coreutils-full
      findutils
    ];

    # Call the script we made earlier.
    # You can call the script multiple times here to check multiple URLs.
    script = "bash ${./path/to/script.sh} https://olliehunt.dev/";

    serviceConfig = {
      # Ensure this script will just run once and then exit
      Type = "oneshot";
    };
  };
}
```

This should run every hour in the background and notify you of any problems with your website(s).
