##
# Spam Check v2.3
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.5.5 or greater.
#
# My Website - http://mc.purehype.net:81/
# Have a bug?  http://mc.purehype.net:81/bugzilla/
##

##
# This script is more focused on catching Onjoin/Onpart spammers.  If you're looking
# for an anti spam script that will catch people saying, for instence, "JOIN #LAMER
# JOIN #LAMER JOIN #LAMER" or something to that effect in your channel, I recomend
# mc.badwords.
#
# This script is probably a little overboard for newbie bot owners... basicaly the
# logics behind it is... no one should be /msg'n this bot.. so EVERYTHING will be
# considered spam.  Of course, you can specify what it to be ignored (like, HELP --
# and other message commands already proposed by eggdrop).
#
# Bot will cycle the channel and listen for notices, DCC's, and messages.  Any
# detected onjoin/onpart will be processed for a warning/kick/ban.
#
# This script works best if you own 2 or more bots and they are linked and they are
# using the needops script.  Otherwise, someone is going to have to manually op the
# bot every time it cycles (unless your lame and use the +a flag).
##

##
# History has been moved to the bottom of the file.
##

##
# Commands
##
# spamcheck [channel]
#   Forces the bot to cycle.  If channel is specified it will cycle that channel,
#   otherwise it will cycle all channels.
#     Required access:  Global 'm'.
#     Command console:  Dcc and Msg
#
# chanset <#channel> <+/->mc.spamcheck
#   This enables (+) or disables (-) the script for the particular channel.
#     Command console:  Dcc
#
# chanset <#channel> <+/->mc.spamcycle
#   This enables (+) or disables (-) the ability of the script to cycle the channel
#   to help detect onjoin spam.
#     Command console:  Dcc
##

##
# Settings
##

# What command words do you want to ignore?  The command word would be the first word
# the user would say, like "seen" or "help" or "op".  List all ignored words,
# seperated by spaces.
set mc_sc(ign:wrds) "addhost info who ident help voice whois pass op invite go key die jump memory save rehash reset status dent notes"

# What word strings do you want to listen for?  Seperate each string with a new line.
# Wildcards are accepted.  If you want it to listen to everything (like in previous
# versions), just have 1 line that states a * wildcard.
# To match an invite, it get's passed as;
#     "invite #channel"
# To match a DCC Send, it get's passed as;
#     "dccsend filename".
# I will give you 2 examples, the first (commented out) will contain 5 character
# strings to watch for ONLY.  The second example (uncommented) states to watch for
# anything and everything.
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

# [0=no/1=yes] Do you want to strip color/bold/uline/reverse/normal characters from
# text?  Useful only if you're listening for certin character strings and not just
# everything.
# Example: Some people get past the kick/ban by puting this color character
#          (invisable in mIRC) inbetween words.  Such as:  www.something.net
set mc_sc(act:strip) 1

# How many mins between cycles do you want?  Set it to minimum:maximum, the script
# will randomly pick a number between them.
# Example: 5:10 == The script will pick a number between 5 and 10 and use that for
#                  the cycle time, will pick another number next cycle point.
# This makes the bot a little less suspicious.  Set to 0:0 to turn off the cycling of
# the channels.
set mc_sc(sc:cyclerate) 15:60

# Set a list of irc nicknames you would like the bot to cycle through when the bot
# performed a spam cycle.  Seperate each nickname with a space.  If the nickname has
# a [ or ], eacape it (ie, \[ or \]).  Set this to "" to disable and just stick with
# the nick (and alt-nick) set in the configs file.
set mc_sc(ircnicks) "manor warez zeraw snatch slash smarz snack jar0 cake lars mastah beejay"

# When the bot cycles the channel for spam, you can restrict it to only cycle if
# certin flagged users are opped in the channel (example, at least a +b| user,
# another bot).  Set valid flags here, flag syntax is <global>|<channel>.  Set to -|-
# for any user opped is 'ok'.
set mc_sc(cycle_opped_flags) -|-

# If you don't want to cycle if the channel is at a certin mode, set it here.  You
# can set as many as you like, seperate each set with a space.  Set this to "" to
# disable.
# Example: "+i-nt +k +sm" == Will not cycle if the channel has a +i, and does NOT
#                            have a +n and a +t.  Or will not cycle if the channel
#                            has a +k.  Or will not cycle if the channel has a +s and
#                            +m.
set mc_sc(nocycle:mode) ""

# How long do you want to stay gone from the channel?  The bot will /part and wait x
# amount of seconds before /join'n.  (Only for eggdrop1.3.28 and greater).  Set to 0
# for quick cycle.
set mc_sc(joind) 10

# If the above method (mc_sc(joind)) is 0 or your bot is older than 1.3.28, it will
# allow you to specify a part message.  What do you want for a part message?  Set to
# "" for no message.
# NOTE:  If you set a message, it's more obvious the bot is doing spam checking.
set mc_sc(chan:cycle:message) ""

# [1=yes/0=no] Do you want to exempt oped users if they are found with an onjoin?
set mc_sc(exempt:op) 1

# [1=yes/0=no] Do you want to exempt voiced users if they are found with an onjoin?
set mc_sc(exempt:voice) 1

# What flags do you want to exempt if they are found with an onjoin?  Set to "" if
# you want to disable this (no flags exemption).
# Flag format: <global flag>|<channel flag>
set mc_sc(exempt:flags) "bn|n"

# How many warnings do you want to give before executing a kick/ban.
set mc_sc(warnings) 0

# What do you want the warning message to say?   You can specify a different message
# depending on the method in which the user contacted the bot.
# Replacment text:
#   %filename -> Will be replaced with the name of the file the user was trying to
#                send -- naturally, this is only valid for dccsend.
#
# If you don't want to listen for one of these spam methods, set the one in in
# particular to "".
# Example: If you only want the script to listen for dccsends (for virus senders) and
#          nothing else, set everything (except for the dccsend one) to "".
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
#   0 == server ban, not an actual ban entry in the bot
#   1 <= Any numbers above 0 are considered the number of min's the user is baned in
#        the bot's banlist.
# If you want the ban to be sticky, put a ! behind the the number (ie: 3!).  If you
# want the ban to be global, rather than channel specific, # put a "@" infront of it
# (ie: @3!).
set mc_sc(warn:ban) -1

# After exceeding warnings, do you want to ban the user?
#  -1 == don't ban
#   0 == server ban, not an actual ban entry in the bot
#   1 <= Any numbers above 0 are considered the number of mins the user is banned in
#        the bot's banlist.
# If you want the ban to be sticky, put a ! behind the number (ie: 3!).  If you want
# the ban to be global, rather than channel specific, put a "@" infront of it (ie:
# @3!).
set mc_sc(exc:ban) 43200

# What do you want the ban message to say?  This is the message the user will get
# after exhausting all his/her warnings.  You can specify a different message
# depending on the method in which the user contacted the bot.
# Replacement text:
#   %filename -> Will be replaced with the name of the file the user was trying to
#                send -- naturally, this is only valid for dccsend.
set mc_sc(exc:message:dccsend) "Anti Spam, Don't dcc send me anything.  That includes %filename!"
set mc_sc(exc:message:privmsg) "Anti Spam, Don't message me."
set mc_sc(exc:message:notice) "Anti Spam, Don't notice me."
set mc_sc(exc:message:invite) "Anti Spam, Don't invite me to your lame channel."

# Set this to the ban mask type you want,
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
#     You can also specify a type of 10 to 19 which correspond to masks 0 to 9.
#     But if the host.domain is a;
#       hostname = Instead of using a * wildcard to replace portions of the
#                  host.domain, it replaces the numbers in the host.domain with
#                  a '?' (question mark) wildcard.
#       ip       = It will mask as normal, with no '?' (question mark)
#                  replacments as does hostname.
set mc_sc(bant) 2

# [0=no/1=yes] If the bot isn't op'd, do you want it to ask the bot's in the botnet
# to punish the user?
# Information:  1) The recieving bot must have this script.  Sure the other bot
#                  yielding this script can have the cycle feature turned off, that
#                  way it'll look a little sneakier on how the receiving bot know's
#                  the spammer is spamming.
#               2) If you set this to 1, this also enables the ability to receive...
#                  as well as send out the relays.
set mc_sc(relay) 1

# If the above (mc_sc(relay)) is set to 1, then what do you want to set the key to?
# The key is the encryption base of the botnet message.  Both the sending bot and the
# receiving bot must have the same key.  This is to prevent some other bot on the
# botnet sending a fake relay request.
set mc_sc(relay:key) "spamcheck"

# [0=no/1=yes] If the bot detects spam, but the bot isn't op'd, do you want the bot
# to add the spammer to the global ban list?  Ban time goes off mc_sc(exc:ban)
# setting.
set mc_sc(ban:anyhow) 1

# [0=no/1=yes] Do you want to enable the 'spamcheck' /msg command?  Downside, someone
# could ghost close enough to match one of your uses that has access to such a
# command and be able to perform the command causing the bot to join/part flood.  I
# could put a password restriction on the /msg command, but no one has requested it
# so I will hold off untill then.
set mc_sc(enable:msgcmd) 0

## MC SVS (Script Version Service) v2.2 ##
# Do you want the bot to connection to MC_8's SVS server to see if there's a
# newer version of this script available?  It will only tell you, it's up to you
# to get the newest version and re-configure it as needed.
#   0 = No, do not enable SVS.
#   1 = Yes, but only inform me of non beta versions.
#   2 = Yes, inform me of all new versions (beta and stable).
set mc_sc(svs:mode) 2

# Upon finding a newer version, whom do you want to notify?  The notification is
# sent via 'note'.  Separate each user with a space.  For those whom know TCL;
# do not put this in list format, keep it in string format.
set mc_sc(svs:notify) "MC_8"


##
# Done with configurations, do not edit past here unless you know TCL.
##

#Script:mc_sc

set mc_sc(script)      "Spam Check"
set mc_sc(version)     "v2.3"
set mc_sc(svs:script)  "spamcheck"
set mc_sc(svs:version) "00200300000"
set mc_sc(svs:server)  "mc.purehype.net"
set mc_sc(svs:port)    "81"
set mc_sc(svs:get)     "/"
set mc_sc(svs:query)   "svs=$mc_sc(svs:script)&version=$mc_sc(svs:version)"

catch {unset temp}
if {![info exists numversion] || ($numversion < "1050500")} {
	set temp(tag) "$mc_sc(script) $mc_sc(version)"
	putlog "$temp(tag) by MC_8 will only work on eggdrop 1.5.5 or greater."
	putlog "$temp(tag)  will not work with eggdrop $version."
	putlog "$temp(tag)  not loaded."
	return 1
}

setudef flag mc.spamcycle; setudef flag mc.spamcheck

# Error system, v2.1
proc mc:sc:error {bindproc error {arg ""}} {
	global mc_sc version lastbind
	putlog "Error in script $mc_sc(script) $mc_sc(version)."
	if {[info exists lastbind]} {set temp(x) $lastbind} \
	else {set temp(x) -NULL-}
	putlog "       Last bind: $temp(x)"
	putlog "       Procedure: $bindproc"
	putlog "            Args: $arg"
	if {[info exists version]} {set temp(x) $version} \
	else {set temp(x) -NULL-}
	putlog " Eggdrop version: $temp(x)"
	putlog "     TCL version: [info tclversion]"
	putlog "  TCL Patchlevel: [info patchlevel]"
	putlog "*** Please tell MC_8 about this BUG!  Visit        "
	putlog "*** http://mc.purehype.net:81/bugzilla/ to do so.  "
	putlog "*** Please include the next line in the bug report."
	error $error
}

proc mc:sc:errchk {command arg} {
	if {[catch {eval $command $arg} return]} {
		mc:sc:error $command $return $arg
		return 0
	}
	return $return
}
# ^

if {![string match *mc:sc:cycle* [timers]]} {
 scan $mc_sc(sc:cyclerate) {%[^:]:%s} min max
 if {$min >= $max} {set cycletime $max} {
  while {[set cycletime [rand [expr $max+1]]] < $min} {}
 }; timer $cycletime mc:sc:cycle
}
catch {unset mc_sc(joind:active)}

bind dcc m| spamcheck mc:sc:dcc:command:spamcheck
proc mc:sc:dcc:command:spamcheck {hand idx arg} {
	return [mc:sc:errchk mc:sc:dcc:command:spamcheck_ [list $hand $idx $arg]]
}
proc mc:sc:dcc:command:spamcheck_ {hand idx arg} {
 global mc_sc
 set chan [lindex [split $arg] 0]
 if {[validchan $chan]} {
  if {![mc:sc:chanflag $chan mc.spamcheck] ||
      ![mc:sc:chanflag $chan mc.spamcycle]} {
   set temp(x) "mc.spamcheck and mc.spamcycle"
   putdcc $idx \
   	"$mc_sc(script):  $chan doesn't have the $temp(x) channel flags enabled."
   return 0
  }
  mc:sc:cycle $chan
  putdcc $idx "$mc_sc(script) is cycling: $chan"
 } else {
  mc:sc:cycle
  putdcc $idx "$mc_sc(script) is cycling: [join [channels] ", "]"
 }; return 1
}

bind msg m| spamcheck mc:sc:msg:command:spamcheck
proc mc:sc:msg:command:spamcheck {nick uhost hand arg} {
	return [mc:sc:errchk mc:sc:msg:command:spamcheck_ [list $nick $uhost $hand $arg]]
}
proc mc:sc:msg:command:spamcheck_ {nick uhost hand arg} {
 global mc_sc
 if {!$mc_sc(enable:msgcmd)} {return 0}
 set chan [lindex [split $arg] 0]
 if {[validchan $chan]} {
  if {![mc:sc:chanflag $chan mc.spamcheck] ||
      ![mc:sc:chanflag $chan mc.spamcycle]} {
   set temp(x) "mc.spamcheck and mc.spamcycle channel flags"
   puthelp "PRIVMSG $nick :$mc_sc(script):  $chan doesn't have the $temp(x) enabled."
   return 0
  }
  mc:sc:cycle $chan
  puthelp "PRIVMSG $nick :$mc_sc(script) is cycling: $chan"
 } else {
  mc:sc:cycle
  puthelp "PRIVMSG $nick :$mc_sc(script) is cycling: [join [channels] ", "]"
 }; return 1
}

proc mc:sc:cycle {{chan ""}} {
	return [mc:sc:errchk mc:sc:cycle_ [list $chan]]
}
proc mc:sc:cycle_ {chan} {
 global mc_sc numversion botnick
 if {[validchan $chan]} {set channels $chan} \
 else {set channels [channels]}
 foreach chan [string tolower $channels] {
  if {![mc:sc:chanflag $chan mc.spamcheck] ||
      ![mc:sc:chanflag $chan mc.spamcycle]} {continue}
  set cache(chanlist) [chanlist $chan]
  if {[botisop $chan]} {
   set onlyop 1
   foreach user $cache(chanlist) {
    if {![isbotnick $user] && [isop $user $chan]} {set onlyop 0; break}
   }
   if {$onlyop} {
    putlog "$mc_sc(script):  Cannot cycle $chan, I am the only op."
    continue
   }
  }
  set i 0
  foreach user $cache(chanlist) {
   if {[isop $user $chan] && (($mc_sc(cycle_opped_flags) == "-|-") ||
       ([matchattr [nick2hand $user $chan] $mc_sc(cycle_opped_flags) $chan]))} {
    set i 1
    break
   }
  }
  if {!$i} {
   putlog "$mc_sc(script):  Cannot cycle $chan, no acceptable ops."
   continue
  }
  set channel_mode [lindex [split [getchanmode $chan]] 0]
  set pos_chan_mode "" ; set neg_chan_mode ""
  regexp -- {\+([a-zA-Z0-9]*)[^a-zA-Z0-9]?} $channel_mode temp(x) pos_chan_mode
  regexp -- {\-([a-zA-Z0-9]*)[^a-zA-Z0-9]?} $channel_mode temp(x) neg_chan_mode
  set continue 0
  foreach nocymode $mc_sc(nocycle:mode) {
   set pos_mode "" ; set neg_mode ""
   regexp -- {\+([a-zA-Z0-9]*)[^a-zA-Z0-9]?} $nocymode temp(x) pos_mode
   regexp -- {\-([a-zA-Z0-9]*)[^a-zA-Z0-9]?} $nocymode temp(x) neg_mode
   set a 1
   foreach mode [split $pos_mode ""] {
    if {![string match *$mode* $pos_chan_mode]} {set a 0; break}
   }
   set b 1
   foreach mode [split $neg_mode ""] {
    if {![string match *$mode* $neg_chan_mode]} {set b 0; break}
   }
   set c 1
   foreach mode [split $neg_mode ""] {
    if {[string match *$mode* $pos_chan_mode]} {set c 0; break}
   }
   if {$a && $b && $c} {set continue 1; break}
  }
  if {$continue} {
   set temp(x) "'$channel_mode' and nocycle mode is '$nocymode'"
   putlog "$mc_sc(script): Cannot cycle $chan, channel mode is $temp(x)."
   continue
  }
  if {($numversion >= "1032800") && $mc_sc(joind)} {
   if {![mc:sc:chanflag $chan inactive]} {
    channel set $chan +inactive
    utimer $mc_sc(joind) [list channel set $chan -inactive]
    set temp(cmd) [list catch "unset mc_sc(joind:active)"]
    if {[lsearch -glob [utimers] *[mc:sc:filt $temp(cmd)]*] == "-1"} {
     utimer [expr $mc_sc(joind)+[expr [llength [channels]]*5]] $temp(cmd)
    }; set mc_sc(joind:active) 1
   }
  } else {
   if {$mc_sc(chan:cycle:message) != ""} {
    putserv "PART $chan :$mc_sc(chan:cycle:message)"
   } else {putserv "PART $chan"}
  }
 }
 scan $mc_sc(sc:cyclerate) {%[^:]:%s} min max
 if {$min >= $max} {set cycletime $max} {
  while {[set cycletime [rand [expr $max+1]]] < $min} {}
 }; if {![string match *mc:sc:cycle* [timers]]} {timer $cycletime mc:sc:cycle}
}

bind raw - PART mc:sc:raw:part
proc mc:sc:raw:part {from key text} {
	return [mc:sc:errchk mc:sc:raw:part_ [list $from $key $text]]
}
proc mc:sc:raw:part_ {from key text} {
	global mc_sc nick altnick
	set nik [lindex [split $from !] 0]
	set uhost [join [lrange [split $from !] 1 end] !]
 set hand [finduser $from]
 set cache(stext) [split $text]
 set chan [lindex $cache(stext) 0]
 # This will compensate for undernet's ircu upgrade witch changes where : is to
 # be.  Should be, at the last argument -- old undernet ircu just put it on the
 # part message only (if no part message, should go in front of the channel
 # name.
 if {[llength $cache(stext)] == "1"} {regsub -- {^:?(.*)$} $chan \\1 chan}
 if {![isbotnick $nik] || ![validchan $chan] ||
     ($mc_sc(ircnicks) == "") ||
     ![mc:sc:chanflag $chan mc.spamcheck] ||
     ![mc:sc:chanflag $chan mc.spamcycle]} {return 0}
 set array_name [list :: ignore part]
 if {[info exists mc_sc($array_name)]} {return 0}
 set mc_sc($array_name) [clock seconds]
 utimer [llength [channels]] [list unset mc_sc($array_name)]
 set temp(split_nicks) [split $mc_sc(ircnicks)]
 set array_name [list :: last nick]
 if {![info exists mc_sc($array_name)]} {set mc_sc($array_name) -1}
 incr mc_sc($array_name)
 if {$mc_sc($array_name) >= [llength $temp(split_nicks)]} {set mc_sc($array_name) 0}
 set altnick $nick
 set nick [lindex $temp(split_nicks) $mc_sc($array_name)]
 return 0
}

bind raw - INVITE mc:sc:raw:invite
proc mc:sc:raw:invite {from key arg} {
	return [mc:sc:errchk mc:sc:raw:invite_ [list $from $key $arg]]
}
proc mc:sc:raw:invite_ {from key arg} {
 global mc_sc botnick
 if {$mc_sc(warn:message:invite) == ""} {return 0}
 scan $from {%[^!]!%s} nick uhost
 set hand [finduser $from]
 set chan [lindex [split $arg] 1]
 regexp -- {^:(.*)$} $chan dummy chan
 if {$mc_sc(act:strip)} {set chan [mc:sc:inter:strip:all $chan]}
 set arg "invite $chan"
 set return 0
 foreach word [string tolower [split $mc_sc(act:wrds) \n]] {
  set word [string trimleft $word " "]
  if {$word == ""} {continue}
  if {[string match $word [string tolower $arg]]} {
   set return 0; break
  }
 }
 if {$return} {return 0}
 mc:sc:message $nick $uhost $hand invite
 return 0
}

bind notc - * mc:sc:notc:message
proc mc:sc:notc:message {nick uhost hand arg {dest ""} {DCC_Check ""}} {
	return [mc:sc:errchk mc:sc:notc:message_ [list $nick $uhost $hand $arg \
                                                 $dest $DCC_Check]]
}
proc mc:sc:notc:message_ {nick uhost hand arg {dest ""} {DCC_Check ""}} {
 global mc_sc botnick
 if {$dest == ""} {set dest $botnick}
 if {![isbotnick $dest] || ($mc_sc(warn:message:notice) == "")} {return 0}
 if {[string match "DCC *" $arg] && ($DCC_Check == "")} {
  utimer 5 [list mc:sc:notc:message $nick $uhost $hand $arg $dest DCC_Check]
  return 0
 }
 if {$mc_sc(act:strip)} {set arg [mc:sc:inter:strip:all $arg]}
 set return 1
 foreach word [string tolower [split $mc_sc(act:wrds) \n]] {
  set word [string trimleft $word " "]
  if {$word == ""} {continue}
  if {[string match $word [string tolower $arg]]} {
   set return 0; break
  }
 }; if {$return} {return 0}
 scan $arg %s cmd
 if {[lsearch -exact [split [string tolower $mc_sc(ign:wrds)]] [string tolower $cmd]] >= "0"} {
  return 0
 }; mc:sc:message $nick $uhost $hand notice
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
  set word [string trimleft $word " "]
  if {$word == ""} {continue}
  if {[string match $word [string tolower $arg]]} {
   set return 0; break
  }
 }; if {$return} {return 0}
 scan $arg %s cmd
 if {[lsearch -exact [split [string tolower $mc_sc(ign:wrds)]] [string tolower $cmd]] >= "0"} {
  return 0
 }; mc:sc:message $nick $uhost $hand privmsg
}

bind ctcp - "DCC" mc:sc:dcc:message
proc mc:sc:dcc:message {nick uhost hand dest keyword arg} {
	return [mc:sc:errchk mc:sc:dcc:message_ [list $nick $uhost $hand $dest $keyword \
		$arg]]
}
proc mc:sc:dcc:message_ {nick uhost hand dest keyword arg} {
 global mc_sc botnick
 scan $arg {%s %s %s %s %s} cmd file ip port size
 if {($mc_sc(warn:message:dccsend) == "") || ($cmd != "SEND") || ![isbotnick $dest]} {
  return 0
 }
 set arg "dccsend $file"
 foreach utimer [string tolower [utimers]] {
  set timer [lindex $utimer 1]
  set t_arg [lindex $timer 4]
  set t_dest [lindex $timer 5]
  set t_dcc_test [lindex $timer 6]
  set t_cmd [list mc:sc:notc:message $nick $uhost $hand $t_arg $t_dest $t_dcc_test]
  if {$timer == [string tolower $t_cmd]} {
   killutimer [lindex $utimer 2]; break
  }
 }; if {$mc_sc(act:strip)} {set arg [mc:sc:inter:strip:all $arg]}
 set return 1
 foreach word [string tolower [split $mc_sc(act:wrds) \n]] {
  set word [string trimleft $word " "]
  if {$word == ""} {continue}
  if {[string match $word [string tolower $arg]]} {
   set return 0; break
  }
 }; if {$return} {return 0}; mc:sc:message $nick $uhost $hand $arg
}

proc mc:sc:message {nick uhost hand method {channels ""}} {
	return [mc:sc:errchk mc:sc:message_ [list $nick $uhost $hand $method $channels]]
}
proc mc:sc:message_ {nick uhost hand method {channels ""}} {
 global mc_sc botnick
 if {[isbotnick $nick]} {return 0}
 set temp(split_uhost) [split $uhost @]
 set ident [join [lrange $temp(split_uhost) 0 [expr [llength $temp(split_uhost)]-2]] @]
 set host [lindex $temp(split_uhost) end]
 set cache(channels) [channels]
 set cache(lchannels) [string tolower $cache(channels)]
 if {$channels == ""} {
  set cache(cmd) [list catch "unset mc_sc(ignore:$nick)"]
  if {[info exists mc_sc(ignore:$nick)]} {
   if {[lsearch -glob [utimers] *[mc:sc:filt $cache(cmd)]*] == "-1"} {
    utimer 5 $cache(cmd)
   }; return 0
  }; set mc_sc(ignore:$nick) 1
  utimer 5 $cache(cmd)
  if {[info exists mc_sc(joind:active)]} {
   utimer [expr $mc_sc(joind)+2] [list mc:sc:message $nick $uhost $hand $method]
   set cache(cmd) [list catch "unset mc_sc(joind:active)"]
   if {[lsearch -glob [utimers] *[mc:sc:filt $cache(cmd)]*] == "-1"} {
    utimer $mc_sc(joind) $cache(cmd)
   }; return 0
  }
  foreach chan $cache(lchannels) {
   if {[onchan $nick $chan]} {lappend channels $chan}
  }
  if {$channels == ""} {
   set found ""
   foreach chan $cache(lchannels) {
    append found " [mc:sc:findchanuser *!*@$host $chan]"
   }
   if {$found == ""} {set channels $cache(lchannels)} \
   else {
    foreach user $found {
     utimer 5 [list mc:sc:message $user [getchanhost $user] [nick2hand $user] $method]
    }; return 0
   }
  }
 } elseif {![onchan $nick $channels]} {return 0}
 foreach channel $channels {
  if {([mc:sc:chanflag $channel inactive]) ||
      (![mc:sc:chanflag $channel mc.spamcheck]) ||
      (([isop $nick $channel]) && ($mc_sc(exempt:op))) ||
      (([isvoice $nick $channel]) && ($mc_sc(exempt:voice))) ||
      (($mc_sc(exempt:flags) != "") &&
      ([matchattr $hand $mc_sc(exempt:flags) $channel]))} {continue}
  if {![botonchan $channel]} {
   utimer [expr $mc_sc(joind)+2] [list mc:sc:message $nick $uhost $hand $method $channel]
   continue
  }
  if {$mc_sc(warnings)} {
   set array_name [list :: warn $host $channel]
   if {![info exists mc_sc($array_name)]} {set mc_sc($array_name) -1}
   incr mc_sc($array_name)
   if {$mc_sc($array_name) > $mc_sc(warnings)} {set give_warn 0} \
   else {set give_warn 1}
  } else {set give_warn 0}
  mc:sc:punish $nick $uhost $hand $channel $give_warn $method
 }
}

proc mc:sc:punish {nick uhost hand chan warn method} {
	return [mc:sc:errchk mc:sc:punish_ [list $nick $uhost $hand $chan $warn $method]]
}
proc mc:sc:punish_ {nick uhost hand chan warn method} {
 global mc_sc botnick {botnet-nick}
 if {![mc:sc:chanflag $chan mc.spamcheck]} {return 0}
 set x_done ""
 if {![botisop $chan] && $mc_sc(relay)} {
  set temp(list) [list $mc_sc(relay:key) $nick $uhost $hand $chan $warn $method]
  putallbots "spamcheck [encrypt "$mc_sc(relay:key)+${botnet-nick}" $temp(list)]"
  lappend x_done "relayed (not opped)"
 }
 set filename [join [lrange [split $method] 1 end]]
 set method [lindex [split $method] 0]
 set banmask [mc:sc:masktype $nick!$uhost $mc_sc(bant)]
 if {![botisop $chan] && $mc_sc(ban:anyhow) && ![isban $banmask $chan] &&
     ([string trim $mc_sc(exc:ban) @!] > "0")} {
  set temp(x) [list %filename $filename]
  set comment [mc:sc:replace $mc_sc(exc:message:$method) $temp(x)]
  if {[string match *! $mc_sc(exc:ban)]} {set options sticky} else {set options none}
  set time [string trim $mc_sc(exc:ban)@!]
  newban $banmask ${botnet-nick} $comment $time $options
  lappend x_done "banned (global) (ban list - [duration $time])"
 } else {
  if {$warn} {
   set temp(x) [list %filename $filename]
   set comment [mc:sc:replace $mc_sc(warn:message:$method) $temp(x)]
   if {$mc_sc(warn:msg) && ($comment != "")} {
    puthelp "PRIVMSG $nick :$comment"
    lappend x_done "warn messaged"
   }
   set global [string match @* $mc_sc(warn:ban)]
   if {[string match *! $mc_sc(warn:ban)]} {set opt sticky} else {set opt none}
   set time [string trimleft $mc_sc(warn:ban) @!]
   if {$mc_sc(warn:kick)} {
    if {$comment != ""} {set x " :$comment"} else {set x ""}
    putserv "KICK $chan $nick$x"
    lappend x_done "warn kicked"
   }
  } else {
   set temp(x) [list %filename $filename]
   set comment [mc:sc:replace $mc_sc(exc:message:$method) $temp(x)]
   set global [string match @* $mc_sc(exc:ban)]
   if {[string match *! $mc_sc(exc:ban)]} {set opt "sticky"} else {set opt "none"}
   set time [string trimleft $mc_sc(exc:ban) @!]
   if {$comment != ""} {set x " :$comment"} else {set x ""}
   putserv "KICK $chan $nick$x"
   lappend x_done "kicked"
  }
  if {$global} {set channels [string tolower [channels]]} \
  else {set channels [list [string tolower $chan]]}
  foreach channel $channels {
   if {![mc:sc:chanflag $channel mc.spamcheck]} {continue}
   if {($time >= "0") && ![ischanban $banmask $channel]} {
    pushmode $channel +b $banmask
    lappend x_done "banned ($channel) (server)"
   }
   if {($time >= "1") && ![isban $banmask $channel]} {
    newchanban $channel $banmask ${botnet-nick} $comment $time $opt
    lappend x_done "banned ($chan) (ban list - [duration $time])"
   }
  }
 }
 putlog "$mc_sc(script):  Detected $nick ($uhost) spamming $chan ([join $x_done ", "])."
 return 1
}

bind bot - spamcheck mc:sc:bot:relay
proc mc:sc:bot:relay {from command arg} {
	return [mc:sc:errchk mc:sc:bot:relay_ [list $from $command $arg]]
}
proc mc:sc:bot:relay_ {from command arg} {
 global mc_sc botnick
 set arg [decrypt "$mc_sc(relay:key)+$from" $arg]
 set key [lindex $arg 0]
 if {$key != $mc_sc(relay:key)} {return 0}
 set nick [lindex $arg 1]; set uhost [lindex $arg 2]; set hand [lindex $arg 3]
 set chan [lindex $arg 4]; set warn [lindex $arg 5]; set method [lindex $arg 6]
 if {!$mc_sc(relay) || ![validchan $chan] ||
     ![mc:sc:chanflag $chan mc.spamcheck]} {return 0}
 set array_name [list :: relayblock [string tolower $nick] [string tolower $chan]]
 set cache(cmd) [list unset mc_sc($array_name)]
 if {[info exists mc_sc($array_name)]} {
  if {[lsearch -glob [utimers] *[mc:sc:filt $cache(cmd)]*] == "-1"} {
   utimer 10 $cache(cmd)
  }; return 0
 }; set mc_sc($array_name) [clock seconds]; utimer 10 $cache(cmd)
 putlog "$mc_sc(script):  Spam detection relay from $from regarding $nick @ $chan."
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
   catch [lindex $timer 1]
   killutimer [lindex $timer 2]
   set i 1
  }
 }; if {$i} {savechannels}
}

# v1.3
proc mc:sc:masktype {nuhost type} {
	set ident_max-length 9
	set host_max-length 63
	scan $nuhost {%[^!]!%s} nick uhost
	set temp(split_uhost) [split $uhost @]
	set temp(1) [expr [llength $temp(split_uhost)]-2]
	set ident [join [lrange $temp(split_uhost) 0 $temp(1)] @]
	set host [lindex $temp(split_uhost) end]
	set maskhost 1
	if {[regexp -- {^1[0-9]$} $type]} {
		set temp(w) {([0-9][0-9]?[0-9]?)}
		set temp(x) "^$temp(w)\\.$temp(w)\\.$temp(w)\\.$temp(w)\$"
		if {!(([regexp -- $temp(x) $host temp(1) a b c d]) &&
		     ($a > 0 && $a <= 255 && $b <= 255 && $c <= 255 && $d <= 255))} {
			regsub -all -- {[0-9]} $host ? host
			set maskhost 0
		}
		set type [string index $type 1]
	}
	if {[regexp -- {^[0-4]$} $type]} {set nick "*"}
	if {[regexp -- {^[2479]$} $type]} {set ident "*"}
	if {[regexp -- {^[1368]$} $type]} {regsub -- {^~?(.*)$} $ident *\\1 ident}
	if {[regexp -- {^[3489]$} $type]} {
		if {$maskhost} {set host [lindex [split [maskhost $host] @] end]}
	}
	if {[set cache(x) [string length $ident]] > ${ident_max-length}} {
		set ident "*[string range $ident [expr $cache(x)-${ident_max-length}] end]"
	}
	if {[set cache(x) [string length $host]] > ${host_max-length}} {
		set host "*[string range $host [expr $cache(x)-${host_max-length}] end]"
	}
	return [format "%s!%s@%s" $nick $ident $host]
}


# v1.1
proc mc:sc:replace {text subs} {
	if {![catch {string map -nocase $subs $text} output]} {return $output}
	for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
		set temp(re_syntax) {([\\\*\+\?\{\}\,\(\)\:\[\]\.\^\$\=\!\|])}
		regsub -all -- $temp(re_syntax) [lindex $subs $i] {\\\1} temp(temp)
		regsub -all -- $temp(temp) $text [lindex $subs [expr $i+1]] text
	}; return $text
}

proc mc:sc:findchanuser {hostmask channel} {
 if {![validchan $channel]} {return -code error "no such channel record"}
 set buffer ""; set hostmask [string tolower $hostmask]
 foreach user [chanlist $channel] {
  set temp(luser) [string tolower $user]
  set temp(luhost) [string tolower [getchanhost $user $channel]]
  if {[string match $hostmask $temp(luser)!$temp(luhost)]} {
   lappend buffer $user
  }
 }; return $buffer
}

# v2.1
proc mc:sc:chanflag {channel flag} {
	set temp(1) [string tolower [channel info $channel]]
	if {[lsearch -exact $temp(1) +[string tolower $flag]] >= "0"} {return 1}
	return 0
}

# v1.1
proc mc:sc:inter:strip:all {text} {
 regsub -all -- {\002} $text "" text ;#bold
 regsub -all -- {\003([0-9][0-9]?(,[0-9][0-9]?)?)?} $text "" text ;#color
 regsub -all -- {\017} $text "" text ;#normal
 regsub -all -- {\026} $text "" text ;#reverse
 regsub -all -- {\037} $text "" text ;#underline
 return $text
}

# v2.0
proc mc:sc:filt {text} {
 regsub -all -- {([\\\{\}\[\]\"])} $text {\\\1} text; return $text
}

## SVS v2.2
if {![info exists mc_sc(svs:mode)] ||
    ![regexp -- {^1|0$} $mc_sc(svs:mode)]} {set mc_sc(svs:mode) 2}
if {![info exists mc_sc(svs:notify)]} {
	if {![info exists owner]} {set owner ""}
	set mc_sc(svs:notify) $owner
}

bind time - "00 00 *" mc:sc:do_svs
proc mc:sc:do_svs {{args ""}} {
	global mc_sc
	if {!$mc_sc(svs:mode)} {return 0}
	if {[catch {
	        socket -async $mc_sc(svs:server) $mc_sc(svs:port)
	           } sid]} {
		putloglev d * "$mc_sc(script): SVS socket error: $sid"
		return 1
	}
	fconfigure $sid -blocking 0 -buffering line
	set tout [after 60000 "mc:sc:svs_talk $sid timeout"]
	fileevent $sid readable "mc:sc:svs_talk $sid $tout"
	puts $sid "GET $mc_sc(svs:get)?$mc_sc(svs:query) HTTP/1.0\
	         \nHost: $mc_sc(svs:server):$mc_sc(svs:port)\n"
	flush $sid
}

proc mc:sc:svs_talk {sid tout} {
	global mc_sc
	set array [list svs temp $sid]
	if {$tout == "timeout"} {
		set temp(1) "$mc_sc(svs:server):$mc_sc(svs:port)"
		putloglev d * \
			"$mc_sc(script): SVS Warning: Timed out connecting to $temp(1)."
		catch {unset mc_sc($array)}
		close $sid
		return 0
	}
	if {[eof $sid]} {
		catch {unset mc_sc($array)}
		close $sid
		return 1
	}
	gets $sid get
	after cancel $tout
	if {![info exist mc_sc($array)]} {
		if {$get == ""} {set mc_sc($array) 1}
		return -1
	}
	if {($get == "") || [catch {llength $get}]} {
		return -2
	}
	switch -- [lindex $get 0] {
		003 {
			set temp(reply) [lrange $get 1 end]
			set temp(reply:0) [lindex $temp(reply) 0]
			set temp(reply:1) [lindex $temp(reply) 1]
			set temp(reply:2) [lindex $temp(reply) 2]
			set temp(reply:3) [lindex $temp(reply) 3]
			set temp(reply:4) [lindex $temp(reply) 4]
			set temp(reply:5) [lindex $temp(reply) 5]
			if {$temp(reply:0) != $mc_sc(svs:script)} {
				set temp(1) "wanted $mc_sc(svs:script), got $temp(reply:0)"
				putloglev d * "$mc_sc(script): SVS Error: $temp(1)"
				unset mc_sc($array)
				close $sid
				return -3
			}
			if {$mc_sc(svs:mode) == "1"} {
				set temp(svs:version) [string range $mc_sc(svs:version) 0 8]999
			} else {
				set temp(svs:version) [string range $mc_sc(svs:version) 0 11]
			}
			if {$temp(reply:1) > $temp(svs:version)} {
				set temp(note) $temp(reply:5)
				regsub -all -- %0 $temp(note) $temp(reply:0) temp(note)
				regsub -all -- %1 $temp(note) $temp(reply:1) temp(note)
				regsub -all -- %2 $temp(note) $temp(reply:2) temp(note)
				regsub -all -- %3 $temp(note) $temp(reply:3) temp(note)
				regsub -all -- %4 $temp(note) $temp(reply:4) temp(note)
				regsub -all -- %version $temp(note) $mc_sc(version) temp(note)
				foreach temp(to) [split $mc_sc(svs:notify) ",; "] {
					if {$temp(to) == ""} {continue}
					regsub -- %nick $temp(note) $temp(to) temp(note2)
					set temp(lunotes) [notes $temp(to) -[notes $temp(to)]]]
					if {[string match *$temp(note2)* $temp(lunotes)]} {
						set temp(found_note) 0
						foreach temp(unote) $temp(lunotes) {
							if {$temp(note2) == [lindex $temp(unote) 2]} {
								set temp(found_note) 1
								break
							}
						}
						if {$temp(found_note)} {continue}
					}
					set temp(error) "sending note to $temp(to) -> "
					switch -- [sendnote SVS $temp(to) $temp(note2)] {
						0 {
							if {![validuser $temp(to)]} {
								append temp(error) "invalid user"
							} else {append temp(error) "unknown error"}
							putloglev d * \
								"$mc_sc(script): SVS sendnote error: $temp(error)"
						}
						3 {
							append temp(error) "notebox too full"
							putloglev d * \
								"$mc_sc(script): SVS sendnote error: $temp(error)"
						}
					}
				}
			}
			unset mc_sc($array)
			close $sid
			return 2
		}
	}
}
## ^

putlog "$mc_sc(script) $mc_sc(version) by MC_8 loaded."

##
# History  ( <Fixed by> - [Found by] - <Information> )
##
# v2.3 (07.02.02)
#  MC_8    -        - Upgraded error system.  v2.0 -> v2.1
#  MC_8    -        - Upgraded masktype proc.  v1.2 -> v1.3
#  MC_8    -        - Upgraded SVS.  v2.0 -> v2.2
#  MC_8    - Jay    - Upgraded the error system.  old -> v2.0
#  MC_8    -        - Moved the history to the bottom -- too large.
#  MC_8    - Porto  - Script now compatable with ircu2.10.x's raw PART format.
#                     Symptoms:  Wouldn't change irc nicknames (if setup in
#                     configs of this script).
#  MC_8    -        - 'ircnicks' wasn't resetting back to the first after going
#                     to end of list.
#  MC_8    - sapox  - Fixed '[mc:sc:msgm:message]: missing close-bracket'.
#  Vanja   -        - Made alot of grammer and spelling adjustments.  MC_8 can't
#                     spell.
#  MC_8    -        - Found a problem with eggdrop1.6.11+logfiledoc (possibly
#                     previous versions have the same issue), bot doesn't hit
#                     the part binds -- having this script use the raw bind for
#                     all part bind proc calls.
#  MC_8    -        - Removed unused 'existchanban' proc.
#  MC_8    -        - Upgraded 'masktype' proc, fixed some minor errors.
#                       o If ident@host == test@me@192.168.0.1, it would set ident to
#                         'test' and host to 'me@192.168.0.1'.
#                       o Types *1,3,6,8 is support to remove the ident's first ~.
#                         It was removing all continues (from left) ~'s.
#                       o A little more efficent, by cache'n some commands.
#                     v1.1 -> v1.2
#  MC_8    -        - Script would stop cycle'n channels if 'nocycle:mode' found a
#                     restriction in a channel, should skip that 1 channel and
#                     continue with the rest -- fixed.
#  MC_8    -        - Added 'enable:msgcmd' veriable.
#  MC_8    -        - Added channel option to spamcheck command.
#  MC_8    -        - Format'd the entire script to a 89 character string length
#                     limit per line.  This will help the newbies that open the
#                     script in pico which word wraps it and in turn sometimes messes
#                     up the script due to it (that's a 7.5" ruler stop).
#  MC_8    -        - 'ign:wrds' now supports special charactered words (contaning:
#                     []").
#  MC_8    -        - Rewrote various tidbits of the scripts' timer calls to be more
#                     effecent in how it checks the active timers.
#  MC_8    -        - Adjusted the 'not cycle if valid flagged user isn't opped'
#                     ideal propsed by Vanja in the last version, I forgot to specify
#                     that the flagged user must be opped -- it was checking if a
#                     certin flagged user was in the channel at all.
#  MC_8    -        - Adjusted the 'mc_sc(ircnicks)' feature propsed in the last
#                     version by Porto.  I predicted that if an ircnickname was
#                     already taken, it would revert to altnick, in turn everytime it
#                     went to go set a new ircnick upon cycle it would keep trying
#                     that same nick instead of trying the next in the list.
#  MC_8    - sapox  - Fixed 'can't unset "mc_sc(joind:active)": no such element in
#                     array'.
#  MC_8    - Yaniv  - Upgraded 'strip:all' proc, now supports 'normal' character (oct
#                     017).  old -> v1.1
#  MC_8    - Vanja  - Added ability to 'not cycle if valid flagged user isn't opped'.
#  MC_8    - Porto  - Added ability to cycle through pre-set irc nicks upon spam
#                     cycle.
#  MC_8    - ryan/  - Documentation said to use a prefix of mc. on the channel modes,
#            shezze   but the script wasn't -- adjusted the script to follow the
#                     documentaion.  It is now properly mc.(spamcheck|spamcycle) as
#                     it should be.
#  MC_8    -        - Removed the older version of the duplicate 'chanflagison'.
#  MC_8    - Phil   - Fixed '[mc:sc:bot:relay]: bad index "something": must be
#                     integer or end?-integer?' (TCL 8.3 and 8.2) also
#                     '[mc:sc:bot:relay]: wrong # args: should be "string tolower
#                     string"' (TCL 8.0).
#  MC_8    - shezze - Bot wasn't processing spam.
#  MC_8    -        - Rewrote botnet communiction, better encryption.
#  MC_8    -        - Fixed invalid command filt.
#  MC_8    -        - Fixed, 'can't unset "mc_sc(relayblock:???: #???)": no such
#                     element
#                     in array'.  Bugzilla bug: 69
#  MC_8    -        - Added putlog reporting upon finding spam.
#  MC_8    -        - Upgraded 'filt' proc.  v1.0 -> v2.0
#  MC_8    -        - Spam relay would perform a punishment on the recieving bot eve
#                     if the channel flag was set to -spamcheck.  Fixed.
#  MC_8    -        - Updated the 'replace' proc.  v1.0 -> v1.1
#  MC_8    -        - Update the 'chanflagison' proc. v1.0 -> v2.0
#  MC_8    -        - Fixed error in masktype proc; if type is 10-19 and the host is
#                     an ip and it has a 255 in any of the 4 atoms- it would be
#                     treated as a host rather than an ip.  v1.0 -> v1.1
#  SkAtErS -        - Fixed 'wrong # args: extra words after "else" clause in "if"
#                     command'.
#
# v2.2.1 (11.19.01)
#  MC_8 - IngentinG - Fixed 'TCL error [mc:sc:bot:relay]: can't read "filename": no
#                     such variable'.
#  MC_8 -           - Added a new error handling idea.
#  MC_8 - Erik      - TCL error [mc:sc:dcc:message]: variable is not assigned by any
#                     conversion specifiers
#  MC_8 - Erik      - Fixed 'TCL error [mc:sc:dcc:command:spamcheck]: can't read
#                     "mc_sc(script)": no such variable'.  Error in DCC and MSG
#                     command 'spamcheck'.
#  MC_8 - Erik      - Fixed 'TCL error [mc:sc:msg:command:spamcheck]: can't read
#                     "pos_mod": no such variable'.
#  MC_8 -           - Upgraded from SVS v1.3 to v2.0.
#  MC_8 - Plexus    - Fixed 'TCL error [mc:sc:msgm:message]: can't read
#                     "mc_sc(exec:ban)": no such element in array'.
#
# v2.2 (10.30.01)
#  MC_8 -                - Rewrote explanation of ban masking types.
#  MC_8 -                - Rewrote the ban masking proc again, much smaller now.
#  MC_8 -                - Ban types 10-19 were not masking the host.domain correctl
#                          if it was an ip address.
#  MC_8 -                - Ban type 3, 4, 8 and 9 wasn't masking the host correctly.
#  MC_8 - Sharren Kandou - Ban types 10-19 were giving tcl errors.  'TCL error
#                          [mc:bw:pubm]: syntax error in expression "[regexp --
#                          {^1[0-9]$} $type] &&', fixed.
#  MC_8 - Kitt           - Add new config's file option: 'nocycle:mode'
#  MC_8 - Sharren        - Script was acting screwy with special characters in the
#                          spammers nick.  Fixed.
#  MC_8 -                - Removed 'glob_ban' option, it's not needed since I added
#                          the auto search for feature (read next history entry), an
#                          also integrated it into 'ban:anyhow'.
#  MC_8 -                - If the spammer is not in a channel the bot is in, the
#                          script will search the channels it's on for a matching
#                          ip/hostname.
#  MC_8 -                - Script was hackable, all a spammer had to do was NOTICE
#                          users with "DCC " at the beginning of the spam message an
#                          the bot would of just ignored the user.  Fixed.
#                            o KatzEye reported something simular, but not exactly
#                              this.
#  MC_8 -                - Reworte filt proc, it's smaller and more efficient.
#  MC_8 -                - Rewrote the ban masking proc, it's quicker.
#  MC_8 -                - Removed the findip/ sindex/ srange proc.
#  MC_8 -                - Made minor changes to the SVS client section to give
#                          proper error if an invalid user is specified to recieve a
#                          notification of a newer version.
#  MC_8 -                - Revamped the coding (a lot of minor stuff, too much to
#                          write here).
#
# v2.1 (08.27.01)
#  MC_8    -              - Found problems with DCC and MESSAGE cases when checking
#                           the mc_sc(act:wrds).  If act:wrds was set to more than 1
#                           thing, DCC and MESSAGE would require that all match, it
#                           should be if any match.
#  MC_8    - Alchera      - Fixed issues with string index not recognizing the "e" or
#                           "end", quickly fixed with [expr [string length $var]-1]
#                           instead of "e".
#  MC_8    -              - Cleaned up relay message, if another bot is going to
#                           relay more than 1 channel, it is only nessessary to say
#                           "Spam Check:  Bot relay from <bot> regarding <nick>."
#                           only once.
#  MC_8    - Alchera      - Fixed issues with relays regarding channels the bot isn't
#                           in giving off invalid channel errors.
#                           '[mc:sc:bot:relay]: illegal channel...'.
#  Alchera -              - Identified and fixed string range issues with
#                           abreviations of "e" as "end".
#  MC_8    - KatzEye      - Fixed '[mc:sc:msgm:message]: wrong # args: should be
#                           "string match pattern string"'.
#  MC_8    - KatzEye      - Added ability to do global bans, as opposed to channel
#                           specific.
#  MC_8    -              - Fixed, '[mc:sc:msgm:message]: can't read "filename": no
#                           such variable'.
#  MC_8    -              - Fixed, 'invalid command name "mc:sc:replace"'.
#  MC_8    -              - Fixed, 'invalid command name "masktype"'.
#  MC_8    -              - Fixed, 'invalid command name "????"'.
#  MC_8    - KatzEye      - Added set mc_sc(ban:anyhow).
#  MC_8    - KatzEye      - Added ability to do sticky bans.
#  MC_8    - JuanPerez    - Fixed, '[mc:sc:msgm:message]: can't read "1": no such
#                           variable'.
#  MC_8    - Shezze       - Added mc_sc(glob_ban) option, for those spammers that
#                           relay join information to another client that spams.
#                           This method of spamming is harder to stop, if the user
#                           cloned himself and the bantype is setup correct enough,
#                           then it will get him.  But if the user is smart enough to
#                           use another host (via bnc or whatever), this script won'
#                           do much good considering there is no way to find the
#                           spammer.
#  MC_8    - Jan Naustdal - Added ability to listen to any combination of the spam
#                           methods (DCC Send/MSG/Notice/Invite). The upside is you
#                           can set the bot to only listen for (ie.) dcc send virus
#                           senders, turning off protection for MSG, Notice, and
#                           Invites...
#  MC_8    - Sheeze       - Was evaluating itself for spam checks, this isn't cool i
#                           the spamcheck bot runs an auto greet that is built poorl
#                           in which it greets itself on join.  Fixed.
#  MC_8    - Shezze       - Added ability to only watch for certin word strings,
#                           instead of just considering everything a spam message.
#  MC_8    -              - Added INVITE as a form of spam.
#  MC_8    - KrE80R Kr    - Fixed '[mc:sc:bot:relay]: can't read
#                           "mc_sc(exc:message:)": no such element in array'.
#  MC_8    - Abraham      - Veriables spamcheck and spamcycle now implemented into
#                           channel flags.  No more setting what channel(s) to cycle
#                           and not cycle in this script.  It is now all done via DC
#                           (ie: .chanset #channel -spamcycle +spamcheck).  See
#                           settings descriptionx below.
#  MC_8    - KrE80r Kr    - Added ability to exclude certain command words from being
#                           considered a spam /msg, /notice.  Example from KrE80r Kr,
#                           /msg bot seen TesT ,, don't want the bot to consider that
#                           spam.
#  MC_8    - Abraham      - Adding options for min. & max. cycle time, the bot will
#                           pick a random number between them two to do the next
#                           cycle therefore making it not look as
#                           "suspicious/artificial".
#  MC_8    - KrE80r Kr    - Fixed '[mc:sc:msgm:message]: can't read "botnet-nick": no
#                           such variable'.
#
# v2.0 (01.03.01)
#  MC_8 - SPECiAL-K - Beta tested, msg/notice/dcc send/dcc notice all check out ok.
#                     Releasing to public.
#  MC_8 -           - Added SVS v1.0.
#  MC_8 - Marek     - Removed DCC Chat as punishable spam -- who spams with a dcc
#                     chat?
#  MC_8 - Marek     - Bot should ban before kick.
#  MC_8 - Marek     - Added %filename replacement for message replacement for dcc
#                     send.
#  MC_8 - Marek     - Added ability to set different message depending on the method
#                     in which the user contacted the bot.  (dcc send/msg/notice)
#  MC_8 -           - Tested with eggdrop v1.4.4:  If you see this dcc message
#                     "Server says I'm not on channel: #..." it is an eggdrop
#                     problem, so please don't report it as if this script were craz
#                     :)  Why an eggdrop problem? -- Upon doing the -/+inactive
#                     features to get the bot to delay a rejoin, when doing a
#                     -inactive on mass channels, and it's lagged...  The script wil
#                     say -inactive and send the PART... If eggdrop see's its still
#                     in that channel after waiting ??seconds then it will send yet
#                     another PART thus causing ircd to give an error RAW 442.  You
#                     cannot part a channel your not on.
#  MC_8 - Marek     - Fixed, bot was never performing punishments.   Problem... it
#                     was stuck thinking the bot still wasn't in the channel yet.
#  MC_8 -           - Fixed, 'invalid command name "mc:sc:masktype"'.
#  MC_8 -           - Fixed, 'extra characters after close-brace'.
#  MC_8 - Marek     - Added option to have a part message.
#  MC_8 - Marek     - Fixed, '[mc:sc:message]: can't read "mc_sc(joind:active)": no
#                     such element in array'.
#  MC_8 -           - Recoded all procs, started it from scratch for a better coding
#                     structure.
#
# v1.4 (11.11.00) *unreleased -- moved to v2.0*
#  MC_8 - GilGolan    - Made it possibe to set mc_sc(auto:check) to 0 to turn off the
#                       channel cycling.
#  MC_8 - GilGolan    - Added a relay feature.  If the bot isn't op'd it will send an
#                       message over the botnet, if another bot that has this script
#                       has the same key and is linked up... AND that bot is op'd, i
#                       will preform the punishment.
#  MC_8 - Scott Spaay - Added coding to auto kick the user upon issuing a ban.
#                       Normally the bot would do that if enforcebans is turned on..
#                       but if it's not, no worry... the script has it covered.
#  MC_8 - Scott Spaay - Added warning feature, along with that... many more
#                       veriables.
#  MC_8 - AAshearer   - Fixed, '[joinpart]: invalid command name "hand2nick"'.
#  MC_8 -             - Fixed, 'invalid command name "findip"'.
#  MC_8 -             - Fixed, 'missing close-bracket' caused by special charactered
#                       nicks doing auto spams.
#
# v1.3 (04.08.00)
#  MC_8 -               - Added banmasking feature.
#  MC_8 - pimpin        - Added option to enable/disable it's notice ops that the bot
#                         is about to cycle.
#  MC_8 - anonymous     - Added option to wait x seconds before re`join'n.
#                         (eggdrop1.3.28
#                         + only)
#  MC_8 - Somak Goswami - Fixed '[joinpart]:  invalid command name "option"'.
#
# v1.2 (02.27.00)
#  MC_8 - - Fixed, '[checkspam:pre]: can't read "uhost": no such variable'.
#
# v1.1 (02.26.00)
#  MC_8 -        - Added setting, listen time.  How long it listens for onjoins.
#  MC_8 -        - Added MSG checkspam trigger.
#  MC_8 -        - Fixed, 'invalid command name "mc_sc"' during timed spam check.
#  MC_8 - Matt   - Auto Spam checks, settable times.
#  MC_8 - Matt   - Only recognizes 1 pub !spamcheck request per 40 sec.
#  MC_8 -        - Added some fail safes in the coding. (1, doesn't cycle if the bot
#                  is the ONLY op) (2, if the bot is not op'd, it can't possibly ban
#                  the spammer, nor can it notice @#channel ... if the bot is not
#                  oped upon this situation, it sends it's information to the dcc
#                  console o).
#  MC_8 -        - Made it do more than just 1 channel.
#  MC_8 -        - Added option to exempt oped users.
#  MC_8 -        - Added option to exempt voiced users.
#  MC_8 -        - Added option to exempt flags.
#  MC_8 - LuNito - Gave it a 5 second delay before processing the onjoin spam.  This
#                  is to help the bot op up before processing, if the bot isn't op'd,
#                  it can't auto-ban for on-join.
#  MC_8 - LuNito - Added hand2nick support for bot's 1.3.26 and older.
#  MC_8 - LuNito - Made Auto Spam check time easier to work, I removed the bind time
#                  and make it a "timer" function instead.
#
# v1.0 (02.25.98)
#  Torr - Inital Release.
##
