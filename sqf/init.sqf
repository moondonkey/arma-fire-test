/*
    init.sqf
    Place this file in your Arma 3 mission root directory.
    Polls for fire_mission.txt via callExtension (no caching).

    Requirements:
    - fire_bridge_x64.dll in Arma 3 root directory
    - fn_fireMission.sqf in mission directory
    - Bridge script writing to FIRE_MISSION_PATH below
*/

if (!isServer) exitWith {};

// SET THIS to the full path where bridge.py writes fire_mission.txt
FIRE_MISSION_PATH = "E:\\Programmid\\Steam\\steamapps\\common\\Arma 3\\fire_mission.txt";

diag_log "[TULEKASK] Fire mission system initialized";
systemChat "[TULEKASK] Fire mission system initialized";
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

                systemChat format ["[TULEKASK] TULD! pos=[%1,%2] arv=%3 raadius=%4", _x, _y, _count, _radius];

                [_x, _y, _count, _radius, _interval] execVM "fn_fireMission.sqf";
            } else {
                diag_log format ["[TULEKASK] VIGA: Vale formaat: %1", _content];
                systemChat format ["[TULEKASK] VIGA: Vale formaat: %1", _content];
            };
        };

        sleep 1;
    };
};
