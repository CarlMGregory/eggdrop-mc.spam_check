##
# Spam Check v2.2.1 by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only work on eggdrop 1.5.5 or greater.
#
# My SVS Website - http://mc.purehype.net:81/
##

##
# This script is more focused on catching Onjoin/Onpart spammers.  If your
# looking for an anti spam script that will catch people saying, for instence,
# "JOIN #LAMER JOIN #LAMER JOIN #LAMER" or something to that effect in your
# channel, I recomend mc.badwerds.tcl.
#.
# This script is probably a little overboard for newbie bot owners... basicaly
# the logics behind it is... no one should be /msg'n this bot.. so EVERYTHING
# will be considered spam.
#.
# Bot will cycle the channel and listen for notices, DCC's, and messages.
# Any detected onjoin/onpart will processed for a warning/kick/ban.
#.
# This script works best if you own 2 or more bots and they are linked and they
# are using the getops script.  Otherwise, someone is going to have to manually
# op the bot every time it cycles (unless your lame and use the +a flag).
##

##
# History  ( <Fixed by> - [Found by] - <Information> ) 
##
# v2.2.1 (11.19.01)
#  MC_8 - IngentinG - Fixed 'TCL error [mc:sc:bot:relay]: can't read 
#                     "filename": no such variable'.
#  MC_8 -           - Added a new error handling idea.
#  MC_8 - Erik      - TCL error [mc:sc:dcc:message]: variable is not assigned
#                     by any conversion specifiers
#  MC_8 - Erik      - Fixed 'TCL error [mc:sc:dcc:command:spamcheck]: can't 
#                     read "mc_sc(script)": no such variable'.  Error in DCC
#                     and MSG command 'spamcheck'.
#  MC_8 - Erik      - Fixed 'TCL error [mc:sc:msg:command:spamcheck]: can't
#                     read "pos_mod": no such variable'.
#  MC_8 -           - Upgraded from SVS v1.3 to v2.0.
#  MC_8 - Plexus    - Fixed 'TCL error [mc:sc:msgm:message]: can't read 
#                     "mc_sc(exec:ban)": no such element in array'.
#
# v2.2 (10.30.01)
#  MC_8 - Rewrote explination of ban masking types.
#  MC_8 - Rewrote the ban masking proc again, much smaller now.
#  MC_8 - Ban types 10-19 were not masking the host.domain correctly if it
#         was an ip address.
#  MC_8 - Ban type 3, 4, 8 and 9 wasn't masking the host correctly.
#  MC_8 - Sharren Kandou - Ban types 10-19 were giving tcl errors.  'TCL error
#                       [mc:bw:pubm]: syntax error in expression "[regexp --
#                       {^1[0-9]$} $type] &&', fixed.
#  MC_8 - Kitt - Add new configs file option: 'nocycle:mode'
#  MC_8 - Sharren - Script was acting screwing with special character's in
#                   the spammers nick.  Fixed.
#  MC_8 - Removed 'glob_ban' option, it's not needed since I added the auto
#         search for feature (read next history entry), and also intigrated
#         it into 'ban:anyhow'.
#  MC_8 - If the spammer is not in a channel the bot is in, the script will
#         search the channels it's on for a matching ip/hostname.
#  MC_8 - Script was hackable, all a spammer had to do was NOTICE users with
#         "DCC " at the beginning of the spam messange and the bot would of
#         just ignored the user.  Fixed.
#             KatzEye reported something simular, but not exactly this.
#             Still showing partial credit in history.
#  MC_8 - Reworte filt proc, it's smaller and more effecent.
#  MC_8 - Rewrote the ban masking proc, it's quicker.
#  MC_8 - Removed the findip/ sindex/ srange proc.
#  MC_8 - Made minor changes to the SVS client section -- to give proper
#         error if an invalid user is specified to recieve a notification
#         of a newer version.
#  MC_8 - Revamped the coding (alot of minor stuff, to much to write here).
#
# v2.1 (08.27.01)
#  MC_8 - Found problems with DCC and MESSAGE cases when checking the mc_sc(act:wrds).
#         If act:wrds was set to more than 1 thing, DCC and MESSAGE would require that
#         all match, it should be if any match.
#  MC_8 - Alchera - Fixed issues with string index not recognizing the "e" or "end",
#                   quickly fixed with [expr [string length $var]-1] insted of "e".
#  MC_8 - Cleaned up relay message, if another bot is going to relay more than 1 channel,
#         it is only nessessary to say "Spam Check: Bot relay from <bot> regarding <nick>."
#         only once.
#  MC_8 - Alchera - Fixed issues with relay's regarding channels the bot isn't in giving
#                   off invalid channel errors.
#                   "Tcl error [mc:sc:bot:relay]: illegal channel..."
#  Alchera - Identified and fixed string range issues with abreviations of "e" as "end".
#  MC_8 - KatzEye - Fixed `Tcl error [mc:sc:msgm:message]: wrong # args: should be
#                   "string match pattern string"'
#  MC_8 - KatzEye - Added ability to do global bans, as opposed to channel specific.
#  MC_8 - Fixed, `Tcl error [mc:sc:msgm:message]: can't read "filename": no such variable`.
#  MC_8 - Fixed, `TCL error: invalid command name "mc:sc:replace"`.
#  MC_8 - Fixed, `TCL error: invalid command name "masktype"`.
#  MC_8 - Fixed:
#          Tcl error in script for 'timer????':
#          invalid command name "????"
#  MC_8 - KatzEye - Added set mc_sc(ban:anyhow).
#  MC_8 - KatzEye - Added ability to do sticky ban's.
#  MC_8 - JuanPerez - Fixed, `Tcl error [mc:sc:msgm:message]: can't read "1":
#                     no such variable'
#  MC_8 - Shezze - Added mc_sc(glob_ban) option, for those spammers that relay join
#                  information to another client that spams.  This method of spamming
#                  is harder to stop, if the user cloned himself and the bantype is
#                  setup correct enough, then it will get him.  But if the user is
#                  smart enough to use another host (via bnc or whatever), this script
#                  won't do much good considering there is no way to find the spammer.
#  MC_8 - Jan Christian Naustdal - Added ability to listen to only any combination of
#                                  the spam methods (DCC Send/MSG/Notice/Invite). The
#                                  upside is you can set the bot to only listen for
#                                  (ie.) dcc send virus senders, turning off protection
#                                  for MSG, Notice, and Invites...
#  MC_8 - Sheeze - Was was evaluating it's self for spam checks, this isn't cool
#                  if the spamcheck bot runs an auto greet that is built poorly
#                  in which it greet's self on join.  Fixed.
#  MC_8 - Shezze - Added ability to only watch for certin word strings, insted of
#                  just considering everything a spam message.
#  MC_8 - /Invite is a form of spam... Added that to the script.
#  MC_8 - KrE80R Kr - Fixed `Tcl error [mc:sc:bot:relay]: can't read 
#                     "mc_sc(exc:message:)": no such element in array'
#  MC_8 - Abraham - Veriables spamcheck and spamcycle now implimented into
#                   channel flags.  No more setting what channel(s) to cycle
#                   and not cycle in this script.  It is now all done via
#                   DCC (ie:  .chanset #channel -spamcycle +spamcheck).
#                   See settings description below.
#  MC_8 - KrE80r Kr - Added ability to exclude certin command words from being
#                     considered a spam /msg, /notice.  Example from KrE80r Kr,
#                     /msg bot seen TesT ,, don't want the bot to consider that
#                     spam.
#  MC_8 - Abraham - Adding options for min. & max. cycle time, the bot will 
#                   pick a random number between them two to do the next cycle
#                   therefore making it not look as "suspicious/artificial".
#  MC_8 - KrE80r Kr - Fixed `Tcl error [mc:sc:msgm:message]: can't read 
#                     "botnet-nick": no such variable'
#
# v2.0 (01.03.01)
#  MC_8 - SPECiAL-K - Beta tested, msg/notice/dcc send/dcc notice all check out ok.
#                     Releasing to public.
#  MC_8 - Added MC SVS -- will automatically check to see if the version you have is
#         the most current -- if not, it will leave a note for whoever you choose.
#  MC_8 - Marek - Removed DCC Chat as punishable spam -- who spams with a dcc chat?
#  MC_8 - Marek - Bot should ban before kick.
#  MC_8 - Marek - Added %filename replacement for message replacement for dcc send.
#  MC_8 - Marek - Added ability to set different message depending on the method in
#                 which the user contacted the bot.  (dcc send/msg/notice)
#  MC_8 - Tested with eggdrop v1.4.4:  If you see this dcc message 
#         "Server says I'm not on channel: #..." it is an eggdrop problem, so please don't
#         report it as if this script were crazy :)
#          Why an eggdrop problem? -- Upon doing the -/+inactive features to get the bot
#          to delay a rejoin, when doing a -inactive on mass channels, and it's laged...
#          The script will say -inactive and send the PART... If eggdrop see's its still
#          in that channel after waiting ??seconds then it will send yet another PART
#          thus causing ircd to give an error RAW 442.  You cannot part a channel your not on <g>.
#  MC_8 - Marek - Fixed, bot was never performing punishments.  Problem... it was stuck
#                 thinking the bot still wasn't in the channel yet.
#  MC_8 - Fixed, invalid command name "mc:sc:masktype"
#  MC_8 - Fixed, Tcl error in script for 'timer196286': extra characters after close-brace
#  MC_8 - Marek - Added option to have a part message.
#  MC_8 - Marek - Fixed, Tcl error [mc:sc:message]: can't read "mc_sc(joind:active)": no such element in array
#  MC_8 - Recoded all procs, started it from scratch for a better coding structure.
#
# v1.4 (11.11.00) *unreleased -- moved to v2.0*
#  MC_8 - GilGolan - Made it possibe to set mc_sc(auto:check) to 0 to turn off the 
#                    channel cycling.
#  MC_8 - GilGolan - Added a relay feature.  If the bot isn't op'd it will send an
#                    message over the botnet, if another bot that has this script has
#                    the same key and is linked up... AND that bot is op'd, it will preform
#                    the punishment.
#  MC_8 - Scott Spaay - Added coding to auto kick the user upon issuing a ban.  Normally
#                       the bot would do that if enforcebans is turned on... but if it's
#                       not, no worry... the script has it covered.
#  MC_8 - Scott Spaay - Added warning feature, along with that... many more veriables.
#  MC_8 - AAshearer - Fixed "Tcl error [joinpart]: invalid command name "hand2nick""
#  MC_8 - fixed `invalid command name "findip"'
#  MC_8 - '[21:27] missing close-bracket' caused by special charactered nicks doing auto spams.
#
# v1.3 (04.08.00)
#  MC_8 - Added banmasking feature.
#  MC_8 - pimpin - Added option to enable/disable it's notice ops that the bot is about
#                  to cycle.
#  MC_8 - anonymous - Added option to wait x seconds before re`join'n. (eggdrop1.3.28+ only)
#  MC_8 - Somak Goswami - Fixed `Tcl error [joinpart]:  invalid command name "option"'.
#
# v1.2 (02.27.00)
#  MC_8 - Fixed: Tcl error [checkspam:pre]: can't read "uhost": no such variable
#
# v1.1 (02.26.00)
#  MC_8 - Added setting, listen time.  How long it listens for onjoin's.
#  MC_8 - Added MSG checkspam trigger.
#  MC_8 - Fixed error `invalid command name "mc_sc"' during timed spam check.
#  MC_8 - Matt - Auto Spam checks ... settable times
#  MC_8 - Matt - Only recognizes 1 pub !spamcheck request per 40 sec.
#  MC_8 - Added some fail safes in the coding. (1, doesn't cycle if
#          the bot is the ONLY op) (2, if the bot is not op'd, it can't
#          possibly ban the spammer, nor can it notice @#channel ... if
#          the bot is not oped upon this situation, it sends it's information
#          to the dcc console o)
#  MC_8 - Made it do more than just 1 channel.
#  MC_8 - Added option to exempt oped users.
#  MC_8 - Added option to exempt voiced users.
#  MC_8 - Added option to exempt flags.
#  MC_8 - LuNito - Gave it a 5 second delay before processing the onjoin spam.
#                  This is to help the bot op up before processing, if the bot
#                  isn't op'd, it can't auto-ban for on-join.
#  MC_8 - LuNito - Added hand2nick support for bot's 1.3.26 and older.
#  MC_8 - LuNito - Made Auto Spam check time easier to work, I removed the bind
#                  time and make it a "timer" function insted.
#
# v1.0 (02.25.98)
#  Torr - Inital Release.
##

##
# Commands (DCC & MSG)
#               access
#   command     required    action
#   ___________ ___________ _____________________
#   spamcheck   +m (global) forces channel cycles
##

##
# Settings
##

# Note:
#  There are two settings you set from dcc chat with the bot using .chanset.
#   +/-spamcycle  (Setting this on will enable the channel to be cycled for spamchecks)
#   +/-spamcheck  (Setting this on will enable the channel to process spam)
#
#  Example from dcc chat with the bot:
#   .chanset #channel -spamcycle +spamcheck

# What command words do you want to ignore?  The command word would be the first
# word the user would say, like "seen" or "help" or "op".
# List all ignored words, seperated by spaces.
set mc_sc(ign:wrds) "addhost info who ident help voice whois pass op invite go key die jump memory save rehash reset status dent notes"

# What word strings do you want to listen for?  Seperate each string with a new
# line.  Wildcards are accepted.  If you want it to listen to everything (like
# in previous versions), just have 1 line that states a * wildcard.
# To match an invite, it get's passed as "invite #channel".
# To match a DCC Send, it get's passed as "dccsend filename".
# I will give you 2 examples, the first (commented out) will contain 5 character
# strings to watch for ONLY.  The second example (uncommented) states to watch
# for anything and everything.
#set mc_sc(act:wrds) {
# *http://*
# *www.*
# *sex*
# *join #*
# *goto #*
#}
set mc_sc(act:wrds) {
 *
}

# [0=no/1=yes] Do you want to strip color/bold/uline/reverse characters from text?
#  Usefull only if your listening for certin character strings and not just everything.
#  example: Some ppl get past the kick/ban by .. puting this www.something.net
#           on mirc, that shows up as www.something.net, normal, but to the bot it's 
#           NOT *www.*, it's *www.*
set mc_sc(act:strip) 1

# How many min's between cycles do you want?
# Set it to minimum:maximum, the script will randomly pick a number between
# them.  Example: 5:10  .. the script will pick a number between 5 and 10
# and use that for the cycle time, will pick another number next cycle point.
# This makes the bot a little less suspecious.
# Set to 0:0 to turn off the cycling of the channels.
set mc_sc(sc:cyclerate) 9:20

# If you don't want to cycle if the channel is at a certin mode, set it here.
# You can set as many as you like, seperate each set with a space.  Set this
# to "" to disable.
# Example:
#   "+i-nt +k +sm" == Will not cycle if the channel has a +i, and does NOT have
#                     a +n and a +t.  Or, will not cycle if the channel has a +k.
#                     Or, will not cycle if the channel has a +s and +m.
set mc_sc(nocycle:mode) ""

# How long do you want to stay gone from the channel?  The bot will /part and wait
# x amount of seconds before /join'n.  (Only for eggdrop1.3.28 and greater)
# Set to 0 for quick cycle.
set mc_sc(joind) 10

# If the above method (mc_sc(joind)) is 0 or your bot is older than 1.3.28,
# it will allow you to specify a part message.
# What do you want for a part message?  Set to "" for no message.
# NOTE:  If you set a message, it's move obvious the bot is doing spam checking.
set mc_sc(chan:cycle:message) ""

# [1=yes/0=no] Do you want to exempt oped users if they are found with an onjoin?
set mc_sc(exempt:op) 1

# [1=yes/0=no] Do you want to exempt voiced users if they are found with an onjoin?
set mc_sc(exempt:voice) 1

# What flags do you want to exempt if they are found with an onjoin?
# Set to "" if you want to disable this (no flags exemption).
# format: <global flag>|<channel flag>
set mc_sc(exempt:flags) "bn|n"

# How many warnings do you want to give before executing a kick/ban.
set mc_sc(warnings) 0

# What do you want the warning message to say?
# You can specify a different message depending on the method in 
# which the user contacted the bot.
# Replacment text:  %filename will be replaced with the name of the file
#   the user was trying to send -- naturally, this is only valid for dccsend.
#
# If you don't to listen on one of these spam methods, set it to "". For example,
# if you only want the script to listen for dccsends (for virus senders) and nothing
# else, set everything (except for the dccsend one) to "".
set mc_sc(warn:message:dccsend) "Anti Spam, Don't dcc send me anything.  That includes %filename!"
set mc_sc(warn:message:privmsg) "Anti Spam, Don't message me."
set mc_sc(warn:message:notice) "Anti Spam, Don't notice me."
set mc_sc(warn:message:invite) "Anti Spam, Don't invite me to your lame channel."

# [0=no/1=yes] Do you want to message the user the warning?
set mc_sc(warn:msg) 0

# [0=no/1=yes] Do you want to kick the user upon warning?
set mc_sc(warn:kick) 1

# How long do you want to ban on a warning?
#  -1 == don't ban
#   0 == server ban, not an actual ban entrie in the bot
#  Any numbers above 0 are considered the number of min's the user
#  is baned in the bot's banlist.
# If you want the ban to be sticky, put a ! behind the the number (ie:  3!).
# If you want the ban to be global, rather than channel specific; put a "@"
#  infront of it (ie: @3!)
set mc_sc(warn:ban) -1

# After exceeding warnings, do you want to ban the user?
#  -1 == don't ban
#   0 == server ban, not an actual ban entrie in the bot
#  Any numbers above 0 are considered the number of min's the user
#  is baned in the bot's banlist.
# If you want the ban to be sticky, put a ! behind the number (ie:  3!).
# If you want the ban to be global, rather than channel specific; put a "@"
#  infront of it (ie: @3!)
set mc_sc(exc:ban) 1440

# What do you want the ban message to say?  This is the message the
# user will get after exhausing all his/her warnings.
# You can specify a different message depending on the method in 
# which the user contacted the bot.
# Replacment text:  %filename will be replaced with the name of the file
#   the user was trying to send -- naturally, this is only valid for dccsend.
set mc_sc(exc:message:dccsend) "Anti Spam, Don't dcc send me anything.  That includes %filename!"
set mc_sc(exc:message:privmsg) "Anti Spam, Don't message me."
set mc_sc(exc:message:notice) "Anti Spam, Don't notice me."
set mc_sc(exc:message:invite) "Anti Spam, Don't invite me to your lame channel."

# Set this to the ban mask type you what,
#  Default == 5
#      0 - *!user@host.domain
#      1 - *!*user@host.domain
#      2 - *!*@host.domain
#      3 - *!*user@*.domain
#      4 - *!*@*.domain
#      5 - nick!user@host.domain
#      6 - nick!*user@host.domain
#      7 - nick!*@host.domain
#      8 - nick!*user@*.domain
#      9 - nick!*@*.domain
#     You can also specify a type of 10 to 19 which correspond to masks 0 
#     to 9.  But if the host.domain is a;
#       hostname = Instead of using a * wildcard to replace portions of the
#                  host.domain, it replaces the numbers in the host.domain 
#                  with a '?' (question mark) wildcard
#       ip       = It will mask as normal, with no '?' (question mark)
#                  replacments as does hostname.
set mc_sc(bant) 2

# [0=no/1=yes] If the bot isn't op'd, do you want it to ask the bot's 
# in the botnet to punish the user?
#  Information:  1) The recieving bot must have this script.  Sure the other bot
#                   yielding this script can have the cycle feature turned off, that
#                   way it'll look a little sneakier on how the recieving bot know's
#                   the spammer is spamming.
#                2) If you set this to 1, this also enables the ability to recieve... as
#                   well as send out the relay's.
set mc_sc(relay) 1

# If the above (mc_sc(relay)) is set to 1, then what do you want to set the key to?
# The key is the encryption base of the botnet message.  Both the sending bot
# and the recieving bot must have the same key.  This is to pervent some other bot
# on the botnet sending a fake relay request.
set mc_sc(relay:key) "spamcheck"

# [0=no/1=yes] If the bot detects spam, but the bot isn't op'd, do you want the 
# bot to add the spammer to the global ban list?  Ban time goes off mc_sc(exc:ban)
# setting.
set mc_sc(ban:anyhow) 1


## MC SVS (Script Version Service) v2.0 ##
# Do you want the bot to connection to MC_8's SVS to see if there are newer versions
# of this script avilable?  It will only tell you -- It's up to you to get the newest
# version (I decided not to auto update the code, there may be new features in the
# newest script that may require your attention).
# 0=no/1=yes
set mc_sc(svs:enabled) 1

# Once a day the script will check with the SVS -- this specifies when
# that should happen.  The setting should be the hour (military).
# examples:
#  set mc_sc(svs:check) 0   ;#This is at Midnight
#  set mc_sc(svs:check) 5   ;#This is at 5am
#  set mc_sc(svs:check) 13  ;#This is at 1pm
#  set mc_sc(svs:check) 23  ;#This is at 11pm
set mc_sc(svs:check) 3

# Upon finding a newer version of this script, who do you want this script
# to send a note to telling them of this newer version?
# If more than 1 user is to be notified, seperate each user with a
# ' ' (space).
set mc_sc(svs:notify) "MC_8"

# Do you want even beta version notified to whomever you have set?  Or just
# stable releases of the script?
#  0 = Tell me about all version, even beta versions.
#  1 = Just tell me about new stable versions.
set mc_sc(svs:stableonly) 0






##

##
# Coding below, do not proceed unless you are a programmer.
##

set mc_sc(script)      "Spam Check"
set mc_sc(version)     "v2.2.1"
set mc_sc(svs:script)  "spamcheck"
set mc_sc(svs:version) "002002001000"
set mc_sc(svs:server)  "mc.purehype.net"
set mc_sc(svs:port)    "81"
set mc_sc(svs:get)     "/"
set mc_sc(svs:query)   "svs=$mc_sc(svs:script)&version=$mc_sc(svs:version)"

if {$numversion < "1050500"} {
 putlog "$mc_sc(script) $mc_sc(version) by MC_8 will only work on eggdrop 1.5.5 or greater."
 putlog "$mc_sc(script) $mc_sc(version)  will not work with eggdrop $version."
 putlog "$mc_sc(script) $mc_sc(version)  not loaded."
 return 1
}

setudef flag spamcycle ; setudef flag spamcheck

proc mc:sc:error {bindproc error {arg ""}} {
 global mc_sc version lastbind
 putlog "Error in script $mc_sc(script) $mc_sc(version)."
 putlog "       Last bind: $lastbind"
 putlog "       Procedure: $bindproc"
 putlog "            Args: $arg"
 putlog " Eggdrop version: $version"
 putlog "     TCL version: [info tclversion]"
 putlog "*** Please email this bug information to MC_8, his latest"
 putlog "*** email address should be on http://mc.purehype.net:81/"
 putlog "*** Please include the next line in the email as well."
 error $error
}

proc mc:sc:errchk {command arg} {
 if {[catch {eval $command $arg} return]} {
  mc:sc:error $command $return $arg; return 0
 }; return $return
}

proc mc:sc:inter:chanflagison {chan flag} {
 if {[catch {mc:sc:inter:chanflagison_ $chan $flag} return]} {
  mc:sc:error mc:sc:inter:chanflagison_ $return [list $chan $flag]
  return 0
 }; return $return
}

if {![string match *mc:sc:cycle* [timers]]} {
 scan $mc_sc(sc:cyclerate) {%[^:]:%s} min max
 if {$min >= $max} {set cycletime $max} {
  set cycletime [rand [expr $max+1]]
  while {$cycletime < $min} {set cycletime [rand [expr $max+1]]}
 };timer $cycletime mc:sc:cycle
}
if {[info exists mc_sc(joind:active)]} {unset mc_sc(joind:active)}
set mc_sc(ign:wrds) [string tolower $mc_sc(ign:wrds)]

bind dcc m| spamcheck mc:sc:dcc:command:spamcheck
proc mc:sc:dcc:command:spamcheck {hand idx arg} {
 return [mc:sc:errchk mc:sc:dcc:command:spamcheck_ [list $hand $idx $arg]]
}
proc mc:sc:dcc:command:spamcheck_ {hand idx arg} {
 global mc_sc
 mc:sc:cycle ; putdcc $idx "$mc_sc(script) is cycling channels."
 return 1
}

bind msg m| spamcheck mc:sc:msg:command:spamcheck
proc mc:sc:msg:command:spamcheck {nick uhost hand arg} {
 return [mc:sc:errchk mc:sc:msg:command:spamcheck_ [list $nick $uhost $hand $arg]]
}
proc mc:sc:msg:command:spamcheck_ {nick uhost hand arg} {
 global mc_sc
 mc:sc:cycle ; putserv "PRIVMSG $nick :$mc_sc(script) is cycling channels."
 return 1
}

proc mc:sc:cycle {} {
 return [mc:sc:errchk mc:sc:cycle_ ""]
}
proc mc:sc:cycle_ {} {
 global mc_sc numversion botnick
 foreach chan [string tolower [channels]] {
  if {![mc:sc:inter:chanflagison $chan spamcycle]} {continue}
  if {[isop $botnick $chan]} {
   set onlyop 1
   foreach user [string tolower [chanlist $chan]] {
    if {($user != [string tolower $botnick]) && [isop $user $chan]} {set onlyop 0 ; break}
   } ; if {$onlyop} {putlog "$mc_sc(script): Cannot cycle $chan, I am the only op.";continue}
  }
  set channel_mode [lindex [getchanmode $chan] 0]
  set pos_chan_mode "" ; set neg_chan_mode ""
  regexp -- {\+([a-zA-Z0-9]*)[^a-zA-Z0-9]?} $channel_mode temp pos_chan_mode
  regexp -- {\-([a-zA-Z0-9]*)[^a-zA-Z0-9]?} $channel_mode temp neg_chan_mode
  foreach nocymode $mc_sc(nocycle:mode) {  
   set pos_mode "" ; set neg_mode ""
   regexp -- {\+([a-zA-Z0-9]*)[^a-zA-Z0-9]?} $nocymode temp pos_mode
   regexp -- {\-([a-zA-Z0-9]*)[^a-zA-Z0-9]?} $nocymode temp neg_mode
   set a 1
   foreach mode [split $pos_mode ""] {
    if {![string match *$mode* $pos_chan_mode]} {set a 0;break}
   }
   set b 1
   foreach mode [split $neg_mode ""] {
    if {![string match *$mode* $neg_chan_mode]} {set b 0;break}
   }
   set c 1
   foreach mode [split $neg_mode ""] {
    if {[string match *$mode* $pos_chan_mode]} {set c 0;break}
   }
   if {[expr $a && $b && $c]} {
    putlog "$mc_sc(script): Cannot cycle $chan, channel mode is: $channel_mode / nocycle mode is $nocymode"
    return 0
   }
  }
  if {($numversion >= "1032800") && $mc_sc(joind)} {
   if {![mc:sc:inter:chanflagison $chan inactive]} {
    channel set $chan +inactive
    utimer $mc_sc(joind) "channel set [mc:sc:filt $chan] -inactive"
    if {![string match "*unset mc_sc(joind:active)*" [utimers]]} {
     utimer [expr $mc_sc(joind)+[expr [llength [channels]]*5]] "catch {unset mc_sc(joind:active)}"
    } ; set mc_sc(joind:active) 1
   }
  } else {
   if {$mc_sc(chan:cycle:message) != ""} {
    putserv "PART $chan :$mc_sc(chan:cycle:message)"
   } else {putserv "PART $chan"}
  }
 }
 set min [lindex [split $mc_sc(sc:cyclerate) :] 0]
 set max [lindex [split $mc_sc(sc:cyclerate) :] 1]
 if {$min >= $max} {set cycletime $max} {
  set cycletime [rand [expr $max+1]]
  while {$cycletime < $min} {set cycletime [rand [expr $max+1]]}
 };if {![string match *mc:sc:cycle* [timers]]} {timer $cycletime mc:sc:cycle}
}

bind raw - INVITE mc:sc:raw:invite
proc mc:sc:raw:invite {from key arg} {
 return [mc:sc:errchk mc:sc:raw:invite_ [list $from $key $arg]]
}
proc mc:sc:raw:invite_ {from key arg} {
 global mc_sc botnick
 scan $from {%[^!]!%[^@]@%s} nick ident host
 set hand [finduser $from]
 scan $arg {%[^:]:%s} temp chan
 if {$mc_sc(warn:message:invite) == ""} {return 0}
 if {$mc_sc(act:strip)} {set chan [mc:sc:inter:strip:all $chan]}
 set arg "invite $chan"
 set return 1
 foreach word [string tolower [split $mc_sc(act:wrds) \n]] {
  if {[join $word] == ""} {continue}
  if {[string match [string trim $word] [string tolower $arg]]} {
   set return 0;break
  }
 };if {$return} {return 0};mc:sc:message $nick $ident@$host $hand invite
}

bind notc - * mc:sc:notc:message
proc mc:sc:notc:message {nick uhost hand arg {dest ""} {DCC_Check ""}} {
 return [mc:sc:errchk mc:sc:notc:message_ [list $nick $uhost $hand $arg $dest $DCC_Check]]
}
proc mc:sc:notc:message_ {nick uhost hand arg {dest ""} {DCC_Check ""}} {
 global mc_sc botnick ; if {$dest == ""} {set dest $botnick}
 if {($dest != $botnick) || ($mc_sc(warn:message:notice) == "")} {return 0}
 if {([regexp -- {^DCC } $arg]) && ($DCC_Check == "")} {
  utimer 5 [list mc:sc:notc:message $nick $uhost $hand $arg $dest DCC_Check]
  return 0
 }
 if {$mc_sc(act:strip)} {set arg [mc:sc:inter:strip:all $arg]}
 set return 1
 foreach word [string tolower [split $mc_sc(act:wrds) \n]] {
  if {[join $word] == ""} {continue}
  if {[string match [string trim $word] [string tolower $arg]]} {
   set return 0;break
  }
 };if {$return} {return 0}
 scan $arg %s cmd
 foreach command [string tolower $mc_sc(ign:wrds)] {
  if {[string tolower $cmd] == $command} {return 0}
 };mc:sc:message $nick $uhost $hand notice
}

bind msgm - * mc:sc:msgm:message
proc mc:sc:msgm:message {nick uhost hand arg} {
 return [mc:sc:errchk mc:sc:msgm:message_ [list $nick $uhost $hand $arg]]
}
proc mc:sc:msgm:message_ {nick uhost hand arg} {
 global mc_sc
 if {$mc_sc(warn:message:privmsg) == ""} {return 0}
 if {$mc_sc(act:strip)} {set arg [mc:sc:inter:strip:all $arg]}
 set return 1
 foreach word [string tolower [split $mc_sc(act:wrds) \n]] {
  if {[join $word] == ""} {continue}
  if {[string match [string trim $word] [string tolower $arg]]} {
   set return 0;break
  }
 };if {$return} {return 0}
 scan $arg %s cmd
 foreach command [string tolower $mc_sc(ign:wrds)] {
  if {[string tolower $cmd] == $command} {return 0}
 };mc:sc:message $nick $uhost $hand privmsg
}

bind ctcp - "DCC" mc:sc:dcc:message
proc mc:sc:dcc:message {nick uhost hand dest keyword arg} {
 return [mc:sc:errchk mc:sc:dcc:message_ [list $nick $uhost $hand $dest $keyword $arg]]
}
proc mc:sc:dcc:message_ {nick uhost hand dest keyword arg} {
 global mc_sc botnick
 scan $arg {%s %s %s %s %s} cmd file ip port size
 if {($mc_sc(warn:message:dccsend) == "") || ($cmd != "SEND") ||
     ($dest != $botnick)} {return 0}
 set arg "dccsend $file"
 foreach utimer  [string tolower [utimers]] {
  set timer      [lindex $utimer 1]
  set t_arg      [lindex $timer 4]
  set t_dest     [lindex $timer 5]
  set t_dcc_test [lindex $timer 6]
  if {$timer == [string tolower [list mc:sc:notc:message $nick $uhost $hand $t_arg $t_dest $t_dcc_test]]} {
   killutimer [lindex $utimer 2];break
  }
 };if {$mc_sc(act:strip)} {set arg [mc:sc:inter:strip:all $arg]}
 set return 1
 foreach word [string tolower [split $mc_sc(act:wrds) \n]] {
  if {[join $word] == ""} {continue}
  if {[string match [string trim $word] [string tolower $arg]]} {
   set return 0;break
  }
 };if {$return} {return 0};mc:sc:message $nick $uhost $hand $arg
}

proc mc:sc:message {nick uhost hand method {channels ""}} {
 return [mc:sc:errchk mc:sc:message_ [list $nick $uhost $hand $method $channels]]
}
proc mc:sc:message_ {nick uhost hand method {channels ""}} {
 global mc_sc botnick
 if {[string tolower $nick] == [string tolower $botnick]} {return 0}
 if {$channels == ""} {
  if {[info exists mc_sc(ignore:$nick)]} {
   if {![string match "*unset mc_sc(ignore:$nick)*" [utimers]]} {
    utimer 5 "catch {unset mc_sc(ignore:[mc:sc:filt $nick])}"
   };return 0
  };set mc_sc(ignore:$nick) 1
  utimer 5 "catch {unset mc_sc(ignore:[mc:sc:filt $nick])}"
  if {[info exists mc_sc(joind:active)]} {
   utimer [expr $mc_sc(joind)+2] [list mc:sc:message $nick $uhost $hand $method]
   if {![string match "*unset mc_sc(joind:active)*" [utimers]]} {
    utimer $mc_sc(joind) "unset mc_sc(joind:active)"
   };return 0
  }
  foreach chan [string tolower [channels]] {
   if {[onchan $nick $chan]} {set i 1;lappend channels $chan}
  }
  if {![info exists channels]} {
   scan $from {%[^@]@%s} ident host ; set found ""
   foreach chan [string tolower [channels]] {
    append found " [mc:sc:inter:findchanuser *!*@$host $chan]"
   }
   if {$found != ""} {
    foreach user $found {
     utimer 5 [list mc:sc:message $user [getchanhost $user] [nick2hand $user] $method]
    };return 0
   } {set channels [string tolower [channels]]}
  }
 } elseif {![onchan $nick $channels]} {return 0}
 foreach channel $channels {
  if {([mc:sc:inter:chanflagison $channel inactive]) ||
      (![mc:sc:inter:chanflagison $channel spamcheck]) ||
      (([isop $nick $channel]) && ($mc_sc(exempt:op))) ||
      (([isvoice $nick $channel]) && ($mc_sc(exempt:voice))) ||
      (($mc_sc(exempt:flags) != "") && ([matchattr $hand $mc_sc(exempt:flags) $channel]))} {
   continue
  }
  if {![onchan $botnick $channel]} {
   utimer [expr $mc_sc(joind)+2] [list mc:sc:message $nick $uhost $hand $method $channel]
   continue
  }
  if {$mc_sc(warnings)} {
   if {[info exists mc_sc(warn:$uhost:$channel)]} {
    if {[set mc_sc(warn:$uhost:$channel) [expr $mc_sc(warn:$uhost:$channel)+1]] > $mc_sc(warnings)} {
     set x 0
    } else {set x 1}
   } else {set mc_sc(warn:$uhost:$channel) 0 ; set x 1}
  } else {set x 0}
  mc:sc:punish $nick $uhost $hand $channel $x $method
 }
}

proc mc:sc:punish {nick uhost hand chan warn method} {
 return [mc:sc:errchk mc:sc:punish_ [list $nick $uhost $hand $chan $warn $method]]
}
proc mc:sc:punish_ {nick uhost hand chan warn method} {
 global mc_sc botnick {botnet-nick}
 if {![isop $botnick $chan]} {
  if {$mc_sc(relay)} {
   putallbots "spamcheck [encrypt $mc_sc(relay:key) "$mc_sc(relay:key)+${botnet-nick}"] [list $nick $uhost $hand $chan $warn $method]"
  }
 }
 set filename ""
 scan $method {%s %s} method filename ; if {$method != "dccsend"} {set filename ""}
 set banmask [mc:sc:inter:masktype $nick!$uhost $mc_sc(bant)]
 if {(![isop $botnick $chan]) || (![onchan $nick $chan])} {
  if {($mc_sc(ban:anyhow)) && ([string trim $mc_sc(exc:ban) @!] != "-1") &&
      (![isban $banmask $chan]) && ([string trim $mc_sc(exc:ban) @!])} {
   set comment [mc:sc:inter:replace $mc_sc(exc:message:$method) "%filename $filename"]
   if {[string match *! $mc_sc(exc:ban)]} {
    set time [string trimright $mc_sc(exc:ban) !] ; set options "sticky"
   } {set time $mc_sc(exc:ban) ; set options "none"}
   newchanban $chan $banmask ${botnet-nick} $comment [string trimleft $time @] $options
  };return 0
 }
 if {$warn} {
  set comment [mc:sc:inter:replace $mc_sc(warn:message:$method) "%filename $filename"]
  putlog "$mc_sc(script), warning $nick!$uhost ($chan): $comment"
  if {($mc_sc(warn:msg)) && ($comment != "")} { putserv "PRIVMSG $nick :$comment" }
  set global [string match @* $mc_sc(warn:ban)]
  if {[string match *! $mc_sc(warn:ban)]} {set opt "sticky"} {set opt "none"}
  set time [string trimleft $mc_sc(warn:ban) @!]
  if {$mc_sc(warn:kick)} {
   if {$comment != ""} {set x " :$comment"} {set x ""};putserv "KICK $chan $nick$x"
  }
 } else {
  set comment [mc:sc:inter:replace $mc_sc(exc:message:$method) "%filename $filename"]
  putlog "$mc_sc(script), exceeded warnings for $nick!$uhost ($chan): $comment"
  set global [string match @* $mc_sc(exc:ban)]
  if {[string match *! $mc_sc(exc:ban)]} {set opt "sticky"} {set opt "none"}
  set time [string trimleft $mc_sc(exc:ban) @!]
  if {$comment != ""} {set x " :$comment"} {set x ""};putserv "KICK $chan $nick$x"
 }
 if {$time >= "0"} {
  if {$global} {set channels [string tolower [channels]]} else {
   set channels [string tolower $chan]
  }
  foreach channel $channels {
   if {(![mc:sc:inter:chanflagison $channel spamcheck]) ||
       ([mc:sc:inter:existchanban $banmask $channel])} {continue}
   putserv "MODE $channel +b $banmask"
  }
 }
 if {$time >= "1"} {
  foreach channel $channels {
   if {(![mc:sc:inter:chanflagison $channel spamcheck]) ||
       ([isban $banmask $channel])} {continue}
   newchanban $channel $banmask ${botnet-nick} $comment $time $opt
  }
 }
}

bind bot - spamcheck mc:sc:bot:relay
proc mc:sc:bot:relay {from command arg} {
 return [mc:sc:errchk mc:sc:bot:relay_ [list $from $command $arg]]
}
proc mc:sc:bot:relay_ {from command arg} {
 global mc_sc botnick
 set nick [lindex $arg 1] ; set uhost [lindex $arg 2] ; set hand [lindex $arg 3]
 set chan [lindex $arg 4] ; set warn [lindex $arg 5] ; set method [lindex $arg 6]
 if {([lindex $arg 0] != [encrypt $mc_sc(relay:key) "$mc_sc(relay:key)+$from"]) ||
     (!$mc_sc(relay)) || (![validchan $chan])} {return 0}
 if {[info exists mc_sc(relayblock:$nick:$chan)]} {
  if {![string match "*unset mc_sc(relayblock:$nick:$chan)*" [utimers]]} {
   utimer 10 "unset mc_sc(relayblock:[mc:sc:filt $nick:$chan])"
  };return 0
 };set mc_sc(relayblock:$nick:$chan) 1
 utimer 10 "unset mc_sc(relayblock:[mc:sc:filt $nick:$chan])"
 putlog "$mc_sc(script):  Bot relay from $from regarding $nick @ $chan."
 mc:sc:punish $nick $uhost $hand $chan $warn $method
}

bind evnt - prerestart mc:sc:evnt:prestart
proc mc:sc:evnt:prestart {type} {
 return [mc:sc:errchk mc:sc:evnt:prestart_ [list $type]]
}
proc mc:sc:evnt:prestart_ {type} {
 set i 0
 foreach timer [utimers] {
  if {[string match "*channel set * -inactive*" $timer]} {
   catch {channel set [lindex [lindex $timer 1] 2] -inactive]}
   set i 1
  }
 };if {$i} {savechannels}
}

### Internal use Procs

proc mc:sc:inter:masktype {uhost type} {
 return [mc:sc:errchk mc:sc:inter:masktype_ [list $uhost $type]]
}
# v1.0
proc mc:sc:inter:masktype_ {uhost type} {
 set ident_max-length 9
 set host_max-length 63
 scan $uhost {%[^!]!%[^@]@%s} nick ident host
 set maskhost 1
 if {[regexp -- {^1[0-9]$} $type]} {
  if {!([regexp -- {^([0-9][0-9]?[0-9]?)\.([0-9][0-9]?[0-9]?)\.([0-9][0-9]?[0-9]?)\.([0-9][0-9]?[0-9]?)$} $host temp a b c d] && ($a > 0 && $a < 255 && $b < 255 && $c < 255 && $d < 255))} {
   regsub -all {[0-9]} $host "?" host
   set maskhost 0
  };set type [string index $type 1]
 }
 if {[regexp -- {^[0-4]$} $type]} {set nick "*"}
 if {[regexp -- {^[2479]$} $type]} {set ident "*"}
 if {[regexp -- {^[1368]$} $type]} {set ident "*[string trimleft $ident ~]"}
 if {[regexp -- {^[3489]$} $type]} {if {$maskhost} {scan [maskhost $host] {%[^@]@%s} temp host}}
 if {[string length $ident] > ${ident_max-length}} {
  set ident "*[string range $ident [expr [string length $ident]-${ident_max-length}] end]"
 }
 if {[string length $host] > ${host_max-length}} {
  set host "*[string range $host [expr [string length $host]-${host_max-length}] end]"
 }; return [format "%s!%s@%s" $nick $ident $host]
}

proc mc:sc:inter:replace {string subs} {
 return [mc:sc:errchk mc:sc:inter:replace_ [list $string $subs]]
}
proc mc:sc:inter:replace_ {string subs} {
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- [lindex $subs $i] $string [lindex $subs [expr $i+1]] string
 } ; return $string
}

proc mc:sc:inter:findchanuser {hostmask channel} {
 return [mc:sc:errchk mc:sc:inter:findchanuser_ [list $hostmask $channel]]
}
proc mc:sc:inter:findchanuser_ {hostmask channel} {
 if {![validchan $channel]} {return -code error "no such channel record"}
 set buffer "" ; set hostmask [string tolower $hostmask]
 foreach user [chanlist $channel] {
  if {[string match $hostmask [string tolower $user![getchanhost $user $channel]]]} {
   lappend buffer $user
  }
 }; return $buffer
}

proc mc:sc:inter:chanflagison {chan flag} {
 return [mc:sc:errchk mc:sc:inter:chanflagison_ [list $chan $flag]]
}
proc mc:sc:inter:chanflagison_ {chan flag} {
 foreach info [string tolower [channel info $chan]] {
  if {[string range $info 1 end] != [string tolower $flag]} {continue}
  if {[string index $info 0] == "-"} {
   return 0
  } elseif {[string index $info 0] == "+"} {return 1} else {return 0}
 };return 0
}

proc mc:sc:inter:existchanban {banmask channel} {
 return [mc:sc:errchk mc:sc:inter:existchanban_ [list $banmask $channel]]
}
proc mc:sc:inter:existchanban_ {banmask channel} {
 foreach lban [chanbans $channel] {
  if {[string match [lindex $lban 0] $banmask]} {return 1}
 };return 0
}

proc mc:sc:inter:strip:color {ar} {
 regsub -all -- {\003([0-9][0-9]?(,[0-9][0-9]?)?)?} $ar "" ar ; return $ar
}
proc mc:sc:inter:strip:bold {ar} {regsub -all -- "\002" $ar "" ar; return $ar}
proc mc:sc:inter:strip:uline {ar} {regsub -all -- "\037" $ar "" ar; return $ar}
proc mc:sc:inter:strip:reverse {ar} {regsub -all -- "\026" $ar "" ar; return $ar}
proc mc:sc:inter:strip:all {ar} {
 return [mc:sc:inter:strip:reverse [mc:sc:inter:strip:uline [mc:sc:inter:strip:bold [mc:sc:inter:strip:color $ar]]]]
}

proc mc:sc:filt {data} {
  regsub -all -- \\\\ $data \\\\\\\\ data ; regsub -all -- \\\[ $data \\\\\[ data ; regsub -all -- \\\] $data \\\\\] data
  regsub -all -- \\\} $data \\\\\} data ; regsub -all -- \\\{ $data \\\\\{ data ; regsub -all -- \\\" $data \\\\\" data ; return $data
}

## SVS v2.0
if {(![info exists mc_sc(svs:enabled)]) ||
    (![regexp -- {^(0|1)$} $mc_sc(svs:enabled)])} {set mc_sc(svs:enabled) 0}
if {(![info exists mc_sc(svs:check)]) ||
    ([regexp -- {[^0-9]} $mc_sc(svs:check)])} {set mc_sc(svs:check) 0}
if {![info exists mc_sc(svs:notify)]} {set mc_sc(svs:notify) $owner}
if {(![info exists mc_sc(svs:stableonly)]) ||
    (![regexp -- {^(0|1)$} $mc_sc(svs:stableonly)])} {set mc_sc(svs:stableonly) 0}
foreach bind [binds mc:sc:svs:time] {
 unbind [lindex $bind 0] [lindex $bind 1] [lindex $bind 2] [lindex $bind 4]
}
foreach command [info commands mc:sc:svs:time] {rename $command ""}
if {$mc_sc(svs:enabled)} {
 if {($mc_sc(svs:check) > "23") || ($mc_sc(svs:check) < "0")} {set mc_sc(svs:check) 00}
 if {[string length $mc_sc(svs:check)] == "1"} {set mc_sc(svs:check) 0$mc_sc(svs:check)}
 bind time - "00 $mc_sc(svs:check) *" mc:sc:svs:time
 proc mc:sc:svs:time {{args ""}} {
  global mc_sc
  if {[catch {socket -async $mc_sc(svs:server) $mc_sc(svs:port)} sid]} {;\
   putlog "SVS Error\[$mc_sc(svs:script)/$mc_sc(svs:version)\]:  $sid"
   return 1
  }
  fconfigure $sid -blocking 0 -buffering line
  set tout [after 60000 "mc:sc:svs:interface $sid timeout"]
  fileevent $sid readable "mc:sc:svs:interface $sid $tout"
  puts $sid "GET $mc_sc(svs:get)?$mc_sc(svs:query) HTTP/1.0\
           \nHost: $mc_sc(svs:server)\n"
  flush $sid
 }
}
proc mc:sc:svs:interface {sid tout} {
 global mc_sc
 if {$tout == "timeout"} {
  putlog "SVS Warning\[$mc_sc(svs:script)/$mc_sc(svs:version)\]:  SVS Server timed out."
  close $sid
  return 0
 }; after cancel $tout
 set temp 0
 while {![eof $sid]} {
  gets $sid get
  if {$temp < "2"} {
   if {$get == ""} {incr temp; if {$temp == "1"} {set temp 2}}
   continue
  }; if {$get == ""} {continue}
  switch -- [lindex $get 0] {
   003 {
    set reply [lrange $get 1 end]
    if {[lindex $reply 0] != $mc_sc(svs:script)} {
     putlog "SVS Error\[$mc_sc(svs:script)/$mc_sc(svs:version)\]:  SVS Server sent wrong info, got [lindex $reply 0]"
     break   
    }
    if {$mc_sc(svs:stableonly)} {
     set temp [string range $mc_sc(svs:version) 0 8]999
    } else {set temp [string range $mc_sc(svs:version) 0 11]}
    if {[lindex $reply 1] > $temp} {
     set note [lindex $reply 5]
     regsub -- %0 $note [lindex $reply 0] note
     regsub -- %1 $note [lindex $reply 1] note
     regsub -- %2 $note [lindex $reply 2] note
     regsub -- %3 $note [lindex $reply 3] note
     regsub -- %4 $note [lindex $reply 4] note
     regsub -- %version $note $mc_sc(version) note
     foreach to [split $mc_sc(svs:notify) ",; "] {
      if {$to == ""} {continue}
      regsub -- %nick $note $to outnote
      if {[string match *$outnote* [set unotes [notes $to -[notes $to]]]]} {
       set temp 0
       foreach unote $unotes {
        if {$outnote == [lindex $unote 2]} {set temp 1; break}
       }; if {$temp} {continue}
      }
      switch -- [sendnote SVS $to $outnote] {
       0 {
        if {![validuser $notify]} {set x "invalid user"} else {set x "unknown error"}
        putlog "SVS Error\[$mc_sc(svs:script)/$mc_sc(svs:version)\]:  Trying to send note to $to, $x."
       }
       3 {putlog "SVS Error\[$mc_sc(svs:script)/$mc_sc(svs:version)\]:  Trying to send note to $to, notebox too full!"}
      }
     }
    }
   }
  }
 }; close $sid
}
## ^

putlog "$mc_sc(script) $mc_sc(version) by MC_8 loaded."
