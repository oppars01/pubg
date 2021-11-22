ConVar cv_pubg_tag = null, cv_pubg_flags = null, cv_pubg_droptime = null, cv_pubg_team_waiting_time = null;
// pubg_status ==> 0 Disable +++ 1 Countdown to Start +++ 2 Active  +++ 3 Finish Countdown
// team_status ==> 0 No Team +++ 1 Team Active and In-Team FF Off +++ 2 Team Active and In-Team FF On
char pubg_tag[64], mapName[128],pubg_status = '0', team_status = '0';
//0-23 Weapon 1  +++ 24-33 Weapon 2 +++ 34-42 Bombs +++ 43-44 Other
char weapons[50][] = {"weapon_mp9","weapon_mp7","weapon_mp5sd","weapon_ump45","weapon_p90","weapon_bizon","weapon_mac10","weapon_awp","weapon_ssg08","weapon_sg556","weapon_ak47","weapon_aug","weapon_m4a1","weapon_m4a1_silencer","weapon_famas","weapon_g3sg1","weapon_galilar","weapon_m249","weapon_mag7","weapon_negev","weapon_nova","weapon_sawedoff","weapon_scar20","weapon_xm1014","weapon_deagle","weapon_elite","weapon_fiveseven","weapon_glock","weapon_hkp2000","weapon_p250","weapon_tec9","weapon_cz75a","weapon_usp_silencer","weapon_revolver","weapon_molotov","weapon_hegrenade","weapon_flashbang","weapon_decoy","weapon_smokegrenade","weapon_healthshot","weapon_tagrenade","weapon_bumpmine","weapon_breachcharge","weapon_knife","weapon_knifegg","weapon_hammer","weapon_axe","weapon_spanner","weapon_taser","weapon_shield"};
bool weaponStatus[sizeof(weapons)] = { true, ... }, autoObstacle = true, autoDrop = true;
char gameMode[2],gameType[2],rallyingPoint[64];
Handle g_hDB = INVALID_HANDLE,g_Model = INVALID_HANDLE,g_ArmsModel = INVALID_HANDLE;
int tempTimer, clientTeam[MAXPLAYERS+1] = { -1, ... }, clientTime[MAXPLAYERS+1] = { -1, ... };

public void OnPluginStart()
{
    CreateDirectory("addons/sourcemod/logs/pubg", 511);
    LoadTranslations("pubg.phrases.txt");
    cv_pubg_tag = CreateConVar("sm_pubg_tag", "[PUB-G]", "Sets tags in messages.\nMaximum Character Length: 64");
    ConVar cv_command_setting = CreateConVar("sm_pubg_setting_commands", "sm_pubgsetting sm_pubgayar", "Sets the commands for the setting menu.\nSet the commands with the Spacebar.\nMaximum Total Character Length: 128\nMaximum Command: 7\nMaximum Command Character Length: 20");
    ConVar cv_command_main = CreateConVar("sm_pubg_main_commands", "sm_pubg", "Sets the commands for the main menu.\nSet the commands with the Spacebar.\nMaximum Total Character Length: 128\nMaximum Command: 7\nMaximum Command Character Length: 20");
    ConVar cv_command_team = CreateConVar("sm_pubg_team_commands", "sm_pubgteam sm_pubgtakim", "Sets the commands for the team menu.\nSet the commands with the Spacebar.\nMaximum Total Character Length: 128\nMaximum Command: 7\nMaximum Command Character Length: 20");
    cv_pubg_flags = CreateConVar("sm_pubg_flags", "b", "Authority flag. \nSet the commands with the Spacebar.\nRoot has automatic permission. You don't need to add.\nMaximum Character Length: 32");
    cv_pubg_droptime = CreateConVar("sm_pubg_droptime", "15.0", "Auto Drop Time. \nIf the automatic drop status is active, it determines how many seconds the drop will drop from the start of the game.");
    cv_pubg_team_waiting_time = CreateConVar("sm_pubg_team_waiting_time", "10", "Team Waiting Time. \nThe amount of time to wait to send a new team request after submitting a team request.");
    AutoExecConfig(true, "pubg", "CSGO_Turkiye");
    SQL_TConnect(OnSQLConnect, "pubg");

    char pubg_setting_commands[128], pubg_setting_commands_array[7][20],pubg_main_commands[128], pubg_main_commands_array[7][20],pubg_team_commands[128], pubg_team_commands_array[7][20];

    GetConVarString(cv_command_setting, pubg_setting_commands, sizeof(pubg_setting_commands));
    for (int i = 0; i < ExplodeString(pubg_setting_commands, " ", pubg_setting_commands_array, sizeof(pubg_setting_commands_array), sizeof(pubg_setting_commands_array[])); i++)
    {
        RegAdminCmd(pubg_setting_commands_array[i], PUBG_Setting, ADMFLAG_ROOT, "Sets the PUB-G Game");
        PrintToServer("[PUB-G] Setting Command Loaded: %s", pubg_setting_commands_array[i]);
    }

    GetConVarString(cv_command_main, pubg_main_commands, sizeof(pubg_main_commands));
    for (int i = 0; i < ExplodeString(pubg_main_commands, " ", pubg_main_commands_array, sizeof(pubg_main_commands_array), sizeof(pubg_main_commands_array[])); i++)
    {
        RegConsoleCmd(pubg_main_commands_array[i], PUBG_Main);
        PrintToServer("[PUB-G] Main Command Loaded: %s", pubg_main_commands_array[i]);
    }

    GetConVarString(cv_command_team, pubg_team_commands, sizeof(pubg_team_commands));
    for (int i = 0; i < ExplodeString(pubg_team_commands, " ", pubg_team_commands_array, sizeof(pubg_team_commands_array), sizeof(pubg_team_commands_array[])); i++)
    {
        RegConsoleCmd(pubg_team_commands_array[i], PUBG_Team);
        PrintToServer("[PUB-G] Team Command Loaded: %s", pubg_team_commands_array[i]);
    }

    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Pre);
    HookEvent("round_end", Event_RoundEndStart);
    HookEvent("round_start", Event_RoundEndStart);
    HookEvent("player_death", Event_PlayerDeath);

    g_Model = RegClientCookie("PUBG_Old_Model", "PUB-G Old Player Model Cookie", CookieAccess_Protected);
    g_ArmsModel = RegClientCookie("PUBG_Old_ArmsModel", "PUB-G Old Player Arms Model Cookie", CookieAccess_Protected);
}

public void OnMapStart()
{
    GetCurrentMap(mapName, sizeof(mapName));
    if (StrContains(mapName, "jb_", false) == -1 && StrContains(mapName, "jail_", false) == -1 && StrContains(mapName, "ba_jail", false) == -1)SetFailState("[PUB-G] This plugin is only active in jailbreak mode.");
    GetConVarString(cv_pubg_tag, pubg_tag, sizeof(pubg_tag));
    FindConVar("game_type").GetString(gameType,sizeof(gameType));
    FindConVar("game_mode").GetString(gameMode,sizeof(gameMode));
    Download();
}

public void OnClientCookiesCached(int client)
{
    SetClientCookie(client, g_Model, "");
    SetClientCookie(client, g_ArmsModel, "");
}

public void OnClientPostAdminCheck(int client)
{
    if (!IsFakeClient(client)&&IsValidClient(client))
    {
        Player_PUBG_Stop(client,false);
    }
}

void ErrorLog(char[] errorDescription, char[] error)
{
    char sError[256], sErrorLogPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sErrorLogPath, sizeof(sErrorLogPath), "logs/pubg/errors.log");
    Format(sError, sizeof(sError), "%t", errorDescription, error);
    LogToFileEx(sErrorLogPath, sError);
    LogError(sError);
}

Action PUBG_Setting(int client, int args)
{
    if (client != 0)
    {
        if (IsClientConnected(client) && IsValidClient(client) && !IsFakeClient(client) && IsPlayerAlive(client))
        {
            if (pubg_status != '0')
            {
                CPrintToChat(client, "%t", "PUB-G Active", pubg_tag);
            }
            else
            {
                PUBG_Setting_Menu().Display(client, MENU_TIME_FOREVER);
            }
        }
        else
        {
            CPrintToChat(client, "%t", "PUB-G Command Client Error", pubg_tag);
        }
    }
    else
    {
        ReplyToCommand(client, "%t", "PUB-G Console Error", pubg_tag);
    }
    return Plugin_Handled;
}

Menu PUBG_Setting_Menu()
{
    DeleteSettingModel();
    char temp[128];
    Menu menu = new Menu(PUBG_Setting_Menu_Callback);
    menu.SetTitle("%t", "PUB-G Setting Menu Title", pubg_tag);
    Format(temp, sizeof(temp), "%t", "PUB-G New Position");
    menu.AddItem("newPosition", temp);
    Format(temp, sizeof(temp), "%t", "PUB-G Delete Position");
    menu.AddItem("deletePosition", temp);
    Format(temp, sizeof(temp), "%t", "PUB-G Game Menu");
    menu.AddItem("gameMenu", temp);
    return menu;
}

int PUBG_Setting_Menu_Callback(Menu menu, MenuAction action, int client, int param2)
{
    if (action == MenuAction_Select)
    {
        char option[32];
        menu.GetItem(param2, option, sizeof(option));
        if (StrEqual(option, "gameMenu", true))
        {
            PUBG_MENU_Query(client);
        }
        else
        {
            if (pubg_status != '0')
            {
                CPrintToChat(client, "%t", "PUB-G Active", pubg_tag);
            }
            else
            {
                if (StrEqual(option, "newPosition", true))
                {
                    PUBG_NewPosition_Menu().Display(client, MENU_TIME_FOREVER);
                }
                else if (StrEqual(option, "deletePosition", true))
                {
                    PUBG_DeletePosition_Menu().Display(client, MENU_TIME_FOREVER);
                }
            }
        }
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
}

Menu PUBG_NewPosition_Menu()
{
    SettingModelLoad();
    char temp[128];
    Menu menu = new Menu(PUBG_NewPosition_Menu_Callback);
    menu.SetTitle("%t", "PUB-G New Position Menu Title", pubg_tag);
    Format(temp, sizeof(temp), "SELECT COUNT(*) FROM `pubg_coordinates` WHERE `type` = %d and `map_name`='%s'", false, mapName);
    Format(temp, sizeof(temp), "%t", "PUB-G New Client Position", CountData(temp));
    menu.AddItem("0", temp);
    Format(temp, sizeof(temp), "SELECT COUNT(*) FROM `pubg_coordinates` WHERE `type` = %d and `map_name`='%s'", true, mapName);
    Format(temp, sizeof(temp), "%t", "PUB-G New Drop Position", CountData(temp));
    menu.AddItem("1", temp);
    Format(temp, sizeof(temp), "%t", "PUB-G Setting Main Menu");
    menu.AddItem("mainSetting", temp);
    return menu;
}

int PUBG_NewPosition_Menu_Callback(Menu menu, MenuAction action, int client, int param2)
{
    if (action == MenuAction_Select)
    {
        if (pubg_status != '0')
        {
            CPrintToChat(client, "%t", "PUB-G Active", pubg_tag);
        }
        else
        {
            char option[32];
            menu.GetItem(param2, option, sizeof(option));
            if (StrEqual(option, "mainSetting", true))
            {
                PUBG_Setting_Menu().Display(client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(option, "0", true) || StrEqual(option, "1", true))
            {
                char query[255];
                Format(query, sizeof(query), "SELECT COUNT(*) FROM `pubg_coordinates` WHERE `type` = %d and `map_name`='%s'", StringToInt(option), mapName);
                if (CountData(query) >= 255)
                {
                    CPrintToChat(client, "%t", "PUB-G Max Position Insert Error", pubg_tag, 255);
                }
                else
                {
                    float pos[3];
                    GetAimCoords(client, pos);
                    if (TR_PointOutsideWorld(pos))
                    {
                        CPrintToChat(client, "%t", "PUB-G Failed Point Outside World", pubg_tag);
                    }
                    else
                    {
                        Format(query, sizeof(query), "INSERT INTO `pubg_coordinates`(`map_name`,`type`,`x`,`y`,`z`) VALUES('%s', %d,%f,%f,%f);", mapName, StringToInt(option), pos[0], pos[1], pos[2]);
                        if (SQLQueryNoData(query))
                        {
                            CPrintToChat(client, "%t", "PUB-G Successful Position Insert", pubg_tag);
                        }
                        else
                        {
                            CPrintToChat(client, "%t", "PUB-G Failed Position Insert", pubg_tag);
                        }
                    }
                }
                PUBG_NewPosition_Menu().Display(client, MENU_TIME_FOREVER);
            }
        }
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
    else if (action == MenuAction_Cancel)
    {
        DeleteSettingModel();
    }
}

Menu PUBG_DeletePosition_Menu()
{
    SettingModelLoad();
    char temp[255];
    Menu menu = new Menu(PUBG_DeletePosition_Menu_Callback);
    menu.SetTitle("%t", "PUB-G Delete Position Menu Title", pubg_tag);
    Format(temp, sizeof(temp), "SELECT COUNT(*) FROM `pubg_coordinates`");
    Format(temp, sizeof(temp), "%t", "PUB-G All Map Delete Position", CountData(temp));
    menu.AddItem("deleteAllMapPosition", temp);
    Format(temp, sizeof(temp), "SELECT COUNT(*) FROM `pubg_coordinates` WHERE `map_name`='%s'", mapName);
    Format(temp, sizeof(temp), "%t", "PUB-G This Map Delete Position", CountData(temp));
    menu.AddItem("deleteThisMapPosition", temp);
    Format(temp, sizeof(temp), "SELECT COUNT(*) FROM `pubg_coordinates` WHERE `type` = %d and `map_name`='%s'", false, mapName);
    Format(temp, sizeof(temp), "%t", "PUB-G This Map Delete Client Position", CountData(temp));
    menu.AddItem("deleteThisMapClientPosition", temp);
    Format(temp, sizeof(temp), "SELECT COUNT(*) FROM `pubg_coordinates` WHERE `type` = %d and `map_name`='%s'", true, mapName);
    Format(temp, sizeof(temp), "%t", "PUB-G This Map Delete Drop Position", CountData(temp));
    menu.AddItem("deleteThisMapDropPosition", temp);
    Format(temp, sizeof(temp), "%t", "PUB-G This Map Delete Aim Position");
    menu.AddItem("deleteThisMapAimPosition", temp);
    Format(temp, sizeof(temp), "SELECT COUNT(DISTINCT `map_name`) FROM `pubg_coordinates`");
    Format(temp, sizeof(temp), "%t", "PUB-G Delete Position Map List", CountData(temp));
    menu.AddItem("deleteThisMapList", temp);
    Format(temp, sizeof(temp), "%t", "PUB-G Setting Main Menu");
    menu.AddItem("mainSetting", temp);
    return menu;
}

int PUBG_DeletePosition_Menu_Callback(Menu menu, MenuAction action, int client, int param2)
{
    if (action == MenuAction_Select)
    {
        if (pubg_status != '0')
        {
            CPrintToChat(client, "%t", "PUB-G Active", pubg_tag);
        }
        else
        {
            char option[32];
            menu.GetItem(param2, option, sizeof(option));
            if (StrEqual(option, "mainSetting", true))
            {
                PUBG_Setting_Menu().Display(client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(option, "deleteThisMapList", true))
            {
                PUBG_DeletePositionMapList_Menu().Display(client, MENU_TIME_FOREVER);
            }
            else
            {
                char query[255];
                if (StrEqual(option, "deleteAllMapPosition", true))
                {
                    Format(query, sizeof(query), "DELETE FROM `pubg_coordinates`;");
                    if (SQLQueryNoData(query))
                    {
                        CPrintToChat(client, "%t", "PUB-G Successful Delete All Map Position", pubg_tag);
                    }
                    else
                    {
                        CPrintToChat(client, "%t", "PUB-G Failed Delete All Map Position", pubg_tag);
                    }
                }
                else if (StrEqual(option, "deleteThisMapPosition", true))
                {
                    Format(query, sizeof(query), "DELETE FROM `pubg_coordinates` WHERE `map_name`='%s' ;", mapName);
                    if (SQLQueryNoData(query))
                    {
                        CPrintToChat(client, "%t", "PUB-G Successful Delete This Map Position", pubg_tag);
                    }
                    else
                    {
                        CPrintToChat(client, "%t", "PUB-G Failed Delete This Map Position", pubg_tag);
                    }
                }
                else if (StrEqual(option, "deleteThisMapClientPosition", true))
                {
                    Format(query, sizeof(query), "DELETE FROM `pubg_coordinates` WHERE `map_name`='%s' and `type`= %d ;", mapName, false);
                    if (SQLQueryNoData(query))
                    {
                        CPrintToChat(client, "%t", "PUB-G Successful Delete This Map Client Position", pubg_tag);
                    }
                    else
                    {
                        CPrintToChat(client, "%t", "PUB-G Failed Delete This Map Client Position", pubg_tag);
                    }
                }
                else if (StrEqual(option, "deleteThisMapDropPosition", true))
                {
                    Format(query, sizeof(query), "DELETE FROM `pubg_coordinates` WHERE `map_name`='%s' and `type`= %d ;", mapName, true);
                    if (SQLQueryNoData(query))
                    {
                        CPrintToChat(client, "%t", "PUB-G Successful Delete This Map Drop Position", pubg_tag);
                    }
                    else
                    {
                        CPrintToChat(client, "%t", "PUB-G Failed Delete This Map Drop Position", pubg_tag);
                    }
                }
                else if (StrEqual(option, "deleteThisMapAimPosition", true))
                {
                    int entity = GetClientAimTarget(client, false);
                    if (IsValidEntity(entity) && IsValidEdict(entity))
                    {
                        char className[64], modelName[256], targetName[64];
                        GetEdictClassname(entity, className, sizeof(className));
                        GetEntPropString(entity, Prop_Data, "m_ModelName", modelName, sizeof(modelName));
                        GetEntPropString(entity, Prop_Data, "m_iName", targetName, sizeof(targetName));
                        if (StrEqual(className, "prop_door_rotating") && (StrEqual(modelName, "models/csgo-turkiye_com/plugin/pubg/pubg_birincil.mdl") || StrEqual(modelName, "models/csgo-turkiye_com/plugin/pubg/pubg_ikincil.mdl")) && StrEqual(targetName, "csgo-turkiye_com-pubg") && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == -1)
                        {
                            float position[3];
                            GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
                            Format(query, sizeof(query), "SELECT COUNT(*) FROM `pubg_coordinates` WHERE `map_name`='%s' and `x`= %f and `y`= %f and `z`= %f", mapName, position[0], position[1], (position[2] - 15.0));
                            if (CountData(query) > 0)
                            {
                                Format(query, sizeof(query), "DELETE FROM `pubg_coordinates` WHERE `map_name`='%s' and `x`= %f and `y`= %f and `z`= %f", mapName, position[0], position[1], (position[2] - 15.0));
                                if (SQLQueryNoData(query))
                                {
                                    CPrintToChat(client, "%t", "PUB-G Successful Delete Aim Position", pubg_tag);
                                }
                                else
                                {
                                    CPrintToChat(client, "%t", "PUB-G Failed Delete Aim Position", pubg_tag);
                                }
                            }
                            else
                            {
                                CPrintToChat(client, "%t", "PUB-G Aim Not Position", pubg_tag);
                            }
                        }
                        else
                        {
                            CPrintToChat(client, "%t", "PUB-G Aim Not Position", pubg_tag);
                        }
                    }
                    else
                    {
                        CPrintToChat(client, "%t", "PUB-G Aim Not Position", pubg_tag);
                    }
                }
                PUBG_DeletePosition_Menu().Display(client, MENU_TIME_FOREVER);
            }
        }
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
    else if (action == MenuAction_Cancel)
    {
        DeleteSettingModel();
    }
}

Menu PUBG_DeletePositionMapList_Menu()
{
    DeleteSettingModel();
    char temp[255];
    Format(temp, sizeof(temp), "SELECT COUNT(DISTINCT `map_name`) FROM `pubg_coordinates`");
    Menu menu = new Menu(PUBG_DeletePositionMapList_Menu_Callback);
    menu.SetTitle("%t", "PUB-G Delete Position Map List Menu Title", pubg_tag, CountData(temp));

    Format(temp, sizeof(temp), "SELECT DISTINCT `map_name` FROM `pubg_coordinates`;");
    SelectMenuAddItem(menu, temp);

    Format(temp, sizeof(temp), "%t", "PUB-G Delete Menu");
    menu.AddItem("deleteMenu", temp);
    Format(temp, sizeof(temp), "%t", "PUB-G Setting Main Menu");
    menu.AddItem("mainSetting", temp);
    return menu;
}

int PUBG_DeletePositionMapList_Menu_Callback(Menu menu, MenuAction action, int client, int param2)
{
    if (action == MenuAction_Select)
    {
        if (pubg_status != '0')
        {
            CPrintToChat(client, "%t", "PUB-G Active", pubg_tag);
        }
        else
        {
            char option[128];
            menu.GetItem(param2, option, sizeof(option));
            if (StrEqual(option, "mainSetting", true))
            {
                PUBG_Setting_Menu().Display(client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(option, "deleteMenu", true))
            {
                PUBG_DeletePosition_Menu().Display(client, MENU_TIME_FOREVER);
            }
            else
            {
                char query[255];
                Format(query, sizeof(query), "DELETE FROM `pubg_coordinates` WHERE `map_name`='%s' ;", option);
                if (SQLQueryNoData(query))
                {
                    CPrintToChat(client, "%t", "PUB-G Successful Delete Map Select Position", pubg_tag, option);
                }
                else
                {
                    CPrintToChat(client, "%t", "PUB-G Failed Delete Map Select Position", pubg_tag, option);
                }
                PUBG_DeletePositionMapList_Menu().DisplayAt(client,GetMenuSelectionPosition(), MENU_TIME_FOREVER);
            }
        }
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
}

void GetAimCoords(int client, float vector[3])
{
    float vAngles[3];
    float vOrigin[3];
    GetClientEyePosition(client, vOrigin);
    GetClientEyeAngles(client, vAngles);
    Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
    if (TR_DidHit(trace))
        TR_GetEndPosition(vector, trace);
    trace.Close();
}

bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
    return entity > MaxClients;
}

void DeleteSettingModel()
{
    for (int i = MaxClients; i < GetMaxEntities(); i++)
    {
        if (IsValidEntity(i) && IsValidEdict(i))
        {
            char className[64], modelName[256], targetName[64];
            GetEdictClassname(i, className, sizeof(className));
            GetEntPropString(i, Prop_Data, "m_ModelName", modelName, sizeof(modelName));
            GetEntPropString(i, Prop_Data, "m_iName", targetName, sizeof(targetName));
            if (StrEqual(className, "prop_door_rotating") && (StrEqual(modelName, "models/csgo-turkiye_com/plugin/pubg/pubg_birincil.mdl") || StrEqual(modelName, "models/csgo-turkiye_com/plugin/pubg/pubg_ikincil.mdl")) && StrEqual(targetName, "csgo-turkiye_com-pubg") && GetEntPropEnt(i, Prop_Send, "m_hOwnerEntity") == -1)
            {
                RemoveEntity(i);
            }
        }
    }
}

bool CheckAdminFlag(int client)
{
    char flags[32];
    cv_pubg_flags.GetString(flags, sizeof(flags));
    int iCount = 0;
    char sflagNeed[22][8], sflagFormat[64];
    bool bEntitled = false;
    Format(sflagFormat, sizeof(sflagFormat), flags);
    ReplaceString(sflagFormat, sizeof(sflagFormat), ",", " ");
    iCount = ExplodeString(sflagFormat, " ", sflagNeed, sizeof(sflagNeed), sizeof(sflagNeed[]));
    for (int i = 0; i < iCount; i++)
    {
        if ((GetUserFlagBits(client) & ReadFlagString(sflagNeed[i])) || (GetUserFlagBits(client) & ADMFLAG_ROOT))
        {
            bEntitled = true;
            break;
        }
    }
    return bEntitled;
}

int GetAliveTeamCount(int team)
{
    int count = 0;
    for (new i=1; i<=MaxClients; i++)if (IsValidClient(i) && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team) count++;
    return count;
} 

stock void SetCvar(char[] cvarName, int value)
{
	ConVar IntCvar = FindConVar(cvarName);
	if (IntCvar == null)return;
	int flags = IntCvar.Flags;
	flags &= ~FCVAR_NOTIFY;
	IntCvar.Flags = flags;
	IntCvar.IntValue = value;
	flags |= FCVAR_NOTIFY;
	IntCvar.Flags = flags;
}

stock bool IsValidClient(int client)
{
	if(client > 0 && client <= MaxClients)
	{
		if(IsClientInGame(client))
			return true;
	}
	return false;
}