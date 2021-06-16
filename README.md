amx_uptime
==========

Welcome to the open-source repository for FacuArmo's servers' uptime plugin.

Feel free to look around the code, make improvements and provide suggestions and feedback.

## Introduction

This plugin lets you keep track of your server's uptime by saving the start time on a server-only CVAR and providing easy-to-use client and server commands.

## Screenshots

*Getting the uptime from the client by saying **/uptime***
[![https://i.ibb.co/pLc95PG/image.png](https://i.ibb.co/pLc95PG/image.png)](https://imgbb.com/)

*Resetting the uptime as an administrator with the "`l`" flag (`ADMIN_RCON`) from the client*
[![https://i.ibb.co/BtLGgwR/image.png](https://i.ibb.co/BtLGgwR/image.png)](https://imgbb.com/)
[![https://i.ibb.co/89SFMZc/image.png](https://i.ibb.co/89SFMZc/image.png)](https://imgbb.com/)
[![https://i.ibb.co/5xnTThn/image.png](https://i.ibb.co/5xnTThn/image.png)](https://imgbb.com/)

## Dependencies

- AMX Mod X version **1.8.2 or greater**

## Commands

#### Client

- `say /uptime` - reports the server uptime to the player console and its chat
- `say /resetuptime` - resets the server uptime back to the current time **&ast;**
- `amx_uptime` - reports the server uptime to the player console and its chat
- `amx_uptime_reset` - resets the server uptime back to the current time **&ast;**

#### Console

- `amx_uptime` - posts the server uptime to the internal console
- `amx_uptime_raw` - posts the server uptime to the internal console as a raw epoch timestamp
- `amx_uptime_reset` - resets the server uptime back to the current time **&ast;**

###### **&ast;** All variants of the uptime reset commands do have a second check that you should be aware of, please refer to the CVARs below for more information.

## CVARs

- `server_start_time` - keeps track of the server start timestamp which is used to calculate the uptime upon request, this CVAR is protected from client-side changes and shouldn't be manipulated manually.
- `reset_uptime_enable` - an administrator of the server console or an administrator with a client whose flags allow it to use the `amx_rcon` command **must** set this CVAR to "`true`" in order to authorize itself or any other administrator to execute any of the variants of the uptime reset commands. Once the uptime is reset, this CVAR will get back to "`false`".

## Installation

- Drop the plugin inside of your addons/amxmodx/plugins folder
- Edit your plugins.ini (inside of addons/amxmodx/configs) and add its filename (amx_uptime.amxx)
- Restart your server or change the level to initialize it

## Development

On its current stage, the plugin is completely stable and usable. If you're planning on contributing, passing "debug" next to the filename within plugins.ini will provide you most of the unhandled exceptions that might occur.

## Contributions

If you liked the plugin or you feel like there's anything to improve on or optimize, feel free to provide your suggestions or, better yet,  **submit a pull request to the repo!**

## Credits

- To the writers of the [documentation for the AMX Mod X API]("https://www.amxmodx.org/api/amxmodx/") for providing useful resources to start with.

## License

This project is licensed under the [GNU Affero General Public License v3.0](LICENSE).