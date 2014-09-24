on *:START:{
  if (%draft == $null) set %draft 0
  set %turn 0
  write -c temp.txt ;//buffer for the other load-balancing nickname (if used)
}

;//the different messages on round start and after picking
alias pickmsgs {
  if ($prop == roundstart) {
    if (%msgtype == 1) {
      var %txt = %listt
      var %i = 1
      var %tmp
      while (%i <= $numtok(%txt,32)) {
        %tmp = $+(%tmp,$chr(32),$gettok($gettok(%txt,%i,32),2,7))
        inc %i
      }
      return Round %current_round started. Pick order: %tmp
    }
    else {
      return Round %current_round started. Pick order: $replace(%listt,$chr(7),$chr(183))
    }
  }
  if ($prop == roundstart2) {
    if (%msgtype == 1) return $do(null).captain picks first (2min)
    else return $do(null).captain picks first with $calc($do(null).money - %round [ $+ [ %current_round ] ] ) to spend (2min)
  }
  if ($prop == round3) {
    if (%msgtype == 1) return $+($do(null).captain,$chr(39),s) total salary now at $+(,$chr(36),$calc(%teamcap - $do(null).totalmoney + $1),$chr(46))
    else return $do(null).captain has $calc( $gettok(%captain [ $+ [ $do(null).num ] ] ,2,32) - %round [ $+ [ $calc(%current_round +1) ] ] ) for next round.
  }
  if ($prop == round4) {
    if (%msgtype == 1) return $do(null).captain now picks with a current team salary of $+(,$chr(36),$calc(%teamcap - $do(null).totalmoney),$chr(46)) (2min)
    else return $do(null).captain now picks with $calc($do(null).money - %round [ $+ [ %current_round ] ] ) to spend (2min)
  }
}

;//make the list of players and salaries into standard format. can import from multiple formats
alias makelist {
  if ($exists(rankings.txt) == $true) {
    write -c r2.txt
    var %i = 1
    while ( $read(rankings.txt,%i) ) {
      if ($gettok($read(rankings.txt,n,%i),1,32) isnum) {
        write r2.txt $gettok($read(rankings.txt,n,%i),1,32) $gettok($read(rankings.txt,n,%i),2,32)
      }
      elseif ($gettok($read(rankings.txt,n,%i),2,32) isnum) {
        write r2.txt $gettok($read(rankings.txt,n,%i),2,32) $gettok($read(rankings.txt,n,%i),1,32)
      }
      elseif ($mid($gettok($read(rankings.txt,n,%i),2,32),2,50) isnum) {
        write r2.txt $mid($gettok($read(rankings.txt,n,%i),2,32),2,50) $gettok($read(rankings.txt,n,%i),1,32)
      }
      elseif ($mid($gettok($read(rankings.txt,n,%i),1,32),2,50) isnum) {
        write r2.txt $mid($gettok($read(rankings.txt,n,%i),1,32),2,50) $gettok($read(rankings.txt,n,%i),2,32)
      }
      elseif ($mid($gettok($read(rankings.txt,n,%i),2,32),3,9) isnum) {
        write r2.txt $mid($gettok($read(rankings.txt,n,%i),2,32),3,9) $gettok($read(rankings.txt,n,%i),1,32)
      }
      elseif ($gettok($read(rankings.txt,n,%i),1,9) isnum) {
        write r2.txt $gettok($read(rankings.txt,n,%i),1,9) $gettok($read(rankings.txt,n,%i),2,9)
      }
      inc %i
    }
  }
}

;//automatically generates roundcaps from based on number of players per team
alias makerounds {
  if ($2 != $null) %pad = $2
  else %pad = 0
  var %maxP = 1500
  var %i = 1
  var %total = 0
  while (%i <= $lines(r2.txt)) {
    %total = $calc(%total + $gettok($read(r2.txt,n,%i),1,32))
    inc %i
  }
  var %avgsal = $round($calc( %total / $lines(r2.txt) ),0)
  echo -a %avgsal
  var %diff = $round($calc(((%avgsal * $1) + %pad - (2* %maxP))/($1 -2)),0)


  var %cap = $round($calc(%avgsal * $1 + %pad),0)

  set %teamcap %cap
  set %round1 $calc(%cap - %maxP)
  set %round2 $calc(%cap -(2*%maxP))
  var %t
  %i = 1
  while (%i < $calc($1 -2)) {
    %t = $+(%t,$chr(44),$round($calc((%cap -(2*%maxP))-(%i * %diff)),0))
    set %round [ $+ [ $calc(%i +2) ] ] $round($calc((%cap -(2*%maxP))-(%i * %diff)),0)
    inc %i
  }
  set %round [ $+ [ $1 ] ] 0
  %t = $+(%t,$chr(44),0)
  .timer 1 0 _msg Rounds set to: $+(%cap,$chr(44),$calc(%cap - %maxP),$chr(44),$calc(%cap -(2*%maxP)),%t)
  .timer 1 0 _msg to change the rounds use .rounds #,#,#,...
}

;//devoice all captains
alias removevoices {
  var %i = 0
  if (%total_captains isnum 0-100) {
    while (%i != %total_captains) {
      var %t = $gettok(%captain [ $+ [ %i ] ] ,1,32)
      mode %chan -v %t
      inc %i
    }
  }
}

;//finds *player* in the list
alias fh {
  var %j = 1
  var %found = 0
  while (%j < $lines(r2.txt)) {
    if ($read(r2.txt,w,$+(*,$1,*),%j)) {
      _msg $gettok($read(r2.txt,w,$+(*,$1,*),%j),1,32) $+ $chr(183) $+ $gettok($read(r2.txt,w,$+(*,$1,*),%j),2,32)
      inc %found
    }
    if ($readn == 0) %j = $lines(r2.txt)
    else %j = 1 + $readn
    if (%found > 3) {
      .timer -m 1 50 _msg too many matches
      break
    }
  }
  if (%found == 0) _msg can't find $1
}

;//outputs all players within the given pricerange denoted in xx-yy format
alias range {
  var %done = 0
  var %temp 14,01
  var %p = 15
  var %i = 1
  while ($read(r2.txt,%i)) {
    if ( $gettok($read(r2.txt,%i),1,32) <= $2 ) && ( $gettok($read(r2.txt,%i),1,32) >= $1 ) {
      if (%temp == 14,01) %temp = $+(%temp,$gettok($read(r2.txt,%i),1,32),$chr(183),$gettok($read(r2.txt,%i),2,32),,%p)
      else %temp = %temp $+($gettok($read(r2.txt,%i),1,32),$chr(183),$gettok($read(r2.txt,%i),2,32),,%p)
    }
    inc %i
    inc %p
    if (%p == 16) %p = 14
    if ($len(%temp) > 325) {
      var %temp [ $+ [ %done ] ] %temp
      %temp = 14,01
      inc %done
    }
  }

  %i = 0
  while (%i < %done) {
    .timer -m 1 $calc(%i * 200) _msg %temp [ $+ [ %i ] ]
    inc %i
  }
  if ($len(%temp) <= 325) && ($strip(%temp) != $null) .timer -m 1 $calc(%done * 200) _msg %temp
  if ($strip(%temp) == $null) && (%done == 0) && (%i == 0) _msg no matches for that range
}

;//function which adjusts vars and outputs messages on round start
alias round_start {
  inc %current_round
  set %list
  set %listt
  %current_captain = 1
  var %ii = 1
  while (%ii <= %total_captains) {
    %list = %list $+($gettok(%captain [ $+ [ %ii ] ] ,2,32),$chr(7),$gettok(%captain [ $+ [ %ii ] ] ,3,32),$chr(7),$gettok(%captain [ $+ [ %ii ] ] ,1,32),$chr(7),%ii)
    inc %ii
  }
  var %i = 1
  while (%i <= %total_captains) {
    %listt = %listt $+($calc($gettok(%captain [ $+ [ %i ] ] ,2,32) - %round [ $+ [ %current_round ] ] ),$chr(7),$gettok(%captain [ $+ [ %i ] ] ,3,32))
    inc %i
  }
  %list = $sorttok(%list,32,nr)
  %listt = $sorttok(%listt,32,nr)
  .timer 1 0 _msg $pickmsgs(null).roundstart
  .timer -m 1 50 _msg $pickmsgs(null).roundstart2
  if ($do(null).controller !isop %chan ) {
    .timer -m 1 100 mode %chan +v $do(null).controller
  }
  timeout
}

;//returns the price of the player
alias price {
  if ($1 == $null) return
  var %i = 1
  while (%i <= $lines(r2.txt)) {
    if ($gettok($read(r2.txt,%i),2,32) == $1) return $gettok($read(r2.txt,%i),1,32))
    inc %i
  }
}

;//returns information about the captain currently picking
alias do {
  if ($prop == captain) return $gettok($gettok(%list,%current_captain,32),2,7)
  if ($prop == list) return %listt
  if ($prop == num) return $gettok($gettok(%list,%current_captain,32),4,7)
  if ($prop == money) return $gettok($gettok(%list,%current_captain,32),1,7)
  if ($prop == controller) return $gettok($gettok(%list,%current_captain,32),3,7)
  if ($prop == totalmoney) return $gettok($gettok(%list,%current_captain,32),1,7)
}

;//echo back help commands
alias draft_help {
  var %i = 1
  while ( $read(help.txt,%i) ) {
    echo -a $read(help.txt,%i)
    inc %i
  }
}

;//find a captain in the varlist
alias findcapt {
  var %i = 1
  while (%i <= $var(%captain*) ) {
    if ( $1 == $gettok(%captain [ $+ [ %i ] ] ,3,32) ) {
      return %i
    }
    inc %i
  }
}

;//helper function when more than one bot is active to load-balance the messages
alias nicknum {
  if ($mid(%draftnick,$len(%draftnick),1) isnum) return $+($mid( [ %draftnick ] ,1,$calc($len(%draftnick)-1)),2)
  else return $+( [ %draftnick ] ,2)
}

;//formats the output messages and writes to the buffer file for message load-balancing
alias _msg {
  if ($nicknum !ison %chan) .timer 1 0 msg %chan 0,1[09×00]15 $1- 0,1[9×0]
  else {
    write -il1 temp.txt $+(%turn,$chr(7),0,$chr(44),1[09×00]15,$chr(44),01,$chr(32),$1-,$chr(32),0,$chr(44),1[9×0])
    if (%turn == 1) set %turn 0
    elseif (%turn == 0) set %turn 1
  }
}

;//formats the output messages and writes to the buffer file for message load-balancing
alias _msg2 {
  if (%chan != $null) && (%chan != off) {
    var %stuff = $read(temp.txt,1)
    if ($me == $nicknum) && ($gettok(%stuff,1,7) == 1) {
      .timer -m 1 $calc($lines(temp.txt) *2000) msg %chan $gettok(%stuff,2,7)
      write -dl1 temp.txt
    }
    elseif ($me == %draftnick) && ($gettok(%stuff,1,7) == 0) {
      .timer -m 1 $calc($lines(temp.txt) *2000) msg %chan $gettok(%stuff,2,7)
      write -dl1 temp.txt
    }
  }
}

;//removes the .! (command prefixes) from the input and returns all other characters
alias cp {
  if ( $regex($mid($1,1,1),[.!]) ) return $mid($1,2)
  else return 0
}

;//timeout helper function. resets the warning autopick timers
alias timeout {
  .timer $+ pick $+ $rand(1,1000000) 1 60 _msg $do(null).captain has 1 min left to pick ( $+ $gettok($gettok(%timeouts,$wildtok(%timeouts,$do(null).num $+ *,1,32),32),2,7) timeout(s) remaining)
  .timer $+ pick $+ $rand(1,1000000) 1 90 _msg $do(null).captain has 30 seconds left to pick or the highest salary player possible will automatically be picked ( $+ $gettok($gettok(%timeouts,$wildtok(%timeouts,$do(null).num $+ *,1,32),32),2,7) timeouts remaining)
  var %i = 1
  var %tmp
  while (%i <= $lines(r2.txt)) {
    if ($calc($do(null).money - %round [ $+ [ %current_round ] ] ) >= $gettok($read(r2.txt,n,%i),1,32)) {
      %tmp = $gettok($read(r2.txt,n,%i),2,32)
      break
    }
    inc %i
  }
  .timerpick 1 120 timeout2 %tmp
}

;//the auto-pick player timer
alias timeout2 {
  .timer 1 0 _msg $do(null).captain has picked $1
  .timer 1 0 playerpick $1
}

;//called when a timeout is requested
alias timeoutextra {
  var %y $gettok($gettok(%timeouts,$wildtok(%timeouts,$1 $+ *,1,32),32),2,7)
  if (%y > 0) {
    %timeouts = $puttok(%timeouts,$puttok($gettok(%timeouts,$wildtok(%timeouts,$1 $+ *,1,32),32),$calc(%y -1),2,7),$wildtok(%timeouts,$1 $+ *,1,32),32)
    .timerpick* off
    _msg $do(null).captain has 3 extra minutes to pick
    timeout
  }
  else {
    _msg too bad, no more timeouts
  }
}

;//called when a player is picked.
alias playerpick {
  if ($price($1) != $null) {
    if ( $calc($do(null).money - %round [ $+ [ %current_round ] ] ) >= $price($1) ) {
      if ($do(null).controller !isop %chan) mode %chan -v $do(null).controller
      %captain [ $+ [ $do(null).num ] ] = $puttok(%captain [ $+ [ $do(null).num ] ] ,$calc($do(null).money - $price($1)),2,32) $1
      var %temp $pickmsgs($price($1)).round3
      .timerpick* off
      var %playerreadline $readn
      var %k = 0
      while (%k <= $lines(captains.txt)) {
        if ($gettok($read(captains.txt,%k),2,32) == $do(null).captain) var %found = yes
        if (%found == yes) && ($read(captains.txt,%k) == %teamcap) {
          write -il $+ $calc(%k +1) captains.txt $price($1) $1
          draftbotHttpUpload
          break
        }
        if (%k == $lines(captains.txt)) {
          write captains.txt $price($1) $1
          draftbotHttpUpload
          break
        }
        inc %k
      }
      write -dl $+ %playerreadline r2.txt
      inc %current_captain 
      if (%current_captain > %total_captains) && (%current_round < %total_rounds) {
        .timer 1 0 _msg %temp
        .timer -m 1 50 teams whydoineedthis
        .timer -m 1 150 round_start
        if ($do(null).controller !isop %chan ) {
          .timer 1 0 mode %chan +v $do(null).controller
        }
      }
      elseif (%current_captain > %total_captains) && (%current_round == %total_rounds) {
        _msg Draft done!
        .timer 1 0 teams
        removevoices
        mode %chan -m
        set %draft 0
      }
      else {
        if ($do(null).controller !isop %chan) {
          .timer 1 0 mode %chan +v $do(null).controller
        }
        if (%current_round == %total_rounds) _msg $pickmsgs(null).round4
        else _msg %temp $pickmsgs(null).round4
        .timer 1 0 timeout
      }
    }
    else {
      _msg you don't have enough money for that
    }
  }
  else {
    _msg player doesn't exist. use .find player
  }
}

;//resets the draft. maintains captain and round values
alias draft_reset {
  makelist
  var %i = 1
  if ($var(%captain*) != $null) {
    while (%i <= $var(%captain*) ) {
      var %t = $gettok(%captain [ $+ [ %i ] ] ,3,32)
      var %line $read(r2.txt,w,* $+ %t)
      write -dl $+ $readn r2.txt
      set %captain [ $+ [ %i ] ] $gettok(%captain [ $+ [ %i ] ] ,1,32) $calc( %teamcap - $gettok(%line,1,32) ) $gettok(%line,2,32)
      inc %i
    }
  }
  removevoices
  mode %chan -m
  .timerpick* off
  unset %list*
  unset %total*
  unset %current*
  unset %timeouts
  set %draft 0
}
alias pad {
  var %length = $len($1)
  var %length2 = $2
  var %return = $1
  var %i = %length
  while (%i < %length2) {
    %return = $+(%return,$chr(32),)
    inc %i
  }
  return $+(%return)
}

;//outputs the current teams
alias teams {
  if ($var(%captain*)) {
    .timer 1 0 _msg Teams:
    var %k = 1
    var %t
    var %padlength = 0
    while (%k <= $var(captain*,0)) {
      %t = $+(%t,$chr(32),$gettok(%captain [ $+ [ %k ] ] ,2,32),$chr(44),%k)
      if ($len($gettok(%captain [ $+ [ %k ] ] ,3,32)) > %padlength) %padlength = $len($gettok(%captain [ $+ [ %k ] ] ,3,32))
      inc %k
    }
    %t = $sorttok(%t,32)
    var %k = 1
    var %tt
    while (%k <= $numtok(%t,32)) {
      %tt = $+(%tt,$chr(32),$gettok($gettok(%t,%k,32),2,44))
      inc %k
    }
    var %i = 1
    if ($var(%captain*)) {
      while (%i <= $numtok(%tt,32)) {
        var %ttt = %captain [ $+ [ $gettok(%tt,%i,32) ] ]
        %ttt = $deltok(%ttt,1,32)
        .timer 1 0 _msg $+(15,$chr(36),$calc(%teamcap - $gettok(%ttt,1,32)),$chr(32),$gettok(%ttt,2,32),$chr(32),$gettok(%ttt,3-,32))
        inc %i
      }
    }
  }
  else {
    _msg no teams!
  }
}

;//generic commands function, containing all the callable commands
alias commands {
  if ((%draft == 0)) || ($ulevel >= 6) || ($nick == $me) || ($nick isop %chan) {
    if (teams == $cp($1)) && (($nick == $me) || ($nick isop %chan)) {
      $teams(whydoineedthis)
    }
    if (showrounds == $cp($1)) _msg %rounds
    if (find == $cp($1)) && ($2 != $null) fh $2
    if (about == $cp($1)) _msg Draftbot v2.13 made by spydee
    if ($cp($1) == range) {
      if ($2 != $null) && ($chr(45) isin $2) && ($pos($2,-,0) == 1) && ($gettok($2,1,45) <= $gettok($2,2,45)) && ($gettok($2,1,45) isnum) && ($gettok($2,2,45) isnum) range $gettok($2,1,45) $gettok($2,2,45)
      else _msg invalid range.
    }
    if (commands == $cp($1)) {
      _msg 14.setdraft on|off 15.makelist 14.rounds #,# (include teamcap & 0) 15.players # (generate rounds,total players per team) 14.captain irc_nick draft_captain $&
        15.delcapt irc_nick draft_captain 14.resetcaptains 15.startdraft 14.reset(draft,same captains)  15.fullreset(draft,rounds,captains) 14.range #-#
      _msg 15.find 14.bank 15.teams 14.showteam 15.pick 14.fpick (fakepick) 15.order 14.nextorder 15.timeout 14.about
    }
  }
  if (($ulevel >= 6) || ($nick == $me) || ($nick isop %chan)) && (%draft == 1) {
    if (showteam == $cp($1)) {
      var %t = %captain [ $+ [ $do(null).num ] ]
      %t = $deltok(%t,1,32)
      .timer 1 0 _msg $+(15,Team $gettok(%t,2,32),$chr(32),$chr(40),$chr(36),$calc(%teamcap - $gettok(%t,1,32)),$chr(41),:,$chr(32),$gettok(%t,3-,32))
    }
    if (timeout == $cp($1)) && (($nick == $do(null).controller) || ($nick isop %chan) || ($nick == $me)) {
      $timeoutextra($do(null).num)
    }
    if (bank == $cp($1)) {
      _msg $do(null).captain has $calc($do(null).money - %round [ $+ [ $calc(%current_round) ] ] ) to spend this round with a total of $do(null).totalmoney left
    }
    if (order == $cp($1)) {
      _msg Pick order: $replace(%listt,$chr(7),$chr(183))
    }
    if (nextorder == $cp($1)) {
      var %tmpp 
      var %i = 2
      while (%i <= %current_captain) {
        %tmpp = %tmpp $+($calc($gettok(%captain [ $+ [ $gettok($gettok(%list,$calc(%i -1),32),4,7) ] ] ,2,32) - %round [ $+ [ $calc(%current_round +1) ] ] ),$chr(183),$gettok($gettok(%list,$calc(%i -1),32),2,7)))
        inc %i
      }
      if (%current_captain > 1) _msg $+(Pick order for next round:,$chr(32),$sorttok(%tmpp,32,nr))
      else _msg No one picked yet
    }
    if (fpick == $cp($1)) || (fp == $cp($1)) {
      if ($price($2) != $null) {
        if ( $calc($do(null).money - %round [ $+ [ %current_round ] ] ) >= $price($2) ) {
          _msg $do(null).captain has $calc( $gettok(%captain [ $+ [ $do(null).num ] ] ,2,32) - %round [ $+ [ $calc(%current_round +1) ] ] - $price($2) ) for next round if $2 is picked
        }
        else _msg not enough money
      }
      else _msg player doesn't exist. use .find player
    }
    if ((pick == $cp($1)) || (p == $cp($1))) && ($2 != $null) && (($nick == $do(null).controller) || ($nick isop %chan) || ($nick == $me)) {
      $playerpick($2)
    }
  }
  if ($nick isop %chan) || ($nick == $me) {
    if ($cp($1) == pause) {
      timers off
      _msg Draft has been paused.
    }
    if ($cp($1) == reset) {
      draft_reset
      _msg draft reset. use .startdraft to restart
    }
    if ($cp($1) == fullreset) {   
      removevoices 
      unset %round*
      unset %captain*
      unset %teamcap*
      .rlevel -r 6
      draft_reset
      _msg captains, teamcap and rounds deleted. make sure to .makelist again
    }
    if (%draft == 0) {
      if (delcapt == $cp($1)) && ($2 != $null) && ($3 != $null) {
        if ($findcapt($3)) && ($3) {
          var %i = $findcapt($3)
          var %p = $var(%captain*)
          unset %captain [ $+ [ $findcapt($3) ] ]
          while (%i != %p ) {
            set %captain [ $+ [ %i ] ] %captain [ $+ [ $calc(%i + 1) ] ]
            inc %i
            if (%i == $var(%captain*)) unset %captain [ $+ [ %i ] ]
          }
          _msg captain $3 (controlled by $2) deleted
        }
        else {
          _msg captain $3 not found
        }
      }
      if (resetcaptains == $cp($1)) {
        removevoices
        unset %captain*
        rlevel -r 6
        _msg captains reset
      }
      if (makelist == $cp($1)) {
        makelist
        _msg List compiled. Don't forget to check r2.txt for any errors (spaces in a player name will screw it up).
      }
    }
    if (players == $cp($1)) && ($2 != $null) {
      if ($numtok($2,44) == 1) && ($2 isnum) {
        $makerounds($2,$3)
      }
    }
    if (rounds == $cp($1)) && ($2 != $null) {
      unset %round*
      unset %teamcap
      var %r = 1
      var %ttmp
      while (%r <= $numtok($2,44)) {
        %ttmp = $gettok($2,%r,44)
        if (%ttmp isnum) && (%ttmp >= 0) {
          if (%r == 1) set %teamcap %ttmp
          else set %round [ $+ [ $calc(%r -1) ] ] %ttmp
        }
        else {
          .timer 1 0 _msg invalid values
          goto end
        }
        inc %r
      }
      .timer 1 0 _msg values added
    }
    if (startdraft == $cp($1)) {
      if (%teamcap == $null) {
        _msg teamcap needed. .rounds #,#,# or .players # of total players per team
        goto end
      }
      if ($var(%round*) < 2) || ($var(%captain*) < 2) {
        _msg rounds/captains need to be larger than 1. type .commands or .help for info
        goto end
      }
      var %k = 1
      set %timeouts
      var %numtimeouts 2
      write -c captains.txt
      ;write captains.txt teamcap %teamcap rounds $var(%round*) total_captains $var(%captain*) players $lines(r2.txt) timeouts %numtimeouts
      draftbotHttpUpload
      while (%k <= $var(%captain*)) {
        %timeouts = %timeouts $+(%k,$chr(7),%numtimeouts)
        var %cap = $gettok( [ $var( %captain*,%k) ] ,3,32)
        write captains.txt %teamcap
        write captains.txt $calc(%teamcap - $gettok( [ $var( %captain*,%k) ] ,2,32)) %cap
        inc %k
      }
      mode %chan +m
      %draft = 1
      %total_rounds = $var(%round*)
      %total_captains = $var(%captain*)
      removevoices
      %current_round = 1
      %current_captain = 1
      .timer 1 0 _msg Captains have been bought.
      .timer -m 1 50 round_start
      :end
    }
    if ($cp($1) == captain) && ($2 != $null) && ($3 != $null) {
      if (%teamcap == $null) _msg must have valid teamcap before inputting captains
      else {
        if (%draft == 0) {
          if ($findcapt($3)) {
            if ($2 ison %chan) {
              set %captain $+ $findcapt($3) $puttok(%captain [ $+ [ $findcapt($3) ] ] ,$2,1,32)
              _msg $2 now controls picking for $3
              .guser 6 $2 0
              ;delete old guser here
              goto skip
            }
            else {
              _msg $2 isn't on the channel
              goto end2
            }
          }
          if ($read(r2.txt,w,* $+ $3)) {
            if ($2 ison %chan) {
              var %line $read(r2.txt,w,* $+ $3)
              write -dl $+ $readn r2.txt
              set %captain $+ $calc($var(%captain*)+1) $2 $calc( %teamcap - $gettok(%line,1,32) ) $gettok(%line,2,32)
              .guser 6 $2 0
              _msg $2 now controls picking for $3
            }
            else {
              _msg $2 isn't on the channel
              goto end2
            }
          }
          else {
            _msg cant find $3 in makelist
          }
          :skip
        }
        if (%draft == 1) {
          if ($findcapt($3)) {
            if ($2 ison %chan) {
              set %captain $+ $findcapt($3) $puttok(%captain [ $+ [ $findcapt($3) ] ] ,$2,1,32)
              var %i = 1
              while (%i <= $numtok(%list,32)) {
                if ($gettok($gettok(%list,%i,32),2,7) == $3) {
                  set %list $puttok(%list,$puttok($gettok(%list,%i,32),$2,3,7),%i,32)
                }
                inc %i
              }
              _msg controller for $3 changed to $2
              .guser 6 $2 0
              ;delete old guser here
            }
            else {
              _msg $2 isn't on the channel
              goto end2
            }
          }
          else {
            _msg can't find $3 in current captain list
          }
        }
      }
    }
  }
  :end2
}
on *:NICK:{
  if ($nick == %draftnick) set %draftnick $newnick
}

;//text input from other users
on *:TEXT:*:#:{
  if (setdraft == $cp($1)) && ($2 != $null) && ($nick isop %chan) {
    if ($2 == on) {
      set %chan $chan
      _msg draft channel set to %chan
      var %tmp
      if ($mid($me,$len($me),1) == 2) %tmp = $mid($me,1,$calc($len($me)-1))
      else %tmp = $me
      set %draftnick %tmp
    }
    if ($2 == off) {
      .timer 1 0 _msg %chan draftbot disabled
      set %chan off
    }
  }
  if ($chan == %chan) && ($me == %draftnick) {
    $commands($1,$2,$3,$4)
  }
  ;//if ($me == $nicknum) && ($timer(msgs) == $null) .timermsgs -m 0 50 _msg2
  ;//if ($me == %draftnick) && ($timer(msgs2) == $null) .timermsgs2 -m 0 50 _msg2
}

;//local input
on *:INPUT:#:{
  if (setdraft == $cp($1)) && ($2 != $null) {
    if ($2 == on) {
      set %chan $chan
      _msg draft channel set to %chan
      var %tmp
      if ($mid($me,$len($me),1) == 2) %tmp = $mid($me,1,50)
      else %tmp = $me
      set %draftnick %tmp
    }
    if ($2 == off) {
      _msg %chan draftbot disabled
      set %chan off
    }
  }
  if ($chan == %chan) && ($me == %draftnick) {
    $commands($1,$2,$3,$4)
  }
  if (help == $cp($1)) .timer 1 0 draft_help
  ;//if ($me == $nicknum) && ($timer(msgs) == $null) .timermsgs -m 0 50 _msg2
  ;//if ($me == %draftnick) && ($timer(msgs2) == $null) .timermsgs2 -m 0 50 _msg2
}

alias urlencode2 return $replace($1,$chr(32),+)
alias draftbotHttpUpload {
  var %id = $rand(1,10000)
  sockopen draftbot $+ %id mlut.strangled.net 2012
  .timer 1 1 sockclose draftbot $+ %id
}

;//outputs draft data via HTTP
on *:sockopen:draftbot*:{
  bset -t &data 1 draft=
  var %i = 0
  while (%i <= $lines(captains.txt)) {
    bset -t &data $calc($bvar(&data,0)+1) $+($urlencode2($read(captains.txt, [ %i ] )),$chr(37),0D,$chr(37),0A)
    inc %i
  }
  bset -t &data $calc($bvar(&data,0)+1) &button=Submit
  ;echo -a $bvar(&data,1,100).text
  sockwrite -nt $sockname POST /draft.php HTTP/1.0
  sockwrite -nt $sockname Host: mlut.strangled.net:2012
  sockwrite -nt $sockname User-Agent: mirc
  sockwrite -nt $sockname Content-Type: application/x-www-form-urlencoded
  sockwrite -nt $sockname Content-Length: $bvar(&data,0)
  sockwrite -nt $sockname $crlf
  sockwrite $sockname &data
  sockclose $sockname
}