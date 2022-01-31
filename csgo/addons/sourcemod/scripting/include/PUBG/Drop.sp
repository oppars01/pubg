void CreateDrop(int client, float dropPos[3])
{
    float pos[3];
    pos[0] = dropPos[0];
    pos[1] = dropPos[1];
    pos[2] = dropPos[2] + 3000.0;
    while (TR_PointOutsideWorld(pos))
        pos[2] -= 5.0;
    pos[0] -= 3000.0;
    while (TR_PointOutsideWorld(pos))
        pos[0] += 5.0;
    int entityDrone = SpawnDrone(pos);
    if (IsValidEntity(entityDrone))
    {
        int entityDrop = SpawnDrop(true,pos);
        if (IsValidEntity(entityDrop))
        {
            if(client!=0)CPrintToChatAll("%t", "PUB-G Drop Info", pubg_tag, client);
            ArrayList DataArray = new ArrayList(7);
            DataArray.Push(dropPos[0]);
            DataArray.Push(dropPos[1]);
            DataArray.Push(dropPos[2]);
            DataArray.Push(pos[2]);
            DataArray.Push(entityDrone);
            DataArray.Push(entityDrop);
            DataArray.Push(-1);
            RequestFrame(MotionEntity, DataArray);
        }
        else
        {
            RemoveEntity(entityDrone);
            if(client!=0)CPrintToChat(client, "%t", "PUB-G Drop Error", pubg_tag);
        }
    }
    else
    {
        if(client!=0)CPrintToChat(client, "%t", "PUB-G Drop Error", pubg_tag);
    }
}

void MotionEntity(ArrayList DataArray)
{
    
    float dropPos[3], temp[3], posZ;
    int entityDrone, entityDrop, entityParac;
    char className[64], modelName[256], targetName[64];
    dropPos[0] = view_as<float>(DataArray.Get(0));
    dropPos[1] = view_as<float>(DataArray.Get(1));
    dropPos[2] = view_as<float>(DataArray.Get(2));
    posZ = view_as<float>(DataArray.Get(3));
    entityDrone = DataArray.Get(4);
    entityDrop = DataArray.Get(5);
    entityParac = DataArray.Get(6);
    if (entityDrone != -1)
    {
        if (IsValidEntity(entityDrone) && IsValidEdict(entityDrone))
        {
            GetEdictClassname(entityDrone, className, sizeof(className));
            GetEntPropString(entityDrone, Prop_Data, "m_ModelName", modelName, sizeof(modelName));
            GetEntPropString(entityDrone, Prop_Data, "m_iName", targetName, sizeof(targetName));
            if (StrEqual(className, "drone") && StrEqual(modelName, "models/props_survival/drone/br_drone.mdl") && StrEqual(targetName, "csgo-turkiye_com-pubgdropdrone") && GetEntPropEnt(entityDrone, Prop_Send, "m_hOwnerEntity") == -1)
            {
                GetEntPropVector(entityDrone, Prop_Send, "m_vecOrigin", temp);
                temp[0] += 5.0;
                if (!TR_PointOutsideWorld(temp) && temp[0] < dropPos[0] + 3000)
                {
                    TeleportEntity(entityDrone, temp, NULL_VECTOR, NULL_VECTOR);
                }
                else
                {
                    RemoveEntity(entityDrone);
                    entityDrone = -1;
                }
            }
            else
            {
                RemoveDrop(entityDrone, entityDrop, entityParac);
                entityDrone = -1;
                entityDrop = -1;
                entityParac = -1;
            }
        }
        else
        {
            RemoveDrop(entityDrone, entityDrop, entityParac);
            entityDrone = -1;
            entityDrop = -1;
            entityParac = -1;
        }
    }

    if (entityDrop != -1)
    {
        if (IsValidEntity(entityDrop) && IsValidEdict(entityDrop))
        {
            GetEdictClassname(entityDrop, className, sizeof(className));
            GetEntPropString(entityDrop, Prop_Data, "m_ModelName", modelName, sizeof(modelName));
            GetEntPropString(entityDrop, Prop_Data, "m_iName", targetName, sizeof(targetName));
            if (StrEqual(className, "prop_dynamic") && StrEqual(modelName, "models/props/crates/csgo_drop_crate_armsdeal1.mdl") && StrEqual(targetName, "csgo-turkiye_com-pubgdropcase") && GetEntPropEnt(entityDrop, Prop_Send, "m_hOwnerEntity") == -1)
            {
                SpawnBeam(dropPos);
                GetEntPropVector(entityDrop, Prop_Send, "m_vecOrigin", temp);
                if (temp[0] >= dropPos[0])
                {
                    if (posZ == temp[2])
                    {
                        temp[0] = dropPos[0];
                        temp[1] = dropPos[1];
                        temp[2] -= 5.0;
                        if (!TR_PointOutsideWorld(temp))
                        {
                            TeleportEntity(entityDrop, temp, NULL_VECTOR, NULL_VECTOR);
                            entityParac = SpawnParac(temp);
                            if (!IsValidEntity(entityParac))
                            {
                                entityParac = -1;
                            }
                        }
                        else
                        {
                            RemoveDrop(entityDrone, entityDrop, entityParac);
                            entityDrone = -1;
                            entityDrop = -1;
                            entityParac = -1;
                        }
                    }
                    else
                    {
                        temp[2] -= 2.0;
                        if (temp[2] <= dropPos[2])
                        {
                            dropPos[2] -= 10.0;
                            TeleportEntity(entityDrop, dropPos, NULL_VECTOR, NULL_VECTOR);
                            int entityButton = SpawnButton(dropPos, entityDrop);
                            if (!IsValidEntity(entityButton))
                            {
                                RemoveDrop(entityDrone, entityDrop, entityParac);
                                entityDrone = -1;
                                entityParac = -1;
                                CPrintToChatAll("%t", "PUB-G Drop Error", pubg_tag);
                            }
                            entityDrop = -1;
                            if (entityParac != -1)
                            {
                                if (IsValidEntity(entityParac))
                                {
                                    RemoveEntity(entityParac);
                                }
                                entityParac = -1;
                            }
                        }
                        else if (!TR_PointOutsideWorld(temp))
                        {
                            TeleportEntity(entityDrop, temp, NULL_VECTOR, NULL_VECTOR);
                            if (entityParac != -1)
                            {
                                if (IsValidEntity(entityParac) && IsValidEdict(entityParac))
                                {
                                    GetEdictClassname(entityParac, className, sizeof(className));
                                    GetEntPropString(entityParac, Prop_Data, "m_ModelName", modelName, sizeof(modelName));
                                    GetEntPropString(entityParac, Prop_Data, "m_iName", targetName, sizeof(targetName));
                                    if (StrEqual(className, "prop_dynamic") && StrEqual(modelName, "models/csgo-turkiye_com/plugin/pubg/parachute.mdl") && StrEqual(targetName, "csgo-turkiye_com-pubgdropparac") && GetEntPropEnt(entityParac, Prop_Send, "m_hOwnerEntity") == -1)
                                    {
                                        temp[0] += 5.0;
                                        temp[2] -= 40.0;
                                        if (!TR_PointOutsideWorld(temp))
                                        {
                                            TeleportEntity(entityParac, temp, NULL_VECTOR, NULL_VECTOR);
                                        }
                                        else
                                        {
                                            RemoveEntity(entityParac);
                                            entityParac = -1;
                                        }
                                    }
                                    else
                                    {
                                        RemoveDrop(entityDrone, entityDrop, entityParac);
                                        entityDrone = -1;
                                        entityDrop = -1;
                                        entityParac = -1;
                                    }
                                }
                                else
                                {
                                    RemoveDrop(entityDrone, entityDrop, entityParac);
                                    entityDrone = -1;
                                    entityDrop = -1;
                                    entityParac = -1;
                                }
                            }
                            else
                            {
                                entityParac = SpawnParac(temp);
                                if (!IsValidEntity(entityParac))
                                {
                                    entityParac = -1;
                                }
                            }
                        }
                        else
                        {
                            RemoveDrop(entityDrone, entityDrop, entityParac);
                            entityDrone = -1;
                            entityDrop = -1;
                            entityParac = -1;
                        }
                    }
                }
                else
                {
                    temp[0] += 5.0;
                    if (!TR_PointOutsideWorld(temp))
                    {
                        TeleportEntity(entityDrop, temp, NULL_VECTOR, NULL_VECTOR);
                    }
                    else
                    {
                        RemoveDrop(entityDrone, entityDrop, entityParac);
                        entityDrone = -1;
                        entityDrop = -1;
                        entityParac = -1;
                    }
                }
            }
            else
            {
                RemoveDrop(entityDrone, entityDrop, entityParac);
                entityDrone = -1;
                entityDrop = -1;
                entityParac = -1;
            }
        }
        else
        {
            RemoveDrop(entityDrone, entityDrop, entityParac);
            entityDrone = -1;
            entityDrop = -1;
            entityParac = -1;
        }
    }
    DataArray.Set(3, posZ);
    DataArray.Set(4, entityDrone);
    DataArray.Set(5, entityDrop);
    DataArray.Set(6, entityParac);
    if (entityDrone != -1 || entityDrop != -1 || entityParac != -1)
    {
        RequestFrame(MotionEntity, DataArray);
    }
}

void RemoveDrop(int entityDrone, int entityDrop, int entityParac)
{
    char className[64], modelName[256], targetName[64];
    if (entityDrone != -1)
    {
        if (IsValidEntity(entityDrone) && IsValidEdict(entityDrone))
        {
            GetEdictClassname(entityDrone, className, sizeof(className));
            GetEntPropString(entityDrone, Prop_Data, "m_ModelName", modelName, sizeof(modelName));
            GetEntPropString(entityDrone, Prop_Data, "m_iName", targetName, sizeof(targetName));
            if (StrEqual(className, "drone") && StrEqual(modelName, "models/props_survival/drone/br_drone.mdl") && StrEqual(targetName, "csgo-turkiye_com-pubgdropdrone") && GetEntPropEnt(entityDrone, Prop_Send, "m_hOwnerEntity") == -1)
            {
                RemoveEntity(entityDrone);
            }
        }
    }
    if (entityParac != -1)
    {
        if (IsValidEntity(entityParac) && IsValidEdict(entityParac))
        {
            GetEdictClassname(entityParac, className, sizeof(className));
            GetEntPropString(entityParac, Prop_Data, "m_ModelName", modelName, sizeof(modelName));
            GetEntPropString(entityParac, Prop_Data, "m_iName", targetName, sizeof(targetName));
            if (StrEqual(className, "prop_dynamic") && StrEqual(modelName, "models/csgo-turkiye_com/plugin/pubg/parachute.mdl") && StrEqual(targetName, "csgo-turkiye_com-pubgdropparac") && GetEntPropEnt(entityParac, Prop_Send, "m_hOwnerEntity") == -1)
            {
                RemoveEntity(entityParac);
            }
        }
    }
    if (entityDrop != -1)
    {
        if (IsValidEntity(entityDrop) && IsValidEdict(entityDrop))
        {
            GetEdictClassname(entityDrop, className, sizeof(className));
            GetEntPropString(entityDrop, Prop_Data, "m_ModelName", modelName, sizeof(modelName));
            GetEntPropString(entityDrop, Prop_Data, "m_iName", targetName, sizeof(targetName));
            if (StrEqual(className, "prop_dynamic") && StrEqual(modelName, "models/props/crates/csgo_drop_crate_armsdeal1.mdl") && StrEqual(targetName, "csgo-turkiye_com-pubgdropcase") && GetEntPropEnt(entityDrop, Prop_Send, "m_hOwnerEntity") == -1)
            {
                RemoveEntity(entityDrop);
            }
        }
    }
}

int SpawnDrone(float pos[3])
{
    int entity = CreateEntityByName("drone");
    if (entity == -1)
        return -1;
    DispatchKeyValue(entity, "targetname", "csgo-turkiye_com-pubgdropdrone");
    ActivateEntity(entity);
    DispatchSpawn(entity);
    TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
    SetEntProp(entity, Prop_Send, "m_nSolidType", 0);
    SetEntityMoveType(entity, MOVETYPE_NONE);
    SetEntProp(entity, Prop_Data, "m_takedamage", 0, 1);
    return entity;
}

int SpawnDrop(bool type,float pos[3])
{
    if(type)pos[2] -= 36.0;
    if (TR_PointOutsideWorld(pos))
        return -1;
    int entity = CreateEntityByName("prop_dynamic");
    if (entity == -1)
        return -1;
    SetEntityModel(entity, "models/props/crates/csgo_drop_crate_armsdeal1.mdl");
    DispatchKeyValue(entity, "targetname", "csgo-turkiye_com-pubgdropcase");
    ActivateEntity(entity);
    DispatchSpawn(entity);
    TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
    return entity;
}

int SpawnParac(float pos[3])
{
    pos[0] += 5.0;
    pos[2] -= 40.0;
    if (TR_PointOutsideWorld(pos))
        return -1;
    int entity = CreateEntityByName("prop_dynamic");
    if (entity == -1)
        return -1;
    SetEntityModel(entity, "models/csgo-turkiye_com/plugin/pubg/parachute.mdl");
    TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
    DispatchKeyValue(entity, "targetname", "csgo-turkiye_com-pubgdropparac");
    return entity;
}

int SpawnButton(float pos[3], int entityDrop)
{
    char targetName[64];
    Format(targetName, sizeof(targetName), "csgo-turkiye_com-pubgdropbutton%d", entityDrop);
    int entity = CreateEntityByName("func_button");
    if (entity == -1)
        return -1;
    DispatchKeyValue(entity, "spawnflags", "1025");
    DispatchKeyValue(entity, "wait", "-1");
    DispatchKeyValue(entity, "targetname", targetName);
    DispatchSpawn(entity);
    ActivateEntity(entity);
    float vecMins[3] = {-30.0, -30.0, -30.0};
    float vecMaxs[3] = {30.0, 30.0, 30.0};
    SetEntPropVector(entity, Prop_Send, "m_vecMins", vecMins);
    SetEntPropVector(entity, Prop_Send, "m_vecMaxs", vecMaxs);
    SetEntityMoveType(entity, MOVETYPE_NONE);
    TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
    HookSingleEntityOutput(entity, "OnPressed", OnPressedDrop);
    return entity;
}

int SpawnDroneGun(float pos[3])
{
    int entity = CreateEntityByName("dronegun");
    if (entity == -1)
        return -1;
    DispatchKeyValue(entity, "targetname", "csgo-turkiye_com-pubgdropdronegun");
    ActivateEntity(entity);
    DispatchSpawn(entity);
    TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
    return entity;
}

void SpawnBeam(float pos[3])
{
    for (int i = 1; i <= MaxClients; i++)
        if (IsValidClient(i) && IsPlayerAlive(i))
        {
            float clientPos[3];
            GetClientAbsOrigin(i, clientPos);
            float distance = GetVectorDistance(clientPos, pos);
            if (distance < 80.0)
            {
                PrintCenterText(i, "%t", "PUB-G Zones Info", pubg_tag);
                KnockbackSetVelocity(i, pos, clientPos, 300.0);
            }
        }
    pos[2] += 10;
    TE_SetupBeamRingPoint(pos, 100.0, 100.1, beamSprite, haloSprite, 0, 30, 0.2, 1.0, 1.0, {255, 255, 255, 100}, 1, 0);
    TE_SendToAll();
}

void KnockbackSetVelocity(int client, const float startpoint[3], const float endpoint[3], float magnitude)
{
    float vector[3];
    MakeVectorFromPoints(startpoint, endpoint, vector);
    NormalizeVector(vector, vector);
    ScaleVector(vector, magnitude);
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vector);
}

void OnPressedDrop(const char[] output, int caller, int activator, float delay)
{
    bool wrong=true;
    if (activator != 0)
    {
        if (IsClientConnected(activator) && IsValidClient(activator) && !IsFakeClient(activator) && IsPlayerAlive(activator) && GetClientTeam(activator)==2)
        {
            if (caller != -1)
            {
                if (IsValidEntity(caller) && IsValidEdict(caller))
                {
                    char className[64], modelName[256], targetName[64];
                    GetEdictClassname(caller, className, sizeof(className));
                    GetEntPropString(caller, Prop_Data, "m_iName", targetName, sizeof(targetName));
                    if (StrEqual(className, "func_button") && StrContains(targetName, "csgo-turkiye_com-pubgdropbutton")==0 && GetEntPropEnt(caller, Prop_Send, "m_hOwnerEntity") == -1){
                        ReplaceString(targetName, sizeof(targetName), "csgo-turkiye_com-pubgdropbutton", "");
                        int entityDrop = StringToInt(targetName);
                        if (entityDrop > 0)
                        {
                            if (IsValidEntity(entityDrop) && IsValidEdict(entityDrop))
                            {
                                GetEdictClassname(entityDrop, className, sizeof(className));
                                GetEntPropString(entityDrop, Prop_Data, "m_ModelName", modelName, sizeof(modelName));
                                GetEntPropString(entityDrop, Prop_Data, "m_iName", targetName, sizeof(targetName));
                                if (StrEqual(className, "prop_dynamic") && StrEqual(modelName, "models/props/crates/csgo_drop_crate_armsdeal1.mdl") && StrEqual(targetName, "csgo-turkiye_com-pubgdropcase") && GetEntPropEnt(entityDrop, Prop_Send, "m_hOwnerEntity") == -1)
                                {
                                    if(pubg_status!='0' && pubg_status!='1'){
                                        SetVariantString("open");
                                        AcceptEntityInput(entityDrop, "SetAnimation");
                                        AcceptEntityInput(entityDrop, "Enable");
                                        ArrayList DataArray = new ArrayList(2);
                                        DataArray.Push(activator);
                                        DataArray.Push(entityDrop);
                                        CreateTimer(2.0, CaseOpen, DataArray);
                                        RemoveEntity(caller);
                                        wrong = false;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    if(wrong)WrongPressedDrop(caller);
}

void WrongPressedDrop(int caller)
{
    if (caller != -1)
    {
        if (IsValidEntity(caller) && IsValidEdict(caller))
        {
            char className[64], modelName[256], targetName[64];
            GetEdictClassname(caller, className, sizeof(className));
            GetEntPropString(caller, Prop_Data, "m_iName", targetName, sizeof(targetName));
            if (StrEqual(className, "func_button") && StrContains(targetName, "csgo-turkiye_com-pubgdropbutton") == 0 && GetEntPropEnt(caller, Prop_Send, "m_hOwnerEntity") == -1)
            {
                ReplaceString(targetName, sizeof(targetName), "csgo-turkiye_com-pubgdropbutton", "");
                int entityDrop = StringToInt(targetName);
                if (entityDrop > 0)
                {
                    if (IsValidEntity(entityDrop) && IsValidEdict(entityDrop))
                    {
                        GetEdictClassname(entityDrop, className, sizeof(className));
                        GetEntPropString(entityDrop, Prop_Data, "m_ModelName", modelName, sizeof(modelName));
                        GetEntPropString(entityDrop, Prop_Data, "m_iName", targetName, sizeof(targetName));
                        if (StrEqual(className, "prop_dynamic") && StrEqual(modelName, "models/props/crates/csgo_drop_crate_armsdeal1.mdl") && StrEqual(targetName, "csgo-turkiye_com-pubgdropcase") && GetEntPropEnt(entityDrop, Prop_Send, "m_hOwnerEntity") == -1)
                        {
                            RemoveEntity(entityDrop);
                            RemoveEntity(caller);
                        }
                    }
                }
            }
        }
    }
}

Action CaseOpen(Handle timer, ArrayList DataArray)
{
    int entityDrop = DataArray.Get(1);
    if (entityDrop > 0)
    {
        if (IsValidEntity(entityDrop) && IsValidEdict(entityDrop))
        {

            char className[64], modelName[256], targetName[64];
            GetEdictClassname(entityDrop, className, sizeof(className));
            GetEntPropString(entityDrop, Prop_Data, "m_ModelName", modelName, sizeof(modelName));
            GetEntPropString(entityDrop, Prop_Data, "m_iName", targetName, sizeof(targetName));
            if (StrEqual(className, "prop_dynamic") && StrEqual(modelName, "models/props/crates/csgo_drop_crate_armsdeal1.mdl") && StrEqual(targetName, "csgo-turkiye_com-pubgdropcase") && GetEntPropEnt(entityDrop, Prop_Send, "m_hOwnerEntity") == -1)
            {
                float pos[3];
                GetEntPropVector(entityDrop, Prop_Send, "m_vecOrigin", pos);
                RemoveEntity(entityDrop);
                SpawnWeapon(DataArray.Get(0),pos);
            }
        }
    }
}

void SpawnWeapon(int client, float pos[3] )
{
    if (client != 0)
    {
        if (IsClientConnected(client) && IsValidClient(client) && !IsFakeClient(client) && IsPlayerAlive(client) && GetClientTeam(client)==2)
        {
            int count = 0;
            int active_weapons[sizeof(weapons)];
            for(int i =0;i<sizeof(weapons);i++){
                if(weaponStatus[i]){
                    active_weapons[count] = i;
                    count++;
                }
            }
            int random = GetRandomInt(0, count-1);
            int ent = CreateEntityByName(weapons[random]);
            if (!IsValidEntity(ent) || !DispatchSpawn(ent))
            {
                CPrintToChat(client,"%t","PUB-G Weapon Spawn Error",pubg_tag)
            }else{
                float rot[3] = { 0.0, 0.0, 90.0 };
                TeleportEntity(ent, pos, rot , NULL_VECTOR);
                DispatchKeyValue(ent, "targetname", "csgo-turkiye_com-pubgdropweapon");
                EmitSoundToClientAny(client,"csgo-turkiye_com/pubg/pubg_weapon_pickup.mp3");
                char weapon_name[64];
                Format(weapon_name, sizeof(weapon_name), "%t", weapons[random]);
                CPrintToChatAll("%t","PUB-G Weapon Spawn",pubg_tag,client,weapon_name)
            }
        }
    }   
}

void ResetWeaponStatus(){
    for(int i=0;i<sizeof(weaponStatus);i++)weaponStatus[i]=true;
}