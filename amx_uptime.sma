#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Uptime"
#define VERSION "1.6"
#define AUTHOR "Facundo Montero (facuarmo)"

/*
 * Global TODOs:
 *
 * - Hope it doesn't break.
 */

const FLAG_MANAGER_OPT_IN = 1;

const ONE_SECOND        = 1;
const SECONDS_IN_MINUTE	= 60;
const SECONDS_IN_HOUR	= SECONDS_IN_MINUTE * 60;  // 3600    	=> 1 minute = 60 seconds
const SECONDS_IN_DAY	= SECONDS_IN_HOUR   * 24;  // 86400   	=> 1 day    = 24 hours
const SECONDS_IN_WEEK  	= SECONDS_IN_DAY    * 7;   // 604800  	=> 1 week   = 7 days
const SECONDS_IN_MONTH 	= SECONDS_IN_WEEK   * 4;   // 2419200	=> 1 month  = 4 weeks
const SECONDS_IN_YEAR  	= SECONDS_IN_MONTH  * 12;  // 29030400	=> 1 year   = 12 months

// Sometimes, the clock counting might start a bit off, we don't want to count that as an overflow.
const INVALID_INTEGER_OFFSET = -3600;

new
	cvar_server_start_time,
	cvar_reset_enable,
	time_spent,
	ts_str[512], aux_str[128],
	do_subtraction = true;

/*
 * This function builds a pair of time information in the following format:
 *
 * <multiplier_hits> <label>[s]
 *
 * Producing the following kind of results:
 * 1 second
 * 5 seconds
 *
 * This result is, then, concatenated to "ts_str". "time_spent" gets subtracted the amount of
 * "mutliplier hits" by the passed "multiplier" so that we're left with the remaining time, which
 * is what's still left to process.
 *
 * @param int	 multiplier
 * @param String label[]
 *
 * @return void
 */
public process_time(multiplier, label[32]) {
	new multiplier_hits = 0;

	if (time_spent > multiplier) {
		multiplier_hits = time_spent / multiplier;

		time_spent -= multiplier_hits * multiplier;
	}

	num_to_str(multiplier_hits, aux_str, 128);

	strcat(ts_str, aux_str, 512);

	strcat(ts_str, " ", 512);

	strcat(ts_str, label, 512);

	if (multiplier_hits > 1 || multiplier_hits == 0) {
		strcat(ts_str, "s", 512);
	}

	if (!equali(label, "second")) {
		if (equali(label, "minute")) {
			strcat(ts_str, " and ", 512);
		} else {
			strcat(ts_str, ", ", 512);
		}
	}
}

/*
 * @return void
 */
build_uptime(do_parsing = true) {
	if (do_subtraction) {
		time_spent = get_systime() - get_pcvar_num(cvar_server_start_time);
	}

	/*
	 * This is because at this point the integer would overflow to a negative value.
	 *
	 * For more information, please refer to the following page:
	 * https://docs.microsoft.com/en-us/cpp/c-language/cpp-integer-limits?view=msvc-160
	 *
	 * Pay close attention to the section that talks about INT_MAX.
	 */
	if (time_spent <= INVALID_INTEGER_OFFSET) {
		ts_str = "more than 68 years.";

		/*
		 * We'll stop trying to do the subtraction, it's a waste of resources and it might
		 * overflow into a positive number after 68 years pass again.
		 */
		do_subtraction = false;
	} else if (do_parsing) {
		ts_str = "";

		process_time(SECONDS_IN_YEAR,	"year");
		process_time(SECONDS_IN_MONTH,	"month");
		process_time(SECONDS_IN_WEEK,	"week");
		process_time(SECONDS_IN_DAY,	"day");
		process_time(SECONDS_IN_HOUR,	"hour");
		process_time(SECONDS_IN_MINUTE,	"minute");
		process_time(ONE_SECOND,	"second");
	
		strcat(ts_str, ".", 512);
	} else {
		num_to_str(time_spent, ts_str, 512);
	}
}

/*
 * @return int
 */
public print_uptime_console() {
	build_uptime();

	server_print("Uptime: %s", ts_str);

	return PLUGIN_HANDLED;
}

/*
 * @return int
 */
public print_uptime_console_raw() {
	build_uptime(false);

	server_print(ts_str);

	return PLUGIN_HANDLED;
}

/*
 * @param int player_id
 *
 * @return int
 */
public print_uptime_player(player_id) {
	if (!is_user_admin(player_id)) {
		return PLUGIN_CONTINUE;
	}

	build_uptime();

	client_print(player_id, print_console, "Uptime: %s", ts_str);
	client_print(player_id, print_chat, "Uptime: %s", ts_str);

	return PLUGIN_HANDLED;
}

/*
 * This method sends a message to a player through both channels (console and chat).
 *
 * @param int	 player_id
 * @param String message[]
 */
public send_message_multi(player_id, message[121]) {
	client_print(player_id, print_console, message);
	client_print(player_id, print_chat, message);
}

/*
 * @param int player_id
 *
 * @return int
 */
public reset_uptime_player(player_id)  {
	if (!is_user_admin(player_id)) {
		return PLUGIN_CONTINUE;
	}

	new msg_chunk_a[121], msg_chunk_b[121], enabled[4];

	get_pcvar_string(cvar_reset_enable, enabled, 4);

	if (equali(enabled, "true")) {
		set_pcvar_num(cvar_server_start_time, get_systime());

		set_pcvar_string(cvar_reset_enable, "false");

		send_message_multi(player_id, "The uptime has been successfully reset.");
	} else {
		// Yeah I mean, is this code terrifying? Yes. But, does it work? Yes it does!
		msg_chunk_a = "The required CVAR isn't set, to use this command please run 'amx_rcon reset_uptime_enable true' from the client console,";
		msg_chunk_b = "or 'reset_uptime_enable true' from the server console, then, try again.";

		send_message_multi(player_id, msg_chunk_a);
		send_message_multi(player_id, msg_chunk_b);
	}

	return PLUGIN_HANDLED;
}


/*
 * @return int
 */
public reset_uptime_console()  {
	new msg_chunk_a[121], msg_chunk_b[121], enabled[4];

	get_pcvar_string(cvar_reset_enable, enabled, 4);

	if (equali(enabled, "true")) {
		set_pcvar_num(cvar_server_start_time, get_systime());

		set_pcvar_string(cvar_reset_enable, "false");

		server_print("The uptime has been successfully reset.");
	} else {
		server_print("The required CVAR isn't set, to use this command please run 'amx_rcon reset_uptime_enable true' from the client console, or 'reset_uptime_enable true' from the server console, then, try again.");
	}

	return PLUGIN_HANDLED;
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

	new start_time_str[512];

	num_to_str(get_systime(), start_time_str, 512);

	cvar_server_start_time = register_cvar("server_start_time", start_time_str, FCVAR_SPONLY);
	cvar_reset_enable = register_cvar("reset_uptime_enable", "false", FCVAR_SPONLY);


	register_srvcmd("amx_uptime", "print_uptime_console", ADMIN_RCON, "- posts the server uptime to the internal console");
	register_srvcmd("amx_uptime_raw", "print_uptime_console_raw", ADMIN_RCON, "- posts the server uptime to the internal console as a raw epoch timestamp");
	register_srvcmd("amx_uptime_reset", "reset_uptime_console", ADMIN_RCON, "- resets the server uptime back to the current time");

	register_clcmd("amx_uptime", "print_uptime_player", ADMIN_ALL, "- reports the server uptime to the player console and its chat", FLAG_MANAGER_OPT_IN);
	register_clcmd("say /uptime", "print_uptime_player", ADMIN_ALL, "- reports the server uptime to the player console and its chat", FLAG_MANAGER_OPT_IN);

	register_clcmd("amx_uptime_reset", "reset_uptime_player", ADMIN_ALL, "- resets the server uptime back to the current time", FLAG_MANAGER_OPT_IN);
	register_clcmd("say /resetuptime", "reset_uptime_player", ADMIN_ALL, "- resets the server uptime back to the current time", FLAG_MANAGER_OPT_IN);
}