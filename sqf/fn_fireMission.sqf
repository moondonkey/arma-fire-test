/*
    fn_fireMission.sqf
    Executes a fire mission: creates explosions at random positions within a circle.
*/

params ["_x", "_y", "_count", "_radius", "_interval"];

diag_log format ["[TULEKASK] === ALGUS === pos=[%1,%2] arv=%3 raadius=%4 intervall=%5", _x, _y, _count, _radius, _interval];
systemChat format ["[TULEKASK] ALGUS pos=[%1,%2] arv=%3", _x, _y, _count];

for "_i" from 1 to _count do {
    diag_log format ["[TULEKASK] --- Plahvatus %1/%2 arvutan positsiooni ---", _i, _count];

    private _angle = random 360;
    private _dist = sqrt (random 1) * _radius;
    private _px = _x + (_dist * sin _angle);
    private _py = _y + (_dist * cos _angle);

    diag_log format ["[TULEKASK] Angle=%1 Dist=%2 Pos=[%3,%4]", _angle, _dist, _px, _py];

    private _pz = getTerrainHeightASL [_px, _py];
    diag_log format ["[TULEKASK] TerrainHeight=%1", _pz];

    private _pos = [_px, _py, _pz];
    diag_log format ["[TULEKASK] Loon plahvatuse: pos=%1", _pos];

    try {
        private _shell = createVehicle ["Bo_Mk82", _pos, [], 0, "CAN_COLLIDE"];
        diag_log format ["[TULEKASK] Plahvatus %1/%2 OK: %3", _i, _count, _shell];
        systemChat format ["[TULEKASK] Plahvatus %1/%2 OK", _i, _count];
    } catch {
        diag_log format ["[TULEKASK] VIGA plahvatus %1/%2: %3", _i, _count, _exception];
        systemChat format ["[TULEKASK] VIGA %1/%2", _i, _count];
    };

    if (_i < _count) then {
        diag_log format ["[TULEKASK] Sleep %1 sek", _interval];
        sleep _interval;
    };
};

diag_log "[TULEKASK] === LOPETATUD ===";
systemChat "[TULEKASK] LOPETATUD";
