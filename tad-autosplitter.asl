// Visit for more information: https://www.speedrun.com/TAD_That_Alien_Dude
//
// TAD Autosplitter
// Made by:
// - Serdrad0x: Twitch - https://www.twitch.tv/serdrad0x / Discord - serdrad0x#5565
// - ZeDoctor: Discord - ZeDoc#4280

state("game-windows-alpha"){
  int songID  : 0x103c5f0, 0x1c, 0x6c, 0x18, 0x10; // levelID
  bool canMove : 0x103C748, 0x48c, 0x0, 0xe8, 0x184, 0x40; // Player can't move in a cutscene
}

init{
  // Get path to log file
  var page = modules.First();
  var gameDir = Path.GetDirectoryName(page.FileName);
  vars.logPath = gameDir + "/game-windows-alpha_Data/output_log.txt";

  vars.logReader = new StreamReader(new FileStream(vars.logPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite));
  
  // Variables to check if player talked to NPC
  vars.talkStatus = new bool[] {false, false, false, false, false, false, false};
  vars.talkElement = new string[] {"Keycodes Pressed", "Bear true", "Eggmund true", "Pigmin true", "Berry true", "Pulpee true", "Pony true"};
  vars.talkID = 0;

  vars.bossFightState = 0;
  vars.playerDied = false;
}

update{
  vars.logLine = vars.logReader.ReadLine();
  if (vars.logLine == null) {
    return false;
  } else {
    // Check if player talked to NPC (and for start)
    if(!vars.talkStatus[vars.talkID] && vars.talkElement[vars.talkID] == vars.logLine){
      vars.talkStatus[vars.talkID] = true;
    }
  }
}

startup{

}

start{
  // If "Keycodes Pressed" -> Start
  if(vars.talkStatus[vars.talkID]){
    vars.talkID += 1;
    return true;
  }
}

split{
  if (current.songID != 2 && current.canMove && current.canMove != old.canMove){
    vars.bossFightState = 1;
  }

  if (current.songID != 2 && !current.canMove && vars.bossFightState == 1){
    vars.bossFightState = 2;
  }

  if (current.songID == 2 && current.songID != old.songID){
    if (vars.bossFightState == 2){
      vars.bossFightState = 0;
      return true;
    } else if (vars.bossFightState == 1){
      vars.bossFightState = 0;
      vars.playerDied = true;
    }
  }
  
  if (current.songID == 7 && vars.bossFightState == 2){
    return true;
  }
}

reset{
  if (vars.playerDied){
    // Remove logfile
    try {
      FileStream fs = new FileStream(vars.logPath, FileMode.Open, FileAccess.Write, FileShare.ReadWrite);
      fs.SetLength(0);
      fs.Close();
    } catch {}
    // Reset variables
    vars.talkStatus = new bool[] {false, false, false, false, false, false, false};
    vars.talkID = 0;
    vars.bossFightState = 0;
    vars.playerDied = false;
    return true;
  }
}

isLoading{

}

exit{
  // Hackaround to reset the timer when exiting the game
  var model = new TimerModel() { 
    CurrentState = timer 
  };
  model.Reset();
   // Remove logfile
  try {
    FileStream fs = new FileStream(vars.logPath, FileMode.Open, FileAccess.Write, FileShare.ReadWrite);
    fs.SetLength(0);
    fs.Close();
  } catch {}
  // Reset variables
  vars.talkStatus = new bool[] {false, false, false, false, false, false, false};
  vars.talkID = 0;
  vars.bossFightState = 0;
  vars.playerDied = false;
}
