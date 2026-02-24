/*
    fn_fireMission.sqf
    Executes a fire mission: creates explosions at random positions within a circle.
*/

params ["_x", "_y", "_count", "_radius", "_interval"];

diag_log format ["[TULEKASK] === ALGUS === pos=[%1,%2] arv=%3 raadius=%4 intervall=%5", _x, _y, _count, _radius, _interval];
systemChat format ["[TULEKASK] ALGUS pos=[%1,%2] arv=%3", _x, _y, _count];

for "_i" from 1 to _count do {
    private _angle = random 360;
    private _dist = sqrt (random 1) * _radius;
    private _px = _x + (_dist * sin _angle);
    private _py = _y + (_dist * cos _angle);
    private _pz = getTerrainHeightASL [_px, _py];
    private _pos = [_px, _py, _pz];

    private _shell = createVehicle ["Bo_Mk82", _pos, [], 0, "CAN_COLLIDE"];

    diag_log format ["[TULEKASK] Plahvatus %1/%2: pos=%3", _i, _count, _pos];
    systemChat format ["[TULEKASK] Plahvatus %1/%2", _i, _count];

    if (_i < _count) then {
        sleep _interval;
    };
};

diag_log "[TULEKASK] === LOPETATUD ===";
systemChat "[TULEKASK] LOPETATUD";
