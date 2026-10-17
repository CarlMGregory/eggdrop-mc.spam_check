##
# Spam Check v2.1 by MC_8 - Carl M. Gregory <gregory@worldinter.net>
#  This script will only work on eggdrop 1.5+ series.
#
# If you have any questions/comments/idea's, please email me!
# ( Include the script name and version in the title, if you do email me. )
#
# My SVS Website - http://mc.purehype.net/
##

##
# This script plus alot of other mc.* scripts are best found at
# http://bseen.tclslave.net/
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
# History
##
# v2.1 (08.27.01)
#  MC_8 - Found problems with DCC and MESSAGE cases when checking the mc_sc(act:wrds).
#         If act:wrds was set to more than 1 thing, DCC and MESSAGE would require that
#         all match, it should be if any match.
#  MC_8 - Alchera - Fixed issues with string index not recognizing the "e" or "end",
#                   quickly fixed with [expr [string length $var]-1] insted of "e".
#  MC_8 - Cleaned up relay message, if another bot is going to relay more than 1 channel,
#         it is only nessessary to say "Spam Check: Bot relay from Africana regarding xxx."
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
set mc_sc(ign:wrds) "addhost info who ident help voice whois pass op invite go key die jump memory save rehash reset status dent"

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
#     You can also specify a type of 10 to 19 which correspond to masks 0 to 9, but
#     instead of using a * wildcard to replace portions of the host.domain, it uses ?
#     wildcards to replace the numbers in the address.
set mc_sc(bant) 2

# [0=no/1=yes] What if the user isn't in the channel... Do you want me to
# still set the ban globally?
set mc_sc(glob_ban) 1

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

## MC SVS (Script Version Server) v1.2 ##
# Do you want the bot to connection to MC_8's SVS to see if there are newer versions
# of this script avilable?  It will only tell you -- It's up to you to get the newest
# version (I decided not to auto update the code, there may be new features in the
# newest script that may require your attention).
# 0=no/1=yes
set mc_sc(svs:enabled) 1

# Once a day the script will check with the SVS -- this specifies when
# that should happen.  The setting should be the hour (military).
# examples:
#  set mc_sc(svs:check) 0  ;#This is at Midnight
#  set mc_sc(svs:check) 5  ;#This is at 5am
#  set mc_sc(svs:check) 13  ;#This is at 1pm
#  set mc_sc(svs:check) 23  ;#This is at 11pm
set mc_sc(svs:check) 3

# Upon finding a newer version, who do you want to notify via note?
# Only the admin of the bot should really be worried about these notes,
# there the ones that keep everything up to par on the bots.
# Seperate each user with a " " (space).
set mc_sc(svs:notify) "MC_8"

# Do you want even beta version notified to whomever you have set?  Or just
# stable releases of the script?
#  0 = Tell me about all version, even beta versions.
#  1 = Just tell me about new stable versions.
set mc_sc(svs:stableonly) 0






##

##
# Coding 
##
set mc_sc(version) v2.1
set mc_sc(svs:script) "spamcheck 002001000000"
set mc_sc(svs:server) "mc.purehype.net 8085"

if {$numversion < "1050000"} {
 putlog "Spam Check $mc_sc(version) by MC_8 is for eggdrop 1.5+ series only."
 putlog "Spam Check $mc_sc(version) will not work with eggdrop $version."
 putlog "Spam Check $mc_sc(version) not loaded."
 return 1
}
if {![string match *mc:sc:cycle* [timers]]} {
 set min [lindex [split $mc_sc(sc:cyclerate) :] 0]
 set max [lindex [split $mc_sc(sc:cyclerate) :] 1]
 if {$min >= $max} {set cycletime $max} {
  set cycletime [rand [expr $max+1]]
  while {$cycletime < $min} {set cycletime [rand [expr $max+1]]}
 }
 timer $cycletime mc:sc:cycle
}
if {[info exists mc_sc(joind:active)]} {unset mc_sc(joind:active)}
set mc_sc(ign:wrds) [string tolower $mc_sc(ign:wrds)]
setudef flag spamcycle ; setudef flag spamcheck

bind dcc m| spamcheck mc:sc:dcc:command:spamcheck
proc mc:sc:dcc:command:spamcheck {hand idx args} {
 mc:sc:cycle ; putdcc $idx "Spam Check is cycling channels."
 return 1
}

bind msg m| spamcheck mc:sc:msg:command:spamcheck
proc mc:sc:msg:command:spamcheck {nick uhost hand args} {
 mc:sc:cycle ; putserv "PRIVMSG $nick :Spam Check is cycling channels."
 return 1
}

proc mc:sc:cycle {} {
 global mc_sc numversion botnick
 foreach chan [string tolower [channels]] {
  if {[string match "* -spamcycle *" " [channel info $chan] "]} {continue}
  if {[isop $botnick $chan]} {
   set onlyop 1
   foreach user [chanlist $chan] {
    if {($user != $botnick) && [isop $user $chan]} {set onlyop 0 ; break}
   } ; if {$onlyop} {putlog "Spam Check, Cannot cycle $chan, I am the only op.";continue}
  }
  if {($numversion >= "1032800") && $mc_sc(joind)} {
   if {[string match *-inactive* [channel info $chan]]} {
    channel set $chan +inactive
    utimer $mc_sc(joind) "channel set [mc:sc:filt $chan] -inactive"
    if {![string match "*unset mc_sc(joind:active)*" [utimers]]} {
     utimer [expr $mc_sc(joind)+[expr [llength [channels]]*5]] "catch {unset mc_sc(joind:active)}"
    } ; set mc_sc(joind:active) 1
   }
  } {
   if {$mc_sc(chan:cycle:message) != ""} {
    putserv "PART $chan :$mc_sc(chan:cycle:message)"
   } {putserv "PART $chan"}
  }
 }
 set min [lindex [split $mc_sc(sc:cyclerate) :] 0]
 set max [lindex [split $mc_sc(sc:cyclerate) :] 1]
 if {$min >= $max} {set cycletime $max} {
  set cycletime [rand [expr $max+1]]
  while {$cycletime < $min} {set cycletime [rand [expr $max+1]]}
 }
 if {![string match *mc:sc:cycle* [timers]]} {timer $cycletime mc:sc:cycle}
}

bind notc - * mc:sc:notc:message
bind msgm - * mc:sc:msgm:message
bind ctcp - "DCC" mc:sc:dcc:message
bind raw - INVITE mc:sc:raw:invite

proc mc:sc:raw:invite {from key args} {
 global mc_sc botnick
 if {$mc_sc(warn:message:invite) == ""} {return 0}
 if {$mc_sc(act:strip)} {set argz [mc:sc:inter:strip:all [join $args]]} {set argz [join $args]}
 set argz "invite [string trimleft [lindex [split [join $argz]] 1] :]"
 set return 1
 foreach word [split $mc_sc(act:wrds) \n] {
  if {[string match [string tolower [string trim $word]] [string tolower $argz]]} {
   set return 0;break
  }
 };if {$return} {return}
 set nick [string range $from 0 [expr [string first ! $from]-1]]
 set uhost [string range $from [expr [string first ! $from]+1] end]
 mc:sc:message $nick $uhost [finduser $from] invite;return 0
}

proc mc:sc:notc:message {nick uhost hand args {dest ""}} {
 global mc_sc botnick ; if {$dest == ""} {set dest $botnick}
 if {([lindex [split $args] 0] == "DCC") || ($dest != $botnick)} {return}
 if {$mc_sc(warn:message:notice) == ""} {return}
 if {$mc_sc(act:strip)} {set argz [mc:sc:inter:strip:all $args]} {set argz $args}
 set return 1
 foreach word [split $mc_sc(act:wrds) \n] {
  if {[string match [string tolower [string trim $word]] [string tolower $argz]]} {
   set return 0;break
  }
 };if {$return} {return}
 foreach command $mc_sc(ign:wrds) {
  if {[string tolower [lindex [split $args] 0]] == $command} {return 0}
 };mc:sc:message $nick $uhost $hand notice
}

proc mc:sc:msgm:message {nick uhost hand args} {
 global mc_sc
 if {$mc_sc(warn:message:privmsg) == ""} {return}
 if {$mc_sc(act:strip)} {set argz [mc:sc:inter:strip:all [join $args]]} {set argz [join $args]}
 set return 1
 foreach word [split $mc_sc(act:wrds) \n] {
  if {[join $word] == ""} {continue}
  if {[string match [string tolower [string trim $word]] [string tolower $argz]]} {
   set return 0; break
  }
 }; if {$return} {return 0}
 foreach command [string tolower $mc_sc(ign:wrds)] {
  if {[string tolower [lindex [split [join $args]] 0]] == $command} {return 0}
 };mc:sc:message $nick $uhost $hand privmsg
}

proc mc:sc:dcc:message {nick uhost hand dest keyword args} {
 global mc_sc
 switch -- [lindex [join $args] 0] {
  SEND {set method "dccsend [lindex [join $args] 1]"}
  CHAT {return 0}
  default {return 0}
 }
 if {$mc_sc(warn:message:dccsend) == ""} {return 0}
 set argz $method
 if {$mc_sc(act:strip)} {set argz [mc:sc:inter:strip:all $argz]}
 set return 1
 foreach word [split $mc_sc(act:wrds) \n] {
  if {[join $word] == ""} {continue}
  if {[string match [string tolower [string trim $word]] [string tolower $argz]]} {
   set return 0; break
  }
 }; if {$return} {return 0}
 mc:sc:message $nick "$nick!$uhost" $hand "$method";return 0
}

proc mc:sc:message {nick uhost hand method} {
 global mc_sc botnick lastbind
 if {[string tolower $nick] == [string tolower $botnick]} {return}
 if {[info exists mc_sc(ignore:$nick)]} {
  if {![string match "*unset mc_sc(ignore:$nick)*" [utimers]]} {
   utimer 5 "catch {unset mc_sc(ignore:[mc:sc:filt $nick])}"
  } ; return 0
 }
 set mc_sc(ignore:$nick) 1
 utimer 5 "catch {unset mc_sc(ignore:[mc:sc:filt $nick])}"
 set uhost [string range $uhost [expr [string first ! $uhost]+1] end]
 if {[info exists mc_sc(joind:active)]} {
  utimer [expr $mc_sc(joind)+2] "mc:sc:message [mc:sc:filt $nick] [mc:sc:filt $uhost] [mc:sc:filt $hand] {[mc:sc:filt $method]}"
  if {![string match "*unset mc_sc(joind:active)*" [utimers]]} {
   utimer $mc_sc(joind) "unset mc_sc(joind:active)"
  };return
 };set channels "";set i 0
 foreach chan [string tolower [channels]] {
  if {[onchan $nick $chan]} {set i 1;append channels " $chan"}
 };if {!$i} {set channels [string tolower [channels]]}
 foreach chan $channels {
  if {[string match *+inactive* [channel info $chan]]} {continue}
  if {![onchan $botnick $chan]} {
   utimer [expr $mc_sc(joind)+2] "mc:sc:message [mc:sc:filt $nick] [mc:sc:filt $uhost] [mc:sc:filt $hand] {[mc:sc:filt $method]}"
   continue
  }
  if {([string match "* -spamcheck *" " [channel info $chan] "]) ||
      (([isop $nick $chan]) && ($mc_sc(exempt:op))) ||
      (([isvoice $nick $chan]) && ($mc_sc(exempt:voice))) ||
      (($mc_sc(exempt:flags) != "") &&
      ([matchattr $hand $mc_sc(exempt:flags) $chan]))} {continue}
  if {$mc_sc(warnings)} {
   if {[info exists mc_sc(warn:$uhost:$chan)]} {
    if {[set mc_sc(warn:$uhost:$chan) [expr $mc_sc(warn:$uhost:$chan)+1]] > $mc_sc(warnings)} {
     mc:sc:punish [split $nick] [split $uhost] [split $hand] [split $chan] 0 "$method"
    } {mc:sc:punish [split $nick] [split $uhost] [split $hand] [split $chan] 1 "$method"}
   } else {
    set mc_sc(warn:$uhost:$chan) 0
    mc:sc:punish [split $nick] [split $uhost] [split $hand] [split $chan] 1 "$method"
   }
  } else {mc:sc:punish [split $nick] [split $uhost] [split $hand] [split $chan] 0 "$method"}
 }
}

proc mc:sc:punish {nick uhost hand chan warn method} {
 global mc_sc botnick {botnet-nick}
 if {[lindex $method 0] == "dccsend"} {set filename [lindex $method 1];set method dccsend} {
  set filename ""
 }
 if {![isop $botnick $chan]} {
  if {$mc_sc(relay)} {
   putallbots "spamcheck [encrypt $mc_sc(relay:key) "$mc_sc(relay:key)+${botnet-nick}"] [split $nick] $uhost [split $hand] [split $chan] $warn $method"
  }
  if {$mc_sc(ban:anyhow)} {
   set ban [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)]
   set comment [mc:sc:inter:replace $mc_sc(exc:message:$method) "%filename $filename"]
   if {[string match *! $mc_sc(exc:ban)]} {
    set time [lindex [split $mc_sc(exc:ban) !] 0]
    set options "sticky"
   } {
    set time $mc_sc(exc:ban)
    set options "none"
   }
   newban $ban ${botnet-nick} $comment [string trimleft $time @] $options
  };return
 }
 if {$warn} {
  putlog "Spam Check, warning $nick!$uhost: [mc:sc:inter:replace $mc_sc(warn:message:$method) "%filename $filename"]"
  if {$mc_sc(warn:msg) && ([mc:sc:inter:replace $mc_sc(warn:message:$method) "%filename $filename"] != "")} {
   putserv "PRIVMSG $nick :[mc:sc:inter:replace $mc_sc(warn:message:$method) "%filename $filename"]"
  }
  if {[string index $mc_sc(warn:ban) 0] == "@"} {
   set time [string range $mc_sc(warn:ban) 1 end]
   set global 1
  } else {set time $mc_sc(warn:ban);set global 0}
  if {[lindex [split $time !] 0] > -1} {
   if {![lindex [split $time !] 0]} {
    if {(![onchan $nick $chan]) && ($mc_sc(glob_ban)) || $global} {
     foreach chan [string tolower [channels]] {
      if {[string match "* -spamcheck *" " [channel info $chan] "]} {continue}
      putserv "MODE $chan +b [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)]"
      set spamnicks [mc:sc:inter:findchanuser [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)] $chan]
      if {[mc:sc:inter:replace $mc_sc(exc:message:$method) "%filename $filename"] != ""} {
       foreach spammer [split $spamnicks] {putserv "KICK $chan $spammer :[mc:sc:inter:replace $mc_sc(exc:message:$method) "%filename $filename"]"}
      } {foreach spammer [split $spamnicks] {putserv "KICK $chan $spammer"}}
     }
    } else {
     putserv "MODE $chan +b [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)]"
     set spamnicks [mc:sc:inter:findchanuser [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)] $chan]
     if {[mc:sc:inter:replace $mc_sc(warn:message:$method) "%filename $filename"] != ""} {
      foreach spammer [split $spamnicks] {putserv "KICK $chan $spammer :[mc:sc:inter:replace $mc_sc(warn:message:$method) "%filename $filename"]"}
     } {foreach spammer [split $spamnicks] {putserv "KICK $chan $spammer"}}
    }
   } else {
    if {(![onchan $nick $chan]) && ($mc_sc(glob_ban)) || $global} {
     foreach chan [string tolower [channels]] {
      if {[string match "* -spamcheck *" " [channel info $chan] "]} {continue}
      putserv "MODE $chan +b [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)]"
      if {[string index $time [expr [string length $time]-1]] == "!"} {
       set opt "sticky"
       set bantime [string range $time 0 [expr [string length $time]-2]]
      } {
       set opt "none"
       set bantime $time
      }
      newchanban $chan [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)] spamcheck [mc:sc:inter:replace $mc_sc(warn:message:$method) "%filename $filename"] $bantime $opt
      set spamnicks [mc:sc:inter:findchanuser [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)] $chan]
      if {[mc:sc:inter:replace $mc_sc(warn:message:$method) "%filename $filename"] != ""} {
       foreach spammer [split $spamnicks] {putserv "KICK $chan $spammer :[mc:sc:inter:replace $mc_sc(warn:message:$method) "%filename $filename"]"}
      } {foreach spammer [split $spamnicks] {putserv "KICK $chan $spammer"}}
     }
    } else {
     putserv "MODE $chan +b [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)]"
     if {[string index $time [expr [string length $time]-1]] == "!"} {
      set opt "sticky"
      set bantime [string range $time 0 [expr [string length $time]-2]]
     } {
      set opt "none"
      set bantime $time
     }
     newchanban $chan [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)] spamcheck [mc:sc:inter:replace $mc_sc(warn:message:$method) "%filename $filename"] $bantime $opt
     set spamnicks [mc:sc:inter:findchanuser [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)] $chan]
     if {[mc:sc:inter:replace $mc_sc(warn:message:$method) "%filename $filename"] != ""} {
      foreach spammer [split $spamnicks] {putserv "KICK $chan $spammer :[mc:sc:inter:replace $mc_sc(warn:message:$method) "%filename $filename"]"}
     } else {foreach spammer [split $spamnicks] {putserv "KICK $chan $spammer"}}
    }
   }
  } else {
   if {$mc_sc(warn:kick)} {
    if {[onchan $nick $chan]} {
     if {[mc:sc:inter:replace $mc_sc(warn:message:$method) "%filename $filename"] != ""} {
      putserv "KICK $chan $nick :[mc:sc:inter:replace $mc_sc(warn:message:$method) "%filename $filename"]"
     } {putserv "KICK $chan $nick"}
    }
   }
  }
 } else {
  putlog "Spam Check, exceeded warnings for $nick!$uhost: [mc:sc:inter:replace $mc_sc(exc:message:$method) "%filename $filename"]"
  if {[string index $mc_sc(exc:ban) 0] == "@"} {
   set time [string range $mc_sc(exc:ban) 1 end]
   set global 1
  } else {set time $mc_sc(exc:ban);set global 0}
  if {[lindex [split $time !] 0] > -1} {
   if {![lindex [split $time !] 0]} {
    if {(![onchan $nick $chan]) && ($mc_sc(glob_ban)) || $global} {
     foreach chan [string tolower [channels]] {
      if {[string match "* -spamcheck *" " [channel info $chan] "]} {continue}
      putserv "MODE $chan +b [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)]"
      set spamnicks [mc:sc:inter:findchanuser [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)] $chan]
      if {[mc:sc:inter:replace $mc_sc(exc:message:$method) "%filename $filename"] != ""} {
       foreach spammer [split $spamnicks] {putserv "KICK $chan $spammer :[mc:sc:inter:replace $mc_sc(exc:message:$method) "%filename $filename"]"}
      } {foreach spammer [split $spamnicks] {putserv "KICK $chan $spammer"}}
     }
    } {
     putserv "MODE $chan +b [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)]"
     set spamnicks [mc:sc:inter:findchanuser [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)] $chan]
     if {[mc:sc:inter:replace $mc_sc(exc:message:$method) "%filename $filename"] != ""} {
      foreach spammer [split $spamnicks] {putserv "KICK $chan $spammer :[mc:sc:inter:replace $mc_sc(exc:message:$method) "%filename $filename"]"}
     } {foreach spammer [split $spamnicks] {putserv "KICK $chan $spammer"}}
    }
   } {
    if {(![onchan $nick $chan]) && ($mc_sc(glob_ban)) || $global} {
     foreach chan [string tolower [channels]] {
      if {[string match "* -spamcheck *" " [channel info $chan] "]} {continue}
      putserv "MODE $chan +b [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)]"
      if {[string index $time [expr [string length $time]-1]] == "!"} {
       set opt "sticky"
       set bantime [string range $time 0 [expr [string length $time]-2]]
      } {
       set opt "none"
       set bantime $time
      }
      newchanban $chan [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)] spamcheck [mc:sc:inter:replace $mc_sc(exc:message:$method) "%filename $filename"] $bantime $opt
      set spamnicks [mc:sc:inter:findchanuser [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)] $chan]
      if {[mc:sc:inter:replace $mc_sc(exc:message:$method) "%filename $filename"] != ""} {
       foreach spammer [split $spamnicks] {putserv "KICK $chan $spammer :[mc:sc:inter:replace $mc_sc(exc:message:$method) "%filename $filename"]"}
      } {foreach spammer [split $spamnicks] {putserv "KICK $chan $spammer"}}
     }
    } {
     putserv "MODE $chan +b [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)]"
     if {[string index $time [expr [string length $time]-1]] == "!"} {
      set opt "sticky"
      set bantime [string range $time 0 [expr [string length $time]-2]]
     } {
      set opt "none"
      set bantime $time
     }
     newchanban $chan [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)] spamcheck [mc:sc:inter:replace $mc_sc(exc:message:$method) "%filename $filename"] $bantime $opt
     set spamnicks [mc:sc:inter:findchanuser [mc:sc:inter:masktype [join [split $nick!$uhost]] $mc_sc(bant)] $chan]
     if {[mc:sc:inter:replace $mc_sc(exc:message:$method) "%filename $filename"] != ""} {
      foreach spammer [split $spamnicks] {putserv "KICK $chan $spammer :[mc:sc:inter:replace $mc_sc(exc:message:$method) "%filename $filename"]"}
     } {foreach spammer [split $spamnicks] {putserv "KICK $chan $spammer"}}
    }
   }
  }
 }
}

bind bot - spamcheck mc:sc:bot:relay
proc mc:sc:bot:relay {from command args} {
 global mc_sc botnick
 set args [join $args]
 if {!$mc_sc(relay)} {return}
 if {[lindex $args 0] != [encrypt $mc_sc(relay:key) "$mc_sc(relay:key)+$from"]} {return}
 set nick [lindex $args 1]
 set uhost [lindex $args 2]
 set hand [lindex $args 3]
 set chan [lindex $args 4]
 set warn [lindex $args 5]
 set method [lindex $args 6]
 if {![validchan $chan]} {return}
 if {[info exists mc_sc(relayblock:$uhost:$chan)]} {
  if {![string match "*unset mc_sc(relayblock:$uhost:$chan)*" [utimers]]} {
   utimer 10 "unset mc_sc(relayblock:[mc:sc:filt $uhost:$chan])"
  };return
 }
 set mc_sc(relayblock:$uhost:$chan) 1
 utimer 10 "unset mc_sc(relayblock:[mc:sc:filt $uhost:$chan])"
 if {[info exists mc_sc(relayblock:$nick)]} {
  if {![string match "*unset mc_sc(relayblock:$nick)*" [utimers]]} {
   utimer 10 "unset mc_sc(relayblock:[mc:sc:filt $nick])"
  }
 } else {
  set mc_sc(relayblock:$nick) 1
  utimer 10 "unset mc_sc(relayblock:[mc:sc:filt $nick])"
  putlog "Spam Check:  Bot relay from $from regarding $nick."
 };mc:sc:punish $nick $uhost $hand $chan $warn $method
}

### Internal use Procs

proc mc:sc:inter:masktype {uhost type} {
 if {![string match "*!*@*.*" $uhost]} {
  set nick [lindex [split $uhost "!"] 0] ; set uhost "$nick![getchanhost $nick]"
  if {$uhost == "$nick!"} {set type "return_nothing"}
 }
 switch -exact $type {
  0 {set ban "*[string range $uhost [string first ! $uhost] end]"}
  1 {set ban "*!*[string trimleft [string range $uhost [expr [string first ! $uhost]+1] end] "~"]"}
  2 {set ban "*!*[string range $uhost [string first @ $uhost] end]"}
  3 {
   set ident [string range $uhost [expr [string first ! $uhost]+1] [expr [string last @ $uhost]-1]]
   set ban "*!*[string trimleft $ident "~"][string range [maskhost $uhost] [string first @ [maskhost $uhost]] end]"
  }
  4 {set ban "*!*[string range [maskhost $uhost] [string last "@" [maskhost $uhost]] end]"}
  5 {set ban $uhost}
  6 {
   set nick [string range $uhost 0 [expr [string first "!" $uhost]-1]]
   set ident [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]]
   set ban "$nick!*[string trimleft $ident "~"][string range $uhost [string last "@" $uhost] end]"
  }
  7 {
   set nick [string range $uhost 0 [expr [string first "!" $uhost]-1]]
   set ban "$nick!*[string range $uhost [string last "@" $uhost] end]"
  }
  8 {
   set nick [string range $uhost 0 [expr [string first "!" $uhost]-1]]
   set ident [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]]
   set ban "$nick!*[string trimleft $ident "~"][string range [maskhost $uhost] [string last "@" [maskhost $uhost]] end]"
  }
  9 {
   set nick [string range $uhost 0 [expr [string first "!" $uhost]-1]]
   set ban "$nick!*[string range [maskhost $uhost] [string last "@" [maskhost $uhost]] end]"
  }
  10 {
   set host [string range $uhost [string last "@" $uhost] end]
   if {[mc:sc:inter:findip [string range $host 1 end]] == "0"} {
    set host [mc:sc:inter:replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set ident [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]]
    set ban "*!$ident$host"
   } {set ban [mc:sc:inter:masktype $uhost 0]}
  }
  11 {
   set host [string range $uhost [string last "@" $uhost] end]
   if {[mc:sc:inter:findip [string range $host 1 end]] == "0"} {
    set host [mc:sc:inter:replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set ident [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]]
    set ban "*!*[string trimleft $ident "~"]$host"
   } {set ban [mc:sc:inter:masktype $uhost 1]}
  }
  12 {
   set host [string range $uhost [string last "@" $uhost] end]
   if {[mc:sc:inter:findip [string range $host 1 end]] == "0"} {
    set host [mc:sc:inter:replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set ban "*!*$host"
   } {set ban [mc:sc:inter:masktype $uhost 2]}
  }
  13 {
   set host [string range $uhost [string last "@" $uhost] end]
   if {[mc:sc:inter:findip [string range $host 1 end]] == "0"} {set ban [mc:sc:inter:masktype $uhost 11]} {set ban [mc:sc:inter:masktype $uhost 3]}
  }
  14 {
   set host [string range $uhost [string last "@" $uhost] end]
   if {[mc:sc:inter:findip [string range $host 1 end]] == "0"} {set ban [mc:sc:inter:masktype $uhost 12]} {set ban [mc:sc:inter:masktype $uhost 4]}
  }
  15 {
   set host [string range $uhost [string last "@" $uhost] end]
   if {[mc:sc:inter:findip [string range $host 1 end]] == "0"} {
    set host [mc:sc:inter:replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set rest [string range $uhost 0 [expr [string last "@" $uhost]-1]]
    set ban $rest$host
   } {set ban [mc:sc:inter:masktype $uhost 5]}
  }
  16 {
   set host [string range $uhost [string last "@" $uhost] end]
   if {[mc:sc:inter:findip [string range $host 1 end]] == "0"} {
    set host [mc:sc:inter:replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set rest "[string range $uhost 0 [expr [string first "!" $uhost]-1]]!*[string trimleft [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]] "~"]"
    set ban $rest$host
   } {set ban [mc:sc:inter:masktype $uhost 6]}
  }
  17 {
   set host [string range $uhost [string last "@" $uhost] end]
   if {[mc:sc:inter:findip [string range $host 1 end]] == "0"} {
    set host [mc:sc:inter:replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set rest "[string range $uhost 0 [expr [string first "!" $uhost]-1]]!*"
    set ban $rest$host 
   } {set ban [mc:sc:inter:masktype $uhost 7]}
  }
  18 {
   set host [string range $uhost [string last "@" $uhost] end]
   if {[mc:sc:inter:findip [string range $host 1 end]] == "0"} {set ban [mc:sc:inter:masktype $uhost 16]} {set ban [mc:sc:inter:masktype $uhost 8]}
  }
  19 {
   set host [string range $uhost [string last "@" $uhost] end]
   if {[mc:sc:inter:findip [string range $host 1 end]] == "0"} {set ban [mc:sc:inter:masktype $uhost 17]} {set ban [mc:sc:inter:masktype $uhost 9]}
  }
  return_nothing {set ban ""}
  default {set ban "*!*[string range $uhost [string first "@" $uhost] end]"}
 }
 set _nick [lindex [split $ban !] 0]
 set _ident [string range $ban [expr [string first ! $ban]+1] [expr [string last @ $ban]-1]]
 set _host [string range $ban [expr [string last @ $ban]+1] end]
 if {$_ident != [set temp [string range $_ident [expr [string length $_ident]-9] end]]} {
  set _ident *[string trimleft $temp *]
 }
 if {$_host != [set temp [string range $_host [expr [string length $_host]-63] end]]} {
  set _host *[string trimleft $temp *]
 } ; return $_nick!$_ident@$_host
}

proc mc:sc:inter:findip {args} {
 catch {unset mc_found_ip}
 if {![string match *.*.*.* $args]} {return 0}
 foreach arg $args {
  if {[string match *.*.*.* $arg]} {
   set mc_testa [split $arg "."] ; set i 0
   while {[llength $mc_testa] != $i} {
    set mc_test [lrange $mc_testa $i end]
    if {[string length [lindex $mc_test 1]]<4 && [string length [lindex $mc_test 2]]<4} {
     if {[lindex $mc_test 1] < 256 && [lindex $mc_test 2] < 256 && [lindex $mc_test 1] >= 0 && [lindex $mc_test 2] >= 0} {
      set first "abcdefghi"
      if {[string index [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 1]] <= 9 && [string index [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 1]] >= 0} {
       set first [string range [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 1] end]
       if {[string index [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 2]] <= 9 && [string index [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 2]] >= 0} {
        set first [string range [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 2] end]
        if {[string index [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 3]] <= 9 && [string index [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 3]] >= 0} {
         set first [string range [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 3] end]
        }
       }
      }
      set second [lindex $mc_test 1] ; set third [lindex $mc_test 2] ; set fourth "abcdefghi"
      if {[string index [lindex $mc_test 3] 0] <= 9 && [string index [lindex $mc_test 3] 0] >= 0} {
       set fourth [string index [lindex $mc_test 3] 0]
       if {[string index [lindex $mc_test 3] 1] <= 9 && [string index [lindex $mc_test 3] 1] >= 0} {
        set fourth $fourth[string index [lindex $mc_test 3] 1]
        if {[string index [lindex $mc_test 3] 2] <= 9 && [string index [lindex $mc_test 3] 2] >= 0} {
         set fourth $fourth[string index [lindex $mc_test 3] 2]
        }
       }
      }
      if {($first < 256) && ($second < 256) && ($third < 256) &&
          ($fourth < 256) && ($first > 0) && ($second > 0) &&
          ($third > 0) && ($fourth > 0) && ([string index $first 0] > 0) &&
          ([string index $second 0] > 0) && ([string index $third 0] > 0) &&
          ([string index $fourth 0] > 0)} {
       if {[info exists mc_found_ip]} {
        set mc_found_ip "$mc_found_ip $first.$second.$third.$fourth"
       } {set mc_found_ip $first.$second.$third.$fourth}
      }
     }
    } ; incr i +1
   }
  }
 } ; if {[info exists mc_found_ip]} {return $mc_found_ip} {return 0}
}

proc mc:sc:inter:replace {string subs} {
 if {[llength $subs] == "1"} {set subs [lindex $subs 0]}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- [lindex $subs $i] $string [lindex $subs [expr $i+1]] string
 } ; return $string
}

proc mc:sc:inter:findchanuser {hostmask channel} {
 if {![validchan $channel]} {return -code error "no such channel record"} ; set buffer ""
 foreach user [chanlist $channel] {
  if {[string match $hostmask "$user![getchanhost $user $channel]"]} {set buffer "$buffer $user"}
 } ; return [join [split $buffer] " "]
}

proc mc:sc:inter:strip:color {ar} {
 set argument ""
 if {![string match ** $ar]} {return $ar} ; set i -1 ; set length [string length $ar]
 while {$i < $length} {
  if {[string index $ar $i] == ""} {
   set wind 1 ; set pos [expr $i+1]
   while {$wind < 3} {
    if {[string index $ar $pos] <= 9 && [string index $ar $pos] >= 0} {
     incr wind 1 ; incr pos 1} {set wind 3
    }
   }
   if {[string index $ar $pos] == "," && [string index $ar [expr $pos + 1]] <= 9 &&
       [string index $ar [expr $pos + 1]] >= 0} {
    set wind 1 ; incr pos 1
    while {$wind < 3} {
     if {[string index $ar $pos] <= 9 && [string index $ar $pos] >= 0} {
      incr wind 1 ; incr pos 1} {set wind 3
     }
    }
   }
   if {$i == 0} { 
    set ar [string range $ar $pos end] 
    set length [string length $ar] 
   } { 
    set ar "[string range $ar 0 [expr $i - 1]][string range $ar $pos end]" 
    set length [string length $ar] 
   }
   set argument "$argument[string index $ar $i]"
  } {incr i 1}
 }
 set argument $ar
 return $argument
}

proc mc:sc:inter:strip:bold {ar} {
 set argument ""
 if {[string match ** $ar]} {
  set i 0
  while {$i <= [string length $ar]} { 
   if {![string match  [string index $ar $i]]} { 
    set argument "$argument[string index $ar $i]"
   } ; incr i 1
  }
 } {set argument $ar}
 return $argument
}

proc mc:sc:inter:strip:uline {ar} {
 set argument ""
 if {[string match ** $ar]} {
  set i 0
  while {$i <= [string length $ar]} { 
   if {![string match  [string index $ar $i]]} { 
    set argument "$argument[string index $ar $i]"
   } ; incr i 1
  }
 } {set argument $ar}
 return $argument
}

proc mc:sc:inter:strip:reverse {ar} {
 set argument ""
 if {[string match ** $ar]} {
  set i 0
  while {$i <= [string length $ar]} { 
   if {![string match  [string index $ar $i]]} { 
    set argument "$argument[string index $ar $i]"
   } ; incr i 1
  }
 } {set argument $ar}
 return $argument
}

proc mc:sc:inter:strip:all {ar} {
 return [mc:sc:inter:strip:reverse [mc:sc:inter:strip:uline [mc:sc:inter:strip:bold [mc:sc:inter:strip:color $ar]]]]
}

## sindex procedures (by MC_8 & guppy)
proc mc:sc:slength {str} {return [llength $str]}
proc mc:sc:sindex {str index} {return [lindex [split $str] $index]}
proc mc:sc:srange {str s e} {return [lrange [split $str] $s $e]}
proc mc:sc:filt {data} {
 return [join [split [join [split [join [split [join [split [join [split [join [split $data \\] \\\\] \[] \\\[] \]] \\\]] \}] \\\}] \{] \\\{] \"] \\\"]
}
proc mc:sc:unfilt {data} {
 regsub -all -- \\\\\\\[ $data \[ data;regsub -all -- \\\\\\\] $data \] data;regsub -all -- \\\\\\\} $data \} data
 regsub -all -- \\\\\\\{ $data \{ data;regsub -all -- \\\\\\\" $data \" data;regsub -all -- \\\\\\\\ $data \\ data;return $data
}
## sindex end

if {$mc_sc(svs:enabled)} {
 if {($mc_sc(svs:check) > "23") || ($mc_sc(svs:check) < "0")} {set mc_sc(svs:check) 00}
 if {[string length $mc_sc(svs:check)] == "1"} {set mc_sc(svs:check) 0$mc_sc(svs:check)}
 if {$mc_sc(svs:stableonly)} {
  set mc_sc(svs:script) [string range $mc_sc(svs:script) 0 [expr [string length $mc_sc(svs:script)]-4]]999
 }
 catch {unbind time - "00 $mc_sc(svs:oldcheck) * * *" mc:sc:svs:time}
 set mc_sc(svs:oldcheck) $mc_sc(svs:check)
 bind time - "00 $mc_sc(svs:check) * * *" mc:sc:svs:time
 proc mc:sc:svs:time {min hour day month year} {
  global mc_sc
  catch {control [connect [lindex $mc_sc(svs:server) 0] [lindex $mc_sc(svs:server) 1]] mc:sc:svs:interface}
 }
}
proc mc:sc:svs:interface {idx args} {
 global mc_sc;set args [join $args]
 switch -- [lindex $args 0] {
  "" {return 1}
  000 {putdcc $idx q}
  002 {putdcc $idx [lindex $mc_sc(svs:script) 0]}
  003 {
   set args [lrange $args 1 end]
   if {[lindex $args 0] != [lindex $mc_sc(svs:script) 0]} {return 0}
   putdcc $idx q
   if {[lindex $args 1] > [lindex $mc_sc(svs:script) 1]} {
    set note [mc:sc:svs:replace [lindex $args 7] "%0 {[lindex $args 0]} %1 {[lindex $args 1]} %2 {[lindex $args 2]}"]
    set note [mc:sc:svs:replace $note "%3 {[lindex $args 3]} %4 {[lindex $args 4]} %5 {[lindex $args 5]}"]
    set note [mc:sc:svs:replace $note "%6 {[lindex $args 6]} %8 {[lindex $args 8]} %version {$mc_sc(version)}"]
    set note [mc:sc:svs:replace $note "%9 {[lindex $args 9]} %10 {[lindex $args 10]} %11 {[lindex $args 11]}"]
    set note [mc:sc:svs:replace $note "%12 {[lindex $args 12]} %13 {[lindex $args 13]} %14 {[lindex $args 14]}"]
    set note [mc:sc:svs:replace $note "%15 {[lindex $args 15]} %16 {[lindex $args 16]} %17 {[lindex $args 17]}"]
    set note [mc:sc:svs:replace $note "%18 {[lindex $args 18]} %19 {[lindex $args 19]} %20 {[lindex $args 20]}"]
    foreach notify [join [split $mc_sc(svs:notify) ",;"]] {
     set outnote [mc:sc:svs:replace $note "%nick {$notify}"]
     if {[string match "*$outnote*" "[notes $notify -[notes $notify]]"]} {
      set cont 0
      foreach unote [notes $notify -[notes $notify]] {
       if {$outnote == [lindex $unote 2]} {set cont 1;break}
      };if {$cont} {continue}
     }
     switch -- [sendnote SVS $notify $outnote] {
      0 {putlog "MC SVS for [lindex $mc_sc(svs:script) 0] had some errors updating $notify on current version of script; unknown reason!"}
      3 {putlog "MC SVS for [lindex $mc_sc(svs:script) 0] had some errors updating $notify on current version of script; notebox too full!"}
     }
    }
   }
  }
 };return 0
}
proc mc:sc:svs:replace {string subs} {
 if {[llength $subs] == "1"} {set subs [lindex $subs 0]}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- [lindex $subs $i] $string [lindex $subs [expr $i+1]] string
 } ; return $string
}

putlog "Spam Check $mc_sc(version) by MC_8 loaded."