<h1>About</h1>

DraftBot facilitates an organized draft of players into teams similar to an entry draft in sports leagues. It is designed to level the playing field initially for each captain of each team regardless of their skill so that the final teams are a result of captain drafting skill and player knowledge only.

<h1>What is mIRC?</h1>
<a href = "http://www.mirc.com/">mIRC</a> is a popular client for the IRC protocol with a powerful event-based scripting language.

<h1>How it works</h1>
A number of players volunteer to captain a team (typically 12-20 teams of 8 or more). Once all captains are determined and players have signed up to play, all players including the captains are given a dollar value (salary) from $100-$1000 (or similar) based on their skill level. The difference in captain salaries determines the initial picking order with the cheapest captain picking first. Each team has a total salary cap which can be fully available to each team from the start (so that they can pick the highest-ranked player each round) or given in increments each round for more strategic picking. Each round the bot determines the pick order and each captain is allowed to pick one player per round (with the price restrictions which are known in advance). Pick order after the initial round is determined by total salary with the lowest total salary picking first. The draft is complete once each team has the predetermined number of players.
<h1>List of Features</h1>
<ul>
	<li>Total salary can be fully available to each team from the start or given in increments each round</li>
	<li>Each team can be given a set number of timeouts (2-3 minutes each) for extra time in deciding who to pick</li>
	<li>Round salary values can be automatically generated or manually entered</li>
	<li>Ability to change captains or pause the draft in the case of player disconnection from the IRC server</li>
	<li>Ability to restart draft in the case of bot disconnection</li>
	<li>Automatically moderates the channel once a draft starts and gives each captain voice when it is their turn to pick</li>
	<li>Connecting to the server as ($nick + 1) and ($nick + 2) i.e., draftbot1 and draftbot2, will use both nicks to output the messages. Useful on servers with prohibitive flood restrictions</li>
	<li>Automatic warnings when approaching the round timelimit and automatic picking of the highest salary player when the time is up</li>
	<li>A myriad of commands to facilitate the draft and aid each captain in their decision making. See <a href="#Usage">Usage</a> for a full list </li>
</ul>
<h1>Installation</h1>
<ol>
	<li>Place all files in the mIRC default scripts directory. This is the mIRC root folder for versions prior to 6.3 and %APPDATA%\mIRC for versions thereafter</li>
	<li>Type /load -rs draftbot.mrc in the server window</li>
	<li>Load up your IRC server of choice, join a channel and type: .setdraft on. <b> NOTE:</b> This bot works best on a network where it can be given the +B flag or similar permissions. If not, mIRC flood rules need to be enabled or the bot may be kicked for flooding</li>
</ol>
<h1>Example Usage</h1>
After joining the IRC server and channel of choice (preferably with unrestricted flood controls) the commands below are the bare minimum to get started:
<ol>
<li>.setdraft on</li>
<li>.fullreset</li>
<li>.makelist</li>
<li>.rounds 5100,4100,3100,2713,2326,1939,1552,1165,778,391,0</li>
<li>.captain irc_nick1 list_nick1</li>
<li>.captain irc_nick2 list_nick2</li>
<li>.captain irc_nick3 list_nick3</li>
<li>.startdraft</li>
</ol>

<h1>Command List</h1>
Command prefixes are <b>! and . only</b>. All OPs in the channel have access to all admin commands.

<h2>Basic Commands</h2>
<table>
	<tr><th>Command Syntax</th><th>Description</th></tr>
	<tr>
		<td>.commands</td>
		<td>Displays a shortened list of commands.</td>
	</tr>
	<tr>
		<td>.pick &lt;player&gt;</td>
		<td>Picks the specified player. Must match the name returned from a .range command.</td>
	</tr>
	<tr>
		<td>.range &lt;low_value-high_value&gt;</td>
		<td>Lists all players in the given price range.</td>
	</tr>
	<tr>
		<td>.order</td>
		<td>Lists the pickorder for the current round.</td>
	</tr>
	<tr>
		<td>.nextorder</td>
		<td>Lists the current pickorder for the next round. This list is incomplete until the round is over.</td>
	</tr>
	<tr>
		<td>.fpick &lt;player&gt;</td>
		<td>Returns how much you would have to spend in the next round if that person is picked. Does not actually pick the player.</td>
	</tr>
	<tr>
		<td>.find &lt;player&gt;</td>
		<td>Finds *player* in the playerlist.</td>
	</tr>
	<tr>
		<td>.timeout</td>
		<td>An extra 2 minutes is given per timeout. Maximum of two per captain.</td>
	</tr>
	<tr>
		<td>.bank</td>
		<td>Returns how much you have to spend in the current round.</td>
	</tr>
	<tr>
		<td>.teams</td>
		<td>Returns the current draft of teams.</td>
	</tr>
	<tr>
		<td>.showteam &lt;captain&gt;</td>
		<td>Returns the playerlist for that specific captain.</td>
	</tr>
	<tr>
		<td>.showrounds</td>
		<td>Returns the roundcaps.</td>
	</tr>
	<tr>
		<td>.about</td>
		<td>Returns version and author (me!).</td>
	</tr>
</table>
			
<h2>Admin Commands</h2>
<table>
	<tr><th>Command Syntax</th><th>Description</th></tr>
	<tr>
		<td>.setdraft &lt;on | off&gt;</td>
		<td>Will turn on the bot to respond to commands in the channel it was typed.</td>
	</tr>
	<tr>
		<td>.captain &lt;irc_nick&gt; &lt;list_nick&gt;</td>
		<td>Will add a captain to the list, linking their irc nick to the nick found in a .range. Captains can change nicks after they are added.</td>
	</tr>
	<tr>
		<td>.startdraft</td>
		<td>Will start the draft. Make sure all captains are ready! Will moderate the channel and voice each captain when it is their turn.</td>
	</tr>
	<tr>
		<td>.pause</td>
		<td>Will indefinitely pause the draft. Will resume when a pick is performed.</td>
	</tr>
	<tr>
		<td>.reset</td>
		<td>Resets the draft sending all players back to the pool. The captain list will remain intact.</td>
	</tr>
	<tr>
		<td>.fullreset</td>
		<td>Sends all player to the pool and removes all captains.</td>
	</tr>
	<tr>
		<td>.delcapt &lt;irc_nick&gt; &lt;list_nick&gt;</td>
		<td>Removes the captain from the captain list.</td>
	</tr>
	<tr>
		<td>.resetcaptains</td>
		<td>Resets only the captain list.</td>
	</tr>
	<tr>
		<td>.makelist</td>
		<td>Will attempt to import the player list. Outputs the full list of players to r2.txt.</td>
	</tr>
	<tr>
		<td>.players &lt;number&gt;</td>
		<td>Will automatically create roundcaps where &lt;number&gt; is the total number of players per team including the captain. The roundcaps are determined as follows: Total cap = (average salary of all players) * (number of players per team). Will allot $1000 for the first two rounds so that every captain can be bought no matter the price and so that each captain can pick anyone in their first round. The reset of the salary is evenly divided amongst the remaining rounds.</td>
	</tr>
	<tr>
		<td>.rounds &lt;round1,round2,rounds3&gt;</td>
		<td>A comma-delimited list of the roundcaps. Each number represents the amount of money unavailable to the captain for that round. For example: .rounds 5000,4000,3500,0 translates to) $5000-$4000=$1000 for the first round (captains are bought here), ($4000-$3500)=$500 added to each captain balance for the second round and ($3500-0)=$3500 added to each captain balance for the last round. In this fictitious example there are 3 rounds. Since captains are automatically bought in the first round, there are only two picking rounds. In total there are 3 players per team.</td>
	</tr>
</table>
