+++
title = "Custom Keyboard V1"
description = "A fully custom keyboard, designed and built by me."
weight = 1
+++

# Custom Keyboard V1
This keyboard is a semi split design (both halves on the same PCB but with some distance between them). It supports n-key rollover but other than that does not have any fancy features like RGB lighting.

## Hardware
For this project, I designed a custom circuit board using [KiCad](https://www.kicad.org/) that I then got printed using [JLCPCB](https://jlcpcb.com/).

I used the [Raspberry Pi Pico 1](https://www.raspberrypi.com/products/raspberry-pi-pico/) for the keyboard's microcontroller.

## Software
I briefly experimented with writing the firmware by hand in C, but ultimately decided to use [QMK](https://qmk.fm/) to simplify the process and take care of the direct hardware communication, allowing me to focus on things like configuring the key map the way I wanted it.

---

See also, [the second version of this project](/projects/3-keyboard-v2) which is much more feature-rich.
