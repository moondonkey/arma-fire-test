/*
    init.sqf
    Place this file in your Arma 3 mission root directory.
    It polls for fire_mission.txt and executes fire missions.

    Also copy fn_fireMission.sqf to the same mission directory.
*/

if (!isServer) exitWith {};  // Only run on the server

diag_log "[TULEKASK] Fire mission system initialized";

// Poll loop - runs on server
[] spawn {
    private _missionDir = format ["\%1\", missionConfigFile];
    // We use profileNamespace path for file operations
    diag_log "[TULEKASK] Polling for fire missions...";

    while {true} do {
        // Try to load the fire mission file
        private _content = loadFile "fire_mission.txt";

        if (_content != "") then {
            diag_log format ["[TULEKASK] File found: %1", _content];

            // Parse CSV: x,y,count,radius,interval
            private _parts = _content splitString ",";

            if (count _parts >= 5) then {
                private _x = parseNumber (_parts select 0);
                private _y = parseNumber (_parts select 1);
                private _count = parseNumber (_parts select 2);
                private _radius = parseNumber (_parts select 3);
                private _interval = parseNumber (_parts select 4);

                // Delete the file by overwriting with empty (SQF can't delete files)
                // The bridge script should handle cleanup, or we just process once
                diag_log "[TULEKASK] Executing fire mission...";

                // Execute fire mission
                [_x, _y, _count, _radius, _interval] execVM "fn_fireMission.sqf";
            } else {
                diag_log format ["[TULEKASK] VIGA: Vale formaat, oodati 5 väärtust, sain %1", count _parts];
            };

            // Wait extra time to avoid re-reading same file
            // Bridge script should only write new file after previous is consumed
            sleep 5;
        };

        sleep 1;
    };
};
