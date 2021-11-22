int beamSprite, haloSprite;

public void Download()
{
    PrecacheDecalAnyDownload("models/csgo-turkiye_com/plugin/pubg/pubg-loading");

    AddFileToDownloadsTable("models/csgo-turkiye_com/plugin/pubg/pubg_birincil_icon.dx90.vtx");
    AddFileToDownloadsTable("models/csgo-turkiye_com/plugin/pubg/pubg_birincil_icon.mdl");
    AddFileToDownloadsTable("models/csgo-turkiye_com/plugin/pubg/pubg_birincil_icon.phy");
    AddFileToDownloadsTable("models/csgo-turkiye_com/plugin/pubg/pubg_birincil_icon.vvd");
    AddFileToDownloadsTable("materials/models/csgo-turkiye_com/plugin/pubg/pubg_birincil.vmt");
    AddFileToDownloadsTable("materials/models/csgo-turkiye_com/plugin/pubg/pubg_birincil.vtf");
    PrecacheModel("models/csgo-turkiye_com/plugin/pubg/pubg_birincil_icon.mdl");

    AddFileToDownloadsTable("models/csgo-turkiye_com/plugin/pubg/pubg_ikincil_icon.dx90.vtx");
    AddFileToDownloadsTable("models/csgo-turkiye_com/plugin/pubg/pubg_ikincil_icon.mdl");
    AddFileToDownloadsTable("models/csgo-turkiye_com/plugin/pubg/pubg_ikincil_icon.phy");
    AddFileToDownloadsTable("models/csgo-turkiye_com/plugin/pubg/pubg_ikincil_icon.vvd");
    AddFileToDownloadsTable("materials/models/csgo-turkiye_com/plugin/pubg/icon/pubg_ikincil.vmt");
    AddFileToDownloadsTable("materials/models/csgo-turkiye_com/plugin/pubg/icon/pubg_ikincil.vtf");
    PrecacheModel("models/csgo-turkiye_com/plugin/pubg/pubg_ikincil_icon.mdl");

    AddFileToDownloadsTable("models/csgo-turkiye_com/plugin/pubg/parachute.dx90.vtx");
    AddFileToDownloadsTable("models/csgo-turkiye_com/plugin/pubg/parachute.mdl");
    AddFileToDownloadsTable("models/csgo-turkiye_com/plugin/pubg/parachute.vvd");
    AddFileToDownloadsTable("materials/models/csgo-turkiye_com/plugin/pubg/pack_carbon.vmt");
    AddFileToDownloadsTable("materials/models/csgo-turkiye_com/plugin/pubg/pack_carbon.vtf");
    AddFileToDownloadsTable("materials/models/csgo-turkiye_com/plugin/pubg/parachute_c.vmt");
    AddFileToDownloadsTable("materials/models/csgo-turkiye_com/plugin/pubg/parachute_c.vtf");
    PrecacheModel("models/csgo-turkiye_com/plugin/pubg/parachute.mdl");

    PrecacheModel("models/props_survival/drone/br_drone.mdl");
    PrecacheModel("models/props_survival/drone/drone_gib1.mdl");
    PrecacheModel("models/props_survival/drone/drone_gib2.mdl");
    PrecacheModel("models/props_survival/drone/drone_gib3.mdl");
    PrecacheModel("models/props_survival/drone/drone_gib4.mdl");
    PrecacheModel("models/props_survival/drone/drone_gib5.mdl");
    PrecacheSound("#/vehicles/drone_loop_03.wav", true);
    PrecacheSound("#/vehicles/drone_loop_02.wav", true);

    PrecacheModel("models/props_survival/dronegun/dronegun_gib1.mdl", true);
    PrecacheModel("models/props_survival/dronegun/dronegun_gib2.mdl", true);
    PrecacheModel("models/props_survival/dronegun/dronegun_gib3.mdl", true);
    PrecacheModel("models/props_survival/dronegun/dronegun_gib4.mdl", true);
    PrecacheModel("models/props_survival/dronegun/dronegun_gib5.mdl", true);
    PrecacheModel("models/props_survival/dronegun/dronegun_gib6.mdl", true);
    PrecacheModel("models/props_survival/dronegun/dronegun_gib7.mdl", true);
    PrecacheModel("models/props_survival/dronegun/dronegun_gib8.mdl", true);
    
    PrecacheSound("sound/survival/turret_death_01.wav", true);
    PrecacheSound("sound/survival/turret_idle_01.wav", true);
    
    PrecacheSound("sound/survival/turret_takesdamage_01.wav", true);
    PrecacheSound("sound/survival/turret_takesdamage_02.wav", true);
    PrecacheSound("sound/survival/turret_takesdamage_03.wav", true);
    
    PrecacheSound("sound/survival/turret_lostplayer_01.wav", true);
    PrecacheSound("sound/survival/turret_lostplayer_02.wav", true);
    PrecacheSound("sound/survival/turret_lostplayer_03.wav", true);
    
    PrecacheSound("sound/survival/turret_sawplayer_01.wav", true);

    PrecacheModel("models/props/crates/csgo_drop_crate_armsdeal1.mdl");
    
    PrecacheModel("models/player/custom_player/legacy/tm_jumpsuit_varianta.mdl", false);
    PrecacheModel("models/player/custom_player/legacy/tm_jumpsuit_variantb.mdl", false);
    PrecacheModel("models/player/custom_player/legacy/tm_jumpsuit_variantc.mdl", false);
    PrecacheModel("models/weapons/t_arms_phoenix.mdl", false);
    
    AddFileToDownloadsTable("sound/csgo-turkiye_com/pubg/pubg_game.mp3");
    PrecacheSoundAny("csgo-turkiye_com/pubg/pubg_game.mp3", false);
    
    AddFileToDownloadsTable("sound/csgo-turkiye_com/pubg/pubg_game_end.mp3");
    PrecacheSoundAny("csgo-turkiye_com/pubg/pubg_game_end.mp3", false);

    AddFileToDownloadsTable("sound/csgo-turkiye_com/pubg/pubg_game_start_2.mp3");
    PrecacheSoundAny("csgo-turkiye_com/pubg/pubg_game_start_2.mp3", false);

    AddFileToDownloadsTable("sound/csgo-turkiye_com/pubg/pubg_weapon_pickup.mp3");
    PrecacheSoundAny("csgo-turkiye_com/pubg/pubg_weapon_pickup.mp3", false);

    beamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
    haloSprite = PrecacheModel("materials/sprites/halo.vmt");
}