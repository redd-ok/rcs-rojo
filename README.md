# RCS - Redds Combat System

An unfinished but still working complete optimized rewrite of ACS

# Setup with rojo

[Rokit](https://github.com/rojo-rbx/rokit) is used for toolchain managment, you should install it if you dont want to install rojo and blink manually.

1. Clone the repository
2. Run `rokit install` to install blink and rojo
3. Run `rojo plugin install` to install a local version of the rojo roblox plugin (alternatively you can install the [toolbox version](https://create.roblox.com/store/asset/13916111004/Rojo))
4. Run `blink main` to generate the networking code

Now you can open roblox studio, run `rojo serve` and connect via the rojo roblox plugin.
You have to run `blink main` every time you change `main.blink`, or run `blink main --watch` to have it automatically generate on save.

# Notes

I doubt I will work on this alot anymore, alot of things are unfinished and some parts of the code are ugly/messy.\
Sounds are most likely broken for you, you will have to reupload them yourselves.\
Attachments do work, however they are very unfinished.\
Medical system also works, but is aswell unfinished. There is no current way to heal from injuries right now, so I recommend you disable the medical system.\
Projectiles are multi-threaded and handled on the server, so you _shouldn't_ have any wallbanging cheaters.\
I have not stress tested this system with alot of players at all, I dont know the complete extents of my optimizations or how many players it can handle.\
You should disable the `Debug` config option in the config if you're going to use this in an actual game.
