# RCS - Redds Combat System

An unfinished but still working complete optimized rewrite of ACS

[Discord Server](https://discord.gg/6rV3bdV9dP)

# Setup with rojo (This section is a W.I.P.)

[Pesde](https://pesde.dev/) is used for toolchain managment, you should install it if you dont want to install rojo and blink manually.

1. Clone the repository
2. Run `pesde install` to install blink and rojo
3. Run `rojo plugin install` to install a local version of the rojo roblox plugin (alternatively you can install the [toolbox version](https://create.roblox.com/store/asset/13916111004/Rojo))
4. Run `blink main` to generate the networking code

Now you can open roblox studio, run `rojo serve` and connect via the rojo roblox plugin. \
You have to run `blink main` every time you change `main.blink`, or run `blink main --watch` to have it automatically generate on save.