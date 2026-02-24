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

[] spawn {
    while {true} do {
        private _content = "fire_bridge" callExtension FIRE_MISSION_PATH;

        if (_content != "") then {
            diag_log format ["[TULEKASK] Mission received: %1", _content];

            private _parts = _content splitString ",";
            private _type = _parts select 0;

            if (_type == "HE") then {
                // HE,x,y,count,radius,interval,zOffset
                if (count _parts >= 7) then {
                    private _x = parseNumber (_parts select 1);
                    private _y = parseNumber (_parts select 2);
                    private _count = parseNumber (_parts select 3);
                    private _radius = parseNumber (_parts select 4);
                    private _interval = parseNumber (_parts select 5);
                    private _zOffset = parseNumber (_parts select 6);

                    diag_log format ["[TULEKASK] HE pos=[%1,%2] arv=%3 r=%4 z=%5", _x, _y, _count, _radius, _zOffset];

                    // Log player positions
                    {
                        private _pPos = getPos _x;
                        diag_log format ["[TULEKASK] Mangija %1 pos=%2", name _x, _pPos];
                    } forEach allPlayers;

                    [_x, _y, _count, _radius, _interval, _zOffset] spawn {
                        params ["_x", "_y", "_count", "_radius", "_interval", "_zOffset"];

                        for "_i" from 1 to _count do {
                            private _angle = random 360;
                            private _dist = sqrt (random 1) * _radius;
                            private _px = _x + (_dist * sin _angle);
                            private _py = _y + (_dist * cos _angle);
                            private _pz = (getTerrainHeightASL [_px, _py]) + _zOffset;
                            private _pos = [_px, _py, _pz];

                            private _shell = createVehicle ["Sh_82mm_AMOS", _pos, [], 0, "CAN_COLLIDE"];
                            _shell setVelocity [0, 0, -100];

                            diag_log format ["[TULEKASK] Plahvatus %1/%2 pos=%3", _i, _count, _pos];

                            if (_i < _count) then {
                                sleep _interval;
                            };
                        };

                        diag_log "[TULEKASK] HE LOPETATUD";
                    };
                };
            };

            if (_type == "ILLUM") then {
                // ILLUM,x,y,height,brightness
                if (count _parts >= 5) then {
                    private _x = parseNumber (_parts select 1);
                    private _y = parseNumber (_parts select 2);
                    private _height = parseNumber (_parts select 3);
                    private _brightness = parseNumber (_parts select 4);

                    diag_log format ["[TULEKASK] ILLUM pos=[%1,%2] h=%3 bright=%4", _x, _y, _height, _brightness];

                    [_x, _y, _height, _brightness] spawn {
                        params ["_x", "_y", "_height", "_brightness"];

                        private _groundZ = getTerrainHeightASL [_x, _y];
                        private _startZ = _groundZ + _height;
                        private _dropSpeed = _height / 40;  // 350m / 40s = 8.75 m/s

                        // Create light source
                        private _light = "#lightpoint" createVehicle [_x, _y, _startZ];
                        _light setLightBrightness _brightness;
                        _light setLightAmbient [1, 1, 0.8];
                        _light setLightColor [1, 1, 0.8];
                        _light setLightAttenuation [1, 0, 0, 0.01];

                        // Create visible flare object
                        private _flare = "Flare_82mm_AMOS_White" createVehicle [_x, _y, _startZ];

                        diag_log format ["[TULEKASK] ILLUM created at z=%1, dropping %2 m/s", _startZ, _dropSpeed];

                        // Descend loop
                        private _currentZ = _startZ;
                        while {_currentZ > _groundZ} do {
                            _currentZ = _currentZ - (_dropSpeed * 0.5);
                            _light setPos [_x, _y, _currentZ];
                            _flare setPos [_x, _y, _currentZ];
                            sleep 0.5;
                        };

                        // Cleanup
                        deleteVehicle _light;
                        deleteVehicle _flare;

                        diag_log "[TULEKASK] ILLUM LOPETATUD";
                    };
                };
            };
        };

        sleep 1;
    };
};
