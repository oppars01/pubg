Action PUBG_Main(int client, int args)
{
    PUBG_MENU_Query(client);
    return Plugin_Handled;
}

Action PUBG_Team(int client, int args)
{
    if(TeamMenuControl(client)){
        PUBG_Team_Menu(client).Display(client, MENU_TIME_FOREVER);
    }
    return Plugin_Handled;
}

bool TeamMenuControl(int client){
    if (client != 0)
    {
        if (IsClientConnected(client) && IsValidClient(client) && !IsFakeClient(client))
        {
            if(pubg_status=='1'){
                if(team_status!='0'){
                    if(GetClientTeam(client) == 2){
                        if(clientTeam[client]==-1){
                            if(clientTime[client] < GetTime()-GetConVarInt(cv_pubg_team_waiting_time)){
                                return true;
                            }else{
                                CPrintToChat(client, "%t", "PUB-G Command Team Waiting Time Error", pubg_tag,(clientTime[client]+10-GetTime()));
                            }
                        }else{
                            CPrintToChat(client, "%t", "PUB-G Command Team Already Have Error", pubg_tag);
                        }
                    }else{
                        CPrintToChat(client, "%t", "PUB-G Command Team GetClientTeam Error", pubg_tag);
                    }
                }else{
                    CPrintToChat(client, "%t", "PUB-G Command Team Status Error", pubg_tag);
                }
            }else{
                CPrintToChat(client, "%t", "PUB-G Command Team Game Status Error", pubg_tag);
            }
        }else{
            CPrintToChat(client, "%t", "PUB-G Command Client Error", pubg_tag);
        }
    }else{
        ReplyToCommand(client, "%t", "PUB-G Console Error", pubg_tag);
    }
    return false;
}

bool clientControl(int client){
    if (client != 0)
    {
        if (IsClientConnected(client) && IsValidClient(client) && !IsFakeClient(client))
        {
            if(warden_iswarden(client) || CheckAdminFlag(client)){
                if(PositionCountQuery()){
                    return true;
                }else{
                    CPrintToChat(client, "%t", "PUB-G Main Menu Setting Error", pubg_tag);
                }
            }else{
                CPrintToChat(client, "%t", "PUB-G Main Menu Authority Error", pubg_tag);
            }
        }
        else
        {
            CPrintToChat(client, "%t", "PUB-G Command Client Error", pubg_tag);
        }
    }else
    {
        ReplyToCommand(client, "%t", "PUB-G Console Error", pubg_tag);
    }
    return false;
}

void PUBG_MENU_Query(int client){
    if (clientControl(client)){
        PUBG_Main_Menu().Display(client, MENU_TIME_FOREVER);
    }
}

bool PositionCountQuery(){
    char temp[255];
    Format(temp, sizeof(temp), "SELECT COUNT(*) FROM `pubg_coordinates` WHERE `type` = %d and `map_name`='%s'", false, mapName);
    int clientPos = CountData(temp);
    Format(temp, sizeof(temp), "SELECT COUNT(*) FROM `pubg_coordinates` WHERE `type` = %d and `map_name`='%s'", true, mapName);
    int dropPos = CountData(temp);
    if(clientPos>=1 && dropPos >=1){
        return true;
    }
    return false;
}

Menu PUBG_Main_Menu()
{
    char temp[128];
    Menu menu = new Menu(PUBG_Main_Menu_Callback);
    menu.SetTitle("%t", "PUB-G Main Menu Title", pubg_tag);
    if (pubg_status == '0')
    {
        char status;
        Format(temp, sizeof(temp), "%t", "PUB-G Game Start");
        menu.AddItem("gameStart", temp);
        Format(temp, sizeof(temp), "%t", "PUB-G Weapon Setting");
        menu.AddItem("weaponSetting", temp);
        if(team_status=='0'){
            Format(temp, sizeof(temp), "%t", "PUB-G Team No");
        }else if(team_status=='1'){
            Format(temp, sizeof(temp), "%t", "PUB-G Team On FF Off");
        }else{
            Format(temp, sizeof(temp), "%t", "PUB-G Team On FF On");
        }
        menu.AddItem("teamSetting", temp);

        if(autoObstacle){
            status = '+';
        }else{
            status = '-';
        }
        Format(temp, sizeof(temp), "%t", "PUB-G Auto Obstacle",status);
        menu.AddItem("autoObstacleSetting", temp);

        if(autoDrop){
            status = '+';
        }else{
            status = '-';
        }
        Format(temp, sizeof(temp), "%t", "PUB-G Auto Drop",status);
        menu.AddItem("autoDropSetting", temp);

    }else{
        Format(temp, sizeof(temp), "%t", "PUB-G Game Stop");
        menu.AddItem("gameStop", temp);
        Format(temp, sizeof(temp), "%t", "PUB-G Add Obstacle");
        menu.AddItem("addObstacle", temp);
        Format(temp, sizeof(temp), "%t", "PUB-G Add Drop Point");
        menu.AddItem("addDropPoint", temp);
        Format(temp, sizeof(temp), "%t", "PUB-G Add Drop");
        menu.AddItem("addDrop", temp);
        if (pubg_status == '1'){
            Format(temp, sizeof(temp), "%t", "PUB-G Add Time +10");
            menu.AddItem("addTime", temp);
            Format(temp, sizeof(temp), "%t", "PUB-G All Respawn");
            menu.AddItem("allRespawn", temp);
        }else if(pubg_status == '2'){
            Format(temp, sizeof(temp), "%t", "PUB-G Rallying Point and Time");
            menu.AddItem("rallyingPoint", temp);
            if(team_status!='0'){
                Format(temp, sizeof(temp), "%t", "PUB-G Team Off");
                menu.AddItem("teamOff", temp);
            }
        }
    }
    return menu;
}

int PUBG_Main_Menu_Callback(Menu menu, MenuAction action, int client, int param2)
{
    if (action == MenuAction_Select)
    {
        if (clientControl(client)){
            char option[32];
            menu.GetItem(param2, option, sizeof(option));
            if(pubg_status=='0'){
                if (StrEqual(option, "gameStart", true))
                {
                    GameStart(client);
                    PUBG_Main_Menu().Display(client, MENU_TIME_FOREVER);
                }else if(StrEqual(option, "weaponSetting", true)){
                    PUBG_Setting_Weapon_Menu().Display(client, MENU_TIME_FOREVER);
                }else if(StrEqual(option, "teamSetting", true)){
                    if(team_status=='0'){
                        team_status='1';
                    }else if(team_status=='1'){
                        team_status='2';
                    }else{
                        team_status='0';
                    }
                    PUBG_Main_Menu().DisplayAt(client, GetMenuSelectionPosition(),MENU_TIME_FOREVER);
                }else if(StrEqual(option, "autoObstacleSetting", true)){
                    autoObstacle = !autoObstacle;
                    PUBG_Main_Menu().DisplayAt(client, GetMenuSelectionPosition(),MENU_TIME_FOREVER);
                }else if(StrEqual(option, "autoDropSetting", true)){
                    autoDrop = !autoDrop;
                    PUBG_Main_Menu().DisplayAt(client, GetMenuSelectionPosition(),MENU_TIME_FOREVER);
                }
            }else{
                if (StrEqual(option, "gameStop", true)){
                    GameStop(true);
                    CPrintToChatAll("%t", "PUB-G Stop", pubg_tag,client);
                    PUBG_Main_Menu().Display(client, MENU_TIME_FOREVER);
                }else if (StrEqual(option, "addObstacle", true)){
                    float pos[3];
                    GetAimCoords(client, pos);
                    int entity = SpawnDroneGun(pos);
                    if (IsValidEntity(entity))
                    {
                        CPrintToChatAll("%t", "PUB-G Obstacle Info", pubg_tag, client);
                    }else{
                        CPrintToChat(client,"%t", "PUB-G Obstacle Error", pubg_tag);
                    }
                }else if (StrEqual(option, "addDropPoint", true)){
                    float dropPos[3];
                    GetAimCoords(client, dropPos);
                    CreateDrop(client,dropPos);  
                }else if (StrEqual(option, "addDrop", true)){
                    float pos[3];
                    GetAimCoords(client, pos);
                    int entityDrop = SpawnDrop(false,pos);
                    if (IsValidEntity(entityDrop))
                    {
                        if (IsValidEntity(SpawnButton(pos, entityDrop)))
                        {
                            CPrintToChatAll("%t", "PUB-G Drop Info", pubg_tag, client);
                        }else{
                            RemoveEntity(entityDrop);
                            CPrintToChat(client, "%t", "PUB-G Drop Error", pubg_tag);
                        }
                    }else{
                        CPrintToChat(client, "%t", "PUB-G Drop Error", pubg_tag);
                    }
                }

                if(pubg_status=='1'){
                    if (StrEqual(option, "addTime", true)){
                        tempTimer += 10;
                        CPrintToChatAll("%t", "PUB-G Add Time", pubg_tag, client);
                    }else if (StrEqual(option, "allRespawn", true)){
                        for (new i=1; i<=MaxClients; i++)if (IsValidClient(i) && !IsFakeClient(i) && !IsPlayerAlive(i) && GetClientTeam(i) == 2)CS_RespawnPlayer(i);
                        CPrintToChatAll("%t", "PUB-G All Respawn Chat", pubg_tag, client);
                    }
                }else if(pubg_status=='2'){
                    if (StrEqual(option, "teamOff", true)){
                        team_status = '0';
                        CPrintToChatAll("%t", "PUB-G Team Off Chat", pubg_tag, client);
                    }else if (StrEqual(option, "rallyingPoint", true)){
                        PUBG_Freeze_Menu().Display(client, MENU_TIME_FOREVER);
                        return;
                    }
                }
                PUBG_Main_Menu().DisplayAt(client, GetMenuSelectionPosition(),MENU_TIME_FOREVER);
            }
        }  
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
}

Menu PUBG_Setting_Weapon_Menu()
{
    char temp[128];
    Menu menu = new Menu(PUBG_Setting_Weapon_Menu_Callback);
    menu.SetTitle("%t", "PUB-G Weapon Menu Title", pubg_tag);
    Format(temp, sizeof(temp), "%t", "PUB-G Weapon 1");
    menu.AddItem("weapon1", temp);
    Format(temp, sizeof(temp), "%t", "PUB-G Weapon 2");
    menu.AddItem("weapon2", temp);
    Format(temp, sizeof(temp), "%t", "PUB-G Bombs");
    menu.AddItem("bomb", temp);
    Format(temp, sizeof(temp), "%t", "PUB-G Other Weapon");
    menu.AddItem("other", temp);
    Format(temp, sizeof(temp), "%t", "PUB-G Reset Weapon");
    menu.AddItem("reset", temp);
    Format(temp, sizeof(temp), "%t", "PUB-G Main Menu");
    menu.AddItem("mainMenu", temp);
    return menu;
}

int PUBG_Setting_Weapon_Menu_Callback(Menu menu, MenuAction action, int client, int param2)
{
    if (action == MenuAction_Select)
    {
        if (clientControl(client)){
            char option[32];
            menu.GetItem(param2, option, sizeof(option));
            if (StrEqual(option, "mainMenu", true))
            {
                PUBG_MENU_Query(client);
            }else if (StrEqual(option, "reset", true)){
                ResetWeaponStatus();
                PUBG_Setting_Weapon_Menu().Display(client, MENU_TIME_FOREVER);
            }else if (StrEqual(option, "weapon1", true)){
                PUBG_Setting_Weapon_Menu2(0).Display(client, MENU_TIME_FOREVER);
            }else if (StrEqual(option, "weapon2", true)){
                PUBG_Setting_Weapon_Menu2(1).Display(client, MENU_TIME_FOREVER);
            }else if (StrEqual(option, "bomb", true)){
                PUBG_Setting_Weapon_Menu2(2).Display(client, MENU_TIME_FOREVER);
            }else if (StrEqual(option, "other", true)){
                PUBG_Setting_Weapon_Menu2(3).Display(client, MENU_TIME_FOREVER);
            }
        }
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
}

Menu PUBG_Setting_Weapon_Menu2(int type)
{
    char temp[128],temp2[8],status;
    Menu menu = new Menu(PUBG_Setting_Weapon_Menu2_Callback);
    menu.SetTitle("%t", "PUB-G Weapon Menu Title", pubg_tag);
    Format(temp, sizeof(temp), "%t", "PUB-G Main Menu");
    menu.AddItem("mainMenu", temp);
    Format(temp, sizeof(temp), "%t", "PUB-G Weapon Menu");
    menu.AddItem("WeaponMenu", temp);
    int start,stop;
    if(type==0){
        start = 0;
        stop = 23;
    }else if(type==1){
        start = 24;
        stop = 33;
    }else if(type==2){
        start = 34;
        stop = 42;
    }else{
        start = 43;
        stop = sizeof(weapons)-1;
    }
    for(int i=start;i<=stop;i++){
        if(weaponStatus[i]){
            status = '+'
        }else{
            status = '-';
        }
        Format(temp, sizeof(temp), "[%s] %t", status, weapons[i]);
        Format(temp2, sizeof(temp2), "%d", i);
        menu.AddItem(temp2, temp);
    }
    return menu;
}

int PUBG_Setting_Weapon_Menu2_Callback(Menu menu, MenuAction action, int client, int param2)
{
    if (action == MenuAction_Select)
    {
        if (clientControl(client)){
            char option[32];
            menu.GetItem(param2, option, sizeof(option));
            if (StrEqual(option, "mainMenu", true))
            {
                PUBG_MENU_Query(client);
            }else if (StrEqual(option, "WeaponMenu", true)){
                PUBG_Setting_Weapon_Menu().Display(client, MENU_TIME_FOREVER);
            }else{
                int weapon = StringToInt(option), type;
                if(weapon>=0 && weapon<=23){
                    type = 0;
                }else if(weapon>=24 && weapon<=33){
                    type = 1;
                }else if(weapon>=34 && weapon<=42){
                    type = 2
                }else if(weapon>=43 && weapon<=sizeof(weapons)-1){
                    type = 3;
                }else{
                    return;
                }
                weaponStatus[weapon]=!weaponStatus[weapon];
                PUBG_Setting_Weapon_Menu2(type).DisplayAt(client,GetMenuSelectionPosition(), MENU_TIME_FOREVER);
            }
        }
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
}

Menu PUBG_Freeze_Menu()
{
    if(tempTimer<=0)tempTimer=30;
    char temp[256];
    Menu menu = new Menu(PUBG_Freeze_Menu_Callback);
    menu.SetTitle("%t", "PUB-G Freeze Menu Title", pubg_tag);
    Format(temp, sizeof(temp), "%t", "PUB-G Rallying Point", rallyingPoint);
    menu.AddItem("null", temp, ITEMDRAW_DISABLED);
    Format(temp, sizeof(temp), "%t", "PUB-G Time", tempTimer);
    menu.AddItem("null", temp, ITEMDRAW_DISABLED);
    Format(temp, sizeof(temp), "%t", "PUB-G Change");
    menu.AddItem("change", temp);
    Format(temp, sizeof(temp), "%t", "PUB-G Approve");
    menu.AddItem("approve", temp);
    Format(temp, sizeof(temp), "%t", "PUB-G Main Menu");
    menu.AddItem("mainMenu", temp);
    return menu;
}

int PUBG_Freeze_Menu_Callback(Menu menu, MenuAction action, int client, int param2)
{
    if (action == MenuAction_Select)
    {
        if (pubg_status=='2'){
            if(IsValidClient(client) && !IsFakeClient(client) && (warden_iswarden(client) || CheckAdminFlag(client))){
                char option[32];
                menu.GetItem(param2, option, sizeof(option));
                if (StrEqual(option, "mainMenu", true))
                {
                    PUBG_MENU_Query(client);
                }else if (StrEqual(option, "change", true)){
                    clientTime[client] = GetTime();
                    PUBG_Freeze_Menu().Display(client, MENU_TIME_FOREVER);
                    CPrintToChat(client, "%t", "PUB-G Freeze Change",pubg_tag);
                }else if (StrEqual(option, "approve", true)){
                    CPrintToChatAll("%t", "PUB-G Freeze Info", pubg_tag, client);
                    CreateTimer(1.0, CountdownTimerStop, _, TIMER_FLAG_NO_MAPCHANGE);
                }
            }
        }
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
}

Menu PUBG_Team_Menu(int client)
{
    char temp[64],temp2[32];
    Menu menu = new Menu(PUBG_Team_Menu_Callback);
    menu.SetTitle("%t", "PUB-G Team Menu Title", pubg_tag);
    Format(temp, sizeof(temp), "%t", "PUB-G Refresh");
    menu.AddItem("refresh", temp);
    for (new i=1; i<=MaxClients; i++)if (IsValidClient(i) && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2 && i!=client && clientTeam[i]==-1){
        Format(temp, sizeof(temp), "%i", i);
        Format(temp2, sizeof(temp2), "%N", i);
        menu.AddItem(temp,temp2);
    }
    return menu;
}

int PUBG_Team_Menu_Callback(Menu menu, MenuAction action, int client, int param2)
{
    if (action == MenuAction_Select)
    {
        if(TeamMenuControl(client)){
            char option[32];
            menu.GetItem(param2, option, sizeof(option));
            if (StrEqual(option, "refresh", true))
            {
                PUBG_Team_Menu(client).Display(client, MENU_TIME_FOREVER);
            }else{
                int target = StringToInt(option);
                if(IsValidClient(target) && !IsFakeClient(target) && IsPlayerAlive(target) && GetClientTeam(target) == 2 && target!=client && clientTeam[target]==-1){
                    PUBG_Send_Team_Menu(client).Display(target, GetConVarInt(cv_pubg_team_waiting_time));
                    CPrintToChat(client,"%t","PUB-G Send Team",pubg_tag, target);
                    clientTime[client]= GetTime();
                }else{
                    CPrintToChat(client,"%t","PUB-G Send Team Error",pubg_tag, target);
                    PUBG_Team_Menu(client).Display(client, MENU_TIME_FOREVER);
                }
            }
        }
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
}

Menu PUBG_Send_Team_Menu(int target)
{
    char temp[256],temp2[64];
    Menu menu = new Menu(PUBG_Send_Team_Menu_Callback);
    menu.SetTitle("%t", "PUB-G Team Menu Title", pubg_tag);
    Format(temp, sizeof(temp), "%t", "PUB-G Send Team Menu",target);
    menu.AddItem("content", temp,ITEMDRAW_DISABLED);
    Format(temp, sizeof(temp), "%t", "PUB-G Yes");
    Format(temp2, sizeof(temp2), "yes_%d", target);
    menu.AddItem(temp2, temp);
    Format(temp, sizeof(temp), "%t", "PUB-G No");
    menu.AddItem("no", temp);
    return menu;
}

int PUBG_Send_Team_Menu_Callback(Menu menu, MenuAction action, int client, int param2)
{
    if (action == MenuAction_Select)
    {
        if(TeamMenuControl(client)){
            char option[32];
            menu.GetItem(param2, option, sizeof(option));
            if (StrContains(option, "yes_")==0)
            {
                ReplaceString(option, sizeof(option), "yes_", "");
                int target = StringToInt(option);
                if(IsValidClient(target) && !IsFakeClient(target) && IsPlayerAlive(target) && GetClientTeam(target) == 2 && target!=client && clientTeam[target]==-1){
                    clientTeam[client]= target;
                    clientTeam[target]= client;
                    SetListenOverride(client, target, Listen_Default);
                    SetListenOverride(target, client, Listen_Default);
                    float pos[3];
                    GetClientAbsOrigin(target, pos);
                    TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
                    CPrintToChatAll("%t","PUB-G Yes Team",pubg_tag, target,client);
                }else{
                    CPrintToChat(client,"%t","PUB-G Yes Team Error",pubg_tag, target);
                }
            }
        }
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
}

void GameStart(int client){
    bool weapon_count = false;
    for(int i=0;i<=sizeof(weapons);i++){
        if(weaponStatus[i]){
            weapon_count = true;
            break;
        }
    }
    if(weapon_count){
        int min_player=3;
        if(team_status=='0'){
            min_player=2;
        }
        if(GetAliveTeamCount(2)>=min_player){
            if(pubg_status=='0'){
                pubg_status='1';
                tempTimer = 30;
                CreateTimer(1.0, CountdownTimerStart, _, TIMER_FLAG_NO_MAPCHANGE);
                DeletePubgItemsAndWeapons();
                EmitSoundToAllAny("csgo-turkiye_com/pubg/pubg_game.mp3", -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
                Player_Start();
                if(team_status!='0')AllSelfMute(false);
                CPrintToChatAll("%t", "PUB-G Start", pubg_tag,client);
            }else{
                CPrintToChat(client, "%t", "PUB-G Active", pubg_tag);
            }
        }else{
            CPrintToChat(client,"%t","PUB-G Main Menu Player Count Error",pubg_tag,min_player);
        }
    }else{
        CPrintToChat(client,"%t","PUB-G Weapon Count Error",pubg_tag);
    }
}

void GameStop(bool freezePlayer){
    pubg_status='0';
    if (GetConVarInt(FindConVar("mp_teammates_are_enemies")) != 0)SetCvar("mp_teammates_are_enemies", 0);
    if (GetConVarInt(FindConVar("mp_friendlyfire")) != 0)SetCvar("mp_friendlyfire", 0);
    if (GetConVarInt(FindConVar("mp_respawn_on_death_t")) != 0)SetCvar("mp_respawn_on_death_t", 0);
    EmitSoundToAllAny("csgo-turkiye_com/pubg/pubg_game_end.mp3", -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
    for (new i=1; i<=MaxClients; i++)if (IsValidClient(i) && !IsFakeClient(i) && GetClientTeam(i) == 2){
        Player_PUBG_Stop(i,freezePlayer);
    }
    AllSelfMute(true);
    DeletePubgItemsAndWeapons();
    char message[512];
    Format(message,sizeof(message),"%t", "PUB-G Stop Panel");
    SendPanelToAll(message);
}

void Player_PUBG(int client){
    FindConVar("game_type").ReplicateToClient(client, "6");
    FindConVar("game_mode").ReplicateToClient(client, "0");
    if(pubg_status=='1'){
        SetEntProp(client, Prop_Send, "m_iHideHUD", 1<<0 | 1<<1 | 1<<3 | 1<<4 | 1<<5 | 1<<7 | 1<<8 | 1<<9 | 1<<10 | 1<<11 | 1<<12 );
        ShowOverlay(client, "models/csgo-turkiye_com/plugin/pubg/pubg-loading", 0.0);
        FreezePlayer(client);
    }else{
        SetEntProp(client, Prop_Send, "m_iHideHUD", 1<<12 );
    }
    DeleteWeaponClient(client);
    GivePlayerItem(client, "weapon_fists");
    SetEntityHealth(client, 100);
    SetEntProp(client, Prop_Send , "m_ArmorValue" , 100 );
    SetEntProp(client, Prop_Send , "m_bHasHelmet" , 1 );
    char playerModel[PLATFORM_MAX_PATH],armsModel[PLATFORM_MAX_PATH];
    GetClientModel(client, playerModel, sizeof(playerModel));
    SetClientCookie(client, g_Model, playerModel);
    GetEntPropString(client, Prop_Send, "m_szArmsModel", armsModel, sizeof(armsModel));
    SetClientCookie(client, g_ArmsModel, armsModel);
    switch (GetRandomInt(0, 2)){
        case 0:{
            Format(playerModel, sizeof(playerModel), "models/player/custom_player/legacy/tm_jumpsuit_varianta.mdl");
        }
        case 1:{
            Format(playerModel, sizeof(playerModel), "models/player/custom_player/legacy/tm_jumpsuit_variantb.mdl");
        }
        default:{
            Format(playerModel, sizeof(playerModel), "models/player/custom_player/legacy/tm_jumpsuit_variantc.mdl");
        }
    }
    SetEntityModel(client, playerModel);
    SetEntPropString(client, Prop_Send, "m_szArmsModel", "models/weapons/t_arms_phoenix.mdl", 0);
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
    ClientReset(client);
}

void Player_PUBG_Stop(int client,bool freezePlayer){
    FindConVar("game_type").ReplicateToClient(client, gameType);
    FindConVar("game_mode").ReplicateToClient(client, gameMode);
    SetEntProp(client, Prop_Send, "m_iHideHUD", 0);
    CreateTimer(0.0, DeleteOverlay, GetClientUserId(client));
    DeleteWeaponClient(client);
    GivePlayerItem(client, "weapon_knife");
    if(freezePlayer)
    {
        UnFreezePlayer(client);
    }else{
        FreezePlayer(client);
    }
    char playerModel[PLATFORM_MAX_PATH],armsModel[PLATFORM_MAX_PATH];
    GetClientCookie(client, g_Model, playerModel, sizeof(playerModel));
    GetClientCookie(client, g_ArmsModel, armsModel, sizeof(armsModel));
    if (!StrEqual(playerModel, "", true))SetEntityModel(client, playerModel);
    if (!StrEqual(armsModel, "", true))SetEntPropString(client, Prop_Send, "m_szArmsModel",armsModel , 0);
    SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
    ClientReset(client);
    PlayerSelfMute(true,client);
}

Action CountdownTimerStart(Handle timer, any data)
{
    if(pubg_status=='1'){
        if(tempTimer>0){
            for (int i = 1; i <= MaxClients; i++)if (IsValidClient(i) && !IsFakeClient(i))PrintHintText(i, "%t","PUB-G Countdown Timer Start", tempTimer);
            if(tempTimer==5){
                char message[512];
                Format(message,sizeof(message),"%t", "PUB-G Start Panel");
                SendPanelToAll(message);
            }
            tempTimer--;
            CreateTimer(1.0, CountdownTimerStart, _, TIMER_FLAG_NO_MAPCHANGE);
        }else{
            pubg_status='2';
            if (GetConVarInt(FindConVar("mp_teammates_are_enemies")) != 1)SetCvar("mp_teammates_are_enemies", 1);
            if (GetConVarInt(FindConVar("mp_friendlyfire")) != 1)SetCvar("mp_friendlyfire", 1);
            if (GetConVarInt(FindConVar("mp_respawn_on_death_t")) != 0)SetCvar("mp_respawn_on_death_t", 0);
            DropAndObstacleRandom();
            if(autoDrop)CreateTimer(GetConVarFloat(cv_pubg_droptime), RandomDrop, _, TIMER_FLAG_NO_MAPCHANGE);
            EmitSoundToAllAny("csgo-turkiye_com/pubg/pubg_game_start_2.mp3", -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
            for (new i=1; i<=MaxClients; i++)if (IsValidClient(i) && !IsFakeClient(i)){
                CreateTimer(0.0, DeleteOverlay, GetClientUserId(i));
                if(IsPlayerAlive(i) && GetClientTeam(i) == 2){
                    SetEntProp(i, Prop_Send, "m_iHideHUD", 1<<12 );
                    UnFreezePlayer(i);
                }
            }
            for (int i = 1; i <= MaxClients; i++)if (IsValidClient(i) && !IsFakeClient(i)){PrintHintText(i, "%t","PUB-G Started");clientTime[i]=-1;}
            GameControl();
        }
    }
    return Plugin_Continue;
}

Action CountdownTimerStop(Handle timer, any data)
{
    if(pubg_status=='2'){
        if(tempTimer>0){
            for (int i = 1; i <= MaxClients; i++)if (IsValidClient(i) && !IsFakeClient(i))PrintHintText(i, "%t","PUB-G Countdown Timer Stop", tempTimer, rallyingPoint);
            tempTimer--;
            CreateTimer(1.0, CountdownTimerStop, _, TIMER_FLAG_NO_MAPCHANGE);
        }else{
            GameStop(false);
        }
    }
    return Plugin_Continue;
}

void GameControl(){
    if(pubg_status!='0'){
        int teamCount = GetAliveTeamCount(2);
        if(teamCount==0){
            GameStop(true);
        }else if(teamCount==2 && team_status!='0'){
            int player = OnePlayer();
            if(player != -1){
                int playerTeam = clientTeam[player]; 
                if(playerTeam!=-1){
                    if(IsValidClient(playerTeam) && !IsFakeClient(playerTeam) && IsPlayerAlive(playerTeam) && GetClientTeam(playerTeam) == 2 && clientTeam[playerTeam]==player){
                        GameStop(true);
                        CPrintToChatAll("%t", "PUB-G Winner Team", pubg_tag,player,playerTeam);
                    }
                }
            }else{
                GameStop(true);
            }
        }else if(teamCount == 1){
            GameStop(true);
            int winner = OnePlayer();
            if(winner != -1)CPrintToChatAll("%t", "PUB-G Winner", pubg_tag,winner);
        }
    }
}

int OnePlayer(){
    for (new i=1; i<=MaxClients; i++)if (IsValidClient(i) && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)return i;
    return -1;
}

void AllSelfMute(bool status){
    for (int client = 1; client <= MaxClients; client++)
    {
        for (int target = 1; target <= MaxClients; target++)
		{
			if (IsValidClient(client) && IsValidClient(target))
			{
                if(status){
                    SetListenOverride(client, target, Listen_Default);
                }else{
                    if(warden_iswarden(target)){
                        SetListenOverride(client, target, Listen_Default);
                    }else{
                        SetListenOverride(client, target, Listen_No);
                    }
                }		
			}
		}
	}
}

void PlayerSelfMute(bool status, int client){
    for (int target = 1; target <= MaxClients; target++)
	{
		if (IsValidClient(target))
		{
            if(status){
                SetListenOverride(client, target, Listen_Default);
            }else{
                if(warden_iswarden(target)){
                    SetListenOverride(client, target, Listen_Default);
                }else{
                    SetListenOverride(client, target, Listen_No);
                }
            }		
		}
	}
}

void DeleteWeaponClient(int client){
	int j;
	while (j < 5)
	{
		int weapon = GetPlayerWeaponSlot(client, j);
		if (weapon != -1)
		{
			RemovePlayerItem(client, weapon);
			RemoveEdict(weapon);
		}
		j++;
	}
}

void DeletePubgItemsAndWeapons(){
	char targetName[64],className[64];
	for (int i = MaxClients; i < GetMaxEntities(); i++)
	{
		if (IsValidEdict(i) && IsValidEntity(i))
		{
            GetEntPropString(i, Prop_Data, "m_iName", targetName, sizeof(targetName));
            GetEdictClassname(i, className, sizeof(className));
            if (StrContains(targetName, "csgo-turkiye_com-pubg")==0 || ((StrContains(className, "weapon_") != -1 || StrContains(className, "item_") != -1) && GetEntDataEnt2(i, FindSendPropInfo("CBaseCombatWeapon", "m_hOwnerEntity")) == -1))RemoveEntity(i);
		}
	}
}

void FreezePlayer(int client)
{
    SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
    SetEntityRenderColor(client, 255, 0, 170, 174);
}

void UnFreezePlayer(int client)
{
    SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
    SetEntityRenderColor(client, 255, 255, 255, 255);
}
void ClientReset(int client){
    if(clientTeam[client]!=-1)if(clientTeam[clientTeam[client]] == client )clientTeam[clientTeam[client]] = -1;
    clientTeam[client]= -1;
    clientTime[client] = -1;
}

void SendPanelToAll(char [] message)
{
	Panel GamePanel = new Panel();
	GamePanel.DrawText(message);

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i) && !IsFakeClient(i))
		{
			GamePanel.Send(i, Handler_DoNothing, 4);
		}
	}
	delete GamePanel;
}

int Handler_DoNothing(Menu menu, MenuAction action, int param1, int param2)
{
	//CS-GO Turkiye | csgo-turkiye.com
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{
    if(pubg_status!='0'){
        int client = GetClientOfUserId(event.GetInt("userid"));
        if(IsValidClient(client) && !IsFakeClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2){
            Player_Start_Client(client);
            Player_PUBG(client);
            if(team_status!='0')PlayerSelfMute(false,client);
        }
    }
}

public void Event_RoundEndStart(Handle event, const char[] Name, bool dontbroadcast)
{
    if(pubg_status!='0')GameStop(true);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom) 
{
    if(IsValidClient(attacker) && !IsFakeClient(attacker) && IsValidClient(victim) && !IsFakeClient(victim) && pubg_status!='0'){
        if(pubg_status=='1'){
            PrintCenterText(attacker,"%t", "PUB-G Countdown Damage");
            return Plugin_Handled;
        }else{
            if(GetClientTeam(attacker) != 2 && GetClientTeam(victim) == 2){
                PrintCenterText(attacker,"%t", "PUB-G CT Damage");
                return Plugin_Handled;
            }else{
                if(team_status=='1'){
                    if(clientTeam[attacker]==victim && clientTeam[victim]==attacker){
                        PrintCenterText(attacker,"%t", "PUB-G Team Damage");
                        return Plugin_Handled;
                    }
                }
            }
        }
    }
    return Plugin_Continue;
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    if(pubg_status!='0'){
        int client = GetClientOfUserId(event.GetInt("userid"));
        if(IsValidClient(client) && !IsFakeClient(client))Player_PUBG_Stop(client, false)
    }
    GameControl();
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
    if(pubg_status=='2'){
        if(IsValidClient(client) && !IsFakeClient(client) && (warden_iswarden(client) || CheckAdminFlag(client)) && clientTime[client] >= GetTime()-15){
            clientTime[client] = -1;
            char timeAndPoint[128];
            Format(timeAndPoint, sizeof(timeAndPoint), "%s", sArgs);
            char timeAndPointArray[1][3];
            ExplodeString(timeAndPoint, " ", timeAndPointArray, sizeof(timeAndPointArray), sizeof(timeAndPointArray[]));
            int timeGet = StringToInt(timeAndPointArray[0]);
            if(timeGet >= 1 && timeGet<=999){
                tempTimer = timeGet;
                ReplaceString(timeAndPoint, sizeof(timeAndPoint), timeAndPointArray[0], "");
                Format(rallyingPoint, sizeof(rallyingPoint), "%s", timeAndPoint);
            }else{
                CPrintToChat(client, "%t", "PUB-G Freeze Time Error", pubg_tag);
            }
            PUBG_Freeze_Menu().Display(client, MENU_TIME_FOREVER);
        }
    }
}