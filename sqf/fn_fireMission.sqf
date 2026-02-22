/*
    fn_fireMission.sqf
    Executes a fire mission: creates explosions at random positions within a circle.

    Parameters (passed as array):
        _x        - X world coordinate (center)
        _y        - Y world coordinate (center)
        _count    - Number of explosions
        _radius   - Dispersion radius in meters
        _interval - Seconds between explosions

    Called by init.sqf when fire_mission.txt is detected.
*/

params ["_x", "_y", "_count", "_radius", "_interval"];

diag_log format ["[TULEKASK] Algus: pos=[%1,%2] arv=%3 raadius=%4 intervall=%5", _x, _y, _count, _radius, _interval];
systemChat format ["[TULEKASK] Algus: pos=[%1,%2] arv=%3", _x, _y, _count];

for "_i" from 1 to _count do {
    // Random position within circle
    private _angle = random 360;
    private _dist = sqrt (random 1) * _radius;  // sqrt for uniform distribution
    private _px = _x + (_dist * sin _angle);
    private _py = _y + (_dist * cos _angle);

    // Get terrain height at this position
    private _pz = getTerrainHeightASL [_px, _py];

    // Create 82mm shell explosion (closest to 81mm mortar)
    private _pos = [_px, _py, _pz];
    private _shell = "Sh_82mm_AMOS" createVehicle _pos;

    diag_log format ["[TULEKASK] Plahvatus %1/%2: pos=%3", _i, _count, _pos];
    systemChat format ["[TULEKASK] Plahvatus %1/%2", _i, _count];

    if (_i < _count) then {
        sleep _interval;
    };
};

diag_log "[TULEKASK] Tulekäsk lõpetatud";
systemChat "[TULEKASK] Tulekäsk lõpetatud";
