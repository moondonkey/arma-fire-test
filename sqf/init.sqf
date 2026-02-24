/*
    init.sqf
    Place this file in your Arma 3 mission root directory.
    Polls for fire_mission.txt via callExtension (no caching).

    Requirements:
    - fire_bridge_x64.dll in Arma 3 root directory
    - Bridge script writing to FIRE_MISSION_PATH below
*/

if (!isServer) exitWith {};

// SET THIS to the full path where bridge.py writes fire_mission.txt
FIRE_MISSION_PATH = "E:\\Programmid\\Steam\\steamapps\\common\\Arma 3\\fire_mission.txt";

diag_log "[TULEKASK] Fire mission system initialized";
systemChat "[TULEKASK] Fire mission system initialized";

// Test which ammo types are available
{
    private _exists = isClass (configFile >> "CfgAmmo" >> _x);
    systemChat format ["[TEST] %1: %2", _x, _exists];
    diag_log format ["[TEST] %1: %2", _x, _exists];
} forEach ["Sh_82mm_AMOS", "R_80mm_HE", "G_40mm_HE", "HelicopterExploSmall", "Bomb_03_F", "Sh_120mm_HE", "Sh_155mm_AMOS", "Bo_Mk82"];
diag_log format ["[TULEKASK] Watching: %1", FIRE_MISSION_PATH];
systemChat format ["[TULEKASK] Watching: %1", FIRE_MISSION_PATH];

[] spawn {
    while {true} do {
        private _content = "fire_bridge" callExtension FIRE_MISSION_PATH;

        if (_content != "") then {
            diag_log format ["[TULEKASK] Mission received: %1", _content];
            systemChat format ["[TULEKASK] Mission received: %1", _content];

            private _parts = _content splitString ",";

            if (count _parts >= 5) then {
                private _x = parseNumber (_parts select 0);
                private _y = parseNumber (_parts select 1);
                private _count = parseNumber (_parts select 2);
                private _radius = parseNumber (_parts select 3);
                private _interval = parseNumber (_parts select 4);
                private _ammoType = if (count _parts >= 6) then {_parts select 5} else {"Bomb_03_F"};
                private _zOffset = if (count _parts >= 7) then {parseNumber (_parts select 6)} else {0};

                systemChat format ["[TULEKASK] TULD! pos=[%1,%2] arv=%3 r=%4 moon=%5 z=%6", _x, _y, _count, _radius, _ammoType, _zOffset];

                // Log all player positions
                {
                    private _pPos = getPos _x;
                    systemChat format ["[TULEKASK] Mangija %1 pos=[%2,%3]", name _x, _pPos select 0, _pPos select 1];
                    diag_log format ["[TULEKASK] Mangija %1 pos=%2", name _x, _pPos];
                } forEach allPlayers;

                // spawn ensures scheduled environment where sleep works
                [_x, _y, _count, _radius, _interval, _ammoType, _zOffset] spawn {
                    params ["_x", "_y", "_count", "_radius", "_interval", "_ammoType", "_zOffset"];

                    diag_log format ["[TULEKASK] SPAWN ALGUS pos=[%1,%2] arv=%3", _x, _y, _count];
                    systemChat format ["[TULEKASK] ALGUS pos=[%1,%2] arv=%3", _x, _y, _count];

                    for "_i" from 1 to _count do {
                        private _angle = random 360;
                        private _dist = sqrt (random 1) * _radius;
                        private _px = _x + (_dist * sin _angle);
                        private _py = _y + (_dist * cos _angle);
                        private _groundZ = getTerrainHeightASL [_px, _py];

                        // Projectiles: spawn 50m above ground, set downward velocity
                        // Pure explosions: spawn at ground level
                        private _isProjectile = !(_ammoType in ["HelicopterExploSmall", "HelicopterExploBig", "FuelExplosion", "FuelExplosionBig"]);

                        private _spawnZ = if (_isProjectile) then {_groundZ + 50 + _zOffset} else {_groundZ + _zOffset};
                        private _pos = [_px, _py, _spawnZ];

                        private _shell = createVehicle [_ammoType, _pos, [], 0, "CAN_COLLIDE"];

                        if (_isProjectile) then {
                            _shell setVelocity [0, 0, -100];
                        };

                        diag_log format ["[TULEKASK] Plahvatus %1/%2 pos=%3", _i, _count, _pos];
                        systemChat format ["[TULEKASK] Plahvatus %1/%2", _i, _count];

                        if (_i < _count) then {
                            sleep _interval;
                        };
                    };

                    diag_log "[TULEKASK] LOPETATUD";
                    systemChat "[TULEKASK] LOPETATUD";
                };
            } else {
                diag_log format ["[TULEKASK] VIGA: Vale formaat: %1", _content];
                systemChat format ["[TULEKASK] VIGA: Vale formaat: %1", _content];
            };
        };

        sleep 1;
    };
};
