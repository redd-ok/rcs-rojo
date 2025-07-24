# RCS - Redds Combat System

An unfinished but working, optimized rewrite of ACS.

[Discord Server](https://discord.gg/6rV3bdV9dP)

## Compilation

To test out the latest commits, you'll need to compile RCS yourself.

[Rokit](https://github.com/rojo-rbx/rokit) is used for toolchain management. You should install it if you don't want to install Rojo and/or Blink manually.

1. Clone the repository and enter the repo directory.
2. Run:
   ```sh
   rokit install
   ```
   to install Blink and Rojo.
3. Run:
   ```sh
   blink main
   ```
   to generate the networking code.
4. Run:
   ```sh
   rojo build rcs.rbxlx
   ```
   to compile the place.

## Live Sync

If you want to contribute, your best bet for testing is live sync, so you don't have to compile every time you change a file. As before, you'll need [Rokit](https://github.com/rojo-rbx/rokit).

1. Clone the repository and enter the repo directory.
2. Run:
   ```sh
   rokit install
   ```
3. Run:
   ```sh
   blink main
   ```
4. Run:
   ```sh
   rojo build rcs.rbxlx
   ```
5. Run:
   ```sh
   rojo plugin install
   ```
   to install the Rojo Plugin, or install it from the Toolbox.
6. Open the Roblox Place and run:
   ```sh
   rojo serve
   ```
7. Connect to the Rojo server from the Rojo plugin.

## Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.
