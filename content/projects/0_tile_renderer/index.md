+++
title = "Tile Map Renderer"
description = "A top-down 3D tile map renderer written in WGSL and Rust."
weight = 0
+++

# Tile Map Renderer
This project was originally meant to be a [Dwarf Fortress](https://www.bay12games.com/dwarves/) clone written in [Rust](https://www.rust-lang.org/) using the [Bevy game engine](https://bevy.org/).

However I never really got to making the game itself and instead got sidetracked with designing a custom tile rendering solution using a [WGSL](https://en.wikipedia.org/wiki/WebGPU_Shading_Language) shader and custom Bevy rendering pipeline.

The final product was able to render a 3D world using 2D sprites across multiple layers similar to the graphical version of Dwarf Fortress. It also had support for sprites that changed the way they looked based on their neighbours, and a chunking system to dynamically extend the world as needed.
