#include <sourcemod>
#include <multicolors>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <cstrike>
#include <overlays>
#include <emitsoundany>
#include <warden>

#include "include/PUBG/Global.sp"
#include "include/PUBG/Game.sp"
#include "include/PUBG/SQL.sp"
#include "include/PUBG/Download.sp"
#include "include/PUBG/Drop.sp"

#pragma semicolon 1

public Plugin myinfo = 
{
	name = "PUB-G", 
	author = "oppa", 
	description = "PUB-G Adaptation for CS:GO Game", 
	version = "1.0", 
	url = "csgo-turkiye.com"
};
/*
                                        __                __   .__                                        
  ____   ______ ____   ____           _/  |_ __ _________|  | _|__|___.__. ____       ____  ____   _____  
_/ ___\ /  ___// ___\ /  _ \   ______ \   __\  |  \_  __ \  |/ /  <   |  |/ __ \    _/ ___\/  _ \ /     \ 
\  \___ \___ \/ /_/  >  <_> ) /_____/  |  | |  |  /|  | \/    <|  |\___  \  ___/    \  \__(  <_> )  Y Y  \
 \___  >____  >___  / \____/           |__| |____/ |__|  |__|_ \__|/ ____|\___  > /\ \___  >____/|__|_|  /
     \/     \/_____/                                          \/   \/         \/  \/     \/            \/ 
                            __________ ____ _____________            ________                             
                            \______   \    |   \______   \          /  _____/                             
                             |     ___/    |   /|    |  _/  ______ /   \  ___                             
                             |    |   |    |  / |    |   \ /_____/ \    \_\  \                            
                             |____|   |______/  |______  /          \______  /         
*/
