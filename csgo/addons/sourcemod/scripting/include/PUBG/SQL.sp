int OnSQLConnect(Handle owner, Handle handle, char[] error, any data)
{
    if (handle == INVALID_HANDLE)
    {
        CPrintToChatAll("%t", "PUB-G Database Connect Error", pubg_tag);
        ErrorLog("PUB-G Database Connect Log Error", error);
        SetFailState("Database connection failed.");
    }
    else
    {
        PrintToServer("%t", "PUB-G Database Connect Success");
        g_hDB = handle;
        char g_sSQLBuffer[3096];
        SQL_GetDriverIdent(SQL_ReadDriver(g_hDB), g_sSQLBuffer, sizeof(g_sSQLBuffer));
        //Type 0: Client - Type 1: Drop
        Format(g_sSQLBuffer, sizeof(g_sSQLBuffer), "CREATE TABLE IF NOT EXISTS `pubg_coordinates` (`map_name` varchar(128) NOT NULL, `type` BOOLEAN NOT NULL, `x` FLOAT DEFAULT 0.0 NOT NULL, `y` FLOAT DEFAULT 0.0 NOT NULL, `z` FLOAT DEFAULT 0.0 NOT NULL)");
        SQL_TQuery(g_hDB, SqlCallback, g_sSQLBuffer);
    }
}

int SqlCallback(Handle owner, Handle handle, char[] error, any data)
{
    if (handle == INVALID_HANDLE)
    {
        ErrorLog("PUB-G Query Error Log", error);
        return;
    }
}

bool SQLQueryNoData(char[] query)
{
    if (!SQL_FastQuery(g_hDB, query))
    {
        char error[255];
        SQL_GetError(g_hDB, error, sizeof(error));
        ErrorLog("PUB-G Query Error Log", error);
        return false;
    }
    return true;
}

int CountData(char[] query)
{
    int count = -1;
    DBResultSet DBRS_Query = SQL_Query(g_hDB, query);
    if (DBRS_Query == INVALID_HANDLE || DBRS_Query == null)
    {
        char error[255];
        SQL_GetError(g_hDB, error, sizeof(error));
        ErrorLog("PUB-G Query Error Log", error);
    }
    if (!SQL_FetchRow(DBRS_Query))
    {
        count = 0;
    }
    else
    {
        count = SQL_FetchInt(DBRS_Query, 0);
    }
    delete DBRS_Query;
    return count;
}

void SettingModelLoad()
{
    DeleteSettingModel();
    char query[512];
    Format(query, sizeof(query), "SELECT `type`,`x`,`y`,`z` FROM `pubg_coordinates` WHERE `map_name`='%s'", mapName);
    DBResultSet DBRS_Query = SQL_Query(g_hDB, query);
    if (DBRS_Query == INVALID_HANDLE || DBRS_Query == null)
    {
        char error[255];
        SQL_GetError(g_hDB, error, sizeof(error));
        ErrorLog("PUB-G Query Error Log", error);
    }
    else
    {
        if (SQL_HasResultSet(DBRS_Query))
        {
            while (SQL_FetchRow(DBRS_Query))
            {
                char modelPath[128];
                if (SQL_FetchInt(DBRS_Query, 0) == 0)
                {
                    Format(modelPath, sizeof(modelPath), "models/csgo-turkiye_com/plugin/pubg/pubg_birincil_icon.mdl");
                }
                else
                {
                    Format(modelPath, sizeof(modelPath), "models/csgo-turkiye_com/plugin/pubg/pubg_ikincil_icon.mdl");
                }
                int new_entity = CreateEntityByName("prop_door_rotating");
                if (IsValidEntity(new_entity))
                {
                    float pos[3];
                    pos[0] = SQL_FetchFloat(DBRS_Query, 1);
                    pos[1] = SQL_FetchFloat(DBRS_Query, 2);
                    pos[2] = SQL_FetchFloat(DBRS_Query, 3) + 15.0;
                    DispatchKeyValue(new_entity, "model", modelPath);
                    DispatchKeyValue(new_entity, "targetname", "csgo-turkiye_com-pubg");
                    SetEntPropFloat(new_entity, Prop_Send, "m_flModelScale", 0.80);
                    DispatchSpawn(new_entity);
                    TeleportEntity(new_entity, pos, NULL_VECTOR, NULL_VECTOR);
                }
            }
        }
    }
    delete DBRS_Query;
}

void SelectMenuAddItem(Menu menu, char[] query)
{
    char temp[128];
    DBResultSet DBRS_Query = SQL_Query(g_hDB, query);
    if (DBRS_Query == INVALID_HANDLE || DBRS_Query == null)
    {
        char error[255];
        SQL_GetError(g_hDB, error, sizeof(error));
        ErrorLog("PUB-G Query Error Log", error);
    }
    else
    {
        if (SQL_HasResultSet(DBRS_Query))
        {
            while (SQL_FetchRow(DBRS_Query))
            {
                SQL_FetchString(DBRS_Query, 0, temp, sizeof(temp));
                menu.AddItem(temp, temp);
            }
        }
    }
    delete DBRS_Query;
}

void Player_Start(){
    char query[512];
    Format(query, sizeof(query), "SELECT `x`,`y`,`z` FROM `pubg_coordinates` WHERE `map_name`='%s' and `type` = %d ORDER BY RANDOM() LIMIT %d", mapName,false,GetMaxHumanPlayers());
    DBResultSet DBRS_Query = SQL_Query(g_hDB, query);
    if (DBRS_Query == INVALID_HANDLE || DBRS_Query == null)
    {
        char error[255];
        SQL_GetError(g_hDB, error, sizeof(error));
        ErrorLog("PUB-G Query Error Log", error);
    }
    else
    {
        if (SQL_HasResultSet(DBRS_Query))
        {
            float pos[3];
            for (new i=1; i<=MaxClients; i++)if (IsValidClient(i) && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2){
                if(!SQL_FetchRow(DBRS_Query))SQL_Rewind(DBRS_Query);
                pos[0] = SQL_FetchFloat(DBRS_Query, 0);
                pos[1] = SQL_FetchFloat(DBRS_Query, 1);
                pos[2] = SQL_FetchFloat(DBRS_Query, 2)+10.0;
                TeleportEntity(i, pos, NULL_VECTOR, NULL_VECTOR);
                Player_PUBG(i);
            }
        }
    }
    delete DBRS_Query;
}

void Player_Start_Client(int client){
    char query[512];
    Format(query, sizeof(query), "SELECT `x`,`y`,`z` FROM `pubg_coordinates` WHERE `map_name`='%s' and `type` = %d ORDER BY RANDOM() LIMIT 1", mapName,false);
    DBResultSet DBRS_Query = SQL_Query(g_hDB, query);
    if (DBRS_Query == INVALID_HANDLE || DBRS_Query == null)
    {
        char error[255];
        SQL_GetError(g_hDB, error, sizeof(error));
        ErrorLog("PUB-G Query Error Log", error);
    }
    else
    {
        if (SQL_HasResultSet(DBRS_Query) && SQL_FetchRow(DBRS_Query))
        {
            float pos[3];
            pos[0] = SQL_FetchFloat(DBRS_Query, 0);
            pos[1] = SQL_FetchFloat(DBRS_Query, 1);
            pos[2] = SQL_FetchFloat(DBRS_Query, 2)+10.0;
            TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
        }
    }
    delete DBRS_Query;
}

void DropAndObstacleRandom(){
    char query[512];
    Format(query, sizeof(query), "SELECT `x`,`y`,`z` FROM `pubg_coordinates` WHERE `map_name`='%s' and `type` = %d ORDER BY RANDOM() LIMIT %d", mapName,true,GetAliveTeamCount(2)*3);
    DBResultSet DBRS_Query = SQL_Query(g_hDB, query);
    if (DBRS_Query == INVALID_HANDLE || DBRS_Query == null)
    {
        char error[255];
        SQL_GetError(g_hDB, error, sizeof(error));
        ErrorLog("PUB-G Query Error Log", error);
    }
    else
    {
        if (SQL_HasResultSet(DBRS_Query))
        {
            float pos[3];
            while (SQL_FetchRow(DBRS_Query))
            {
                pos[0] = SQL_FetchFloat(DBRS_Query, 0);
                pos[1] = SQL_FetchFloat(DBRS_Query, 1);
                pos[2] = SQL_FetchFloat(DBRS_Query, 2);
                if(autoObstacle && GetRandomInt(0, 10)>8){
                    SpawnDroneGun(pos);
                }else{
                    int entityDrop = SpawnDrop(false,pos);
                    if (IsValidEntity(entityDrop))
                    {
                        if (!IsValidEntity(SpawnButton(pos, entityDrop)))RemoveEntity(entityDrop);
                    }
                }
            }
        }
    }
    delete DBRS_Query;
}

public Action RandomDrop(Handle timer, any data)
{
    if(pubg_status=='2' && autoDrop){
        char query[512];
        Format(query, sizeof(query), "SELECT `x`,`y`,`z` FROM `pubg_coordinates` WHERE `map_name`='%s' and `type` = %d ORDER BY RANDOM() LIMIT 1", mapName,true);
        DBResultSet DBRS_Query = SQL_Query(g_hDB, query);
        if (DBRS_Query == INVALID_HANDLE || DBRS_Query == null)
        {
            char error[255];
            SQL_GetError(g_hDB, error, sizeof(error));
            ErrorLog("PUB-G Query Error Log", error);
        }
        else
        {
            if (SQL_HasResultSet(DBRS_Query) && SQL_FetchRow(DBRS_Query))
            {
                float pos[3];
                pos[0] = SQL_FetchFloat(DBRS_Query, 0);
                pos[1] = SQL_FetchFloat(DBRS_Query, 1);
                pos[2] = SQL_FetchFloat(DBRS_Query, 2);
                CreateDrop(0,pos);
            }
        }
        delete DBRS_Query;
        CreateTimer(GetConVarFloat(cv_pubg_droptime), RandomDrop, _, TIMER_FLAG_NO_MAPCHANGE);
    }
}