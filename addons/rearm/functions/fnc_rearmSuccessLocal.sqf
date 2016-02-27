/*
 * Author: GitHawk
 * Rearms a vehicle on the turret owner.
 *
 * Arguments:
 * 0: Params <ARRAY>
 *   0: Target <OBJECT>
 *   1: Unit <OBJECT>
 *   2: Turret Path <ARRAY>
 *   3: Number of magazines <NUMBER>
 *   4: Magazine Classname <STRING>
 *   5: Number of rounds <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [[vehicle, player, [-1], 2, "5000Rnd_762x51_Belt", 500]] call ace_rearm_fnc_rearmSuccess
 *
 * Public: No
 */
#include "script_component.hpp"

params [["_args", [objNull, objNull, [], 0, "", 0], [[]], [6]]];
_args params ["_target", "_unit", "_turretPath", "_numMagazines", "_magazineClass", "_numRounds"];

private _rounds = getNumber (configFile >> "CfgMagazines" >> _magazineClass >> "count");
private _currentRounds = 0;
private _maxMagazines = [_target, _turretPath, _magazineClass] call FUNC(getMaxMagazines);

if (_maxMagazines == 1) then {
    private _currentMagazines = { _x == _magazineClass } count (_target magazinesTurret _turretPath);
    if (_currentMagazines == 0 && {!(_turretPath isEqualTo [-1])}) then {
        // Driver gun will always retain it's magazines
        _target addMagazineTurret [_magazineClass, _turretPath];
        _target setMagazineTurretAmmo [_magazineClass, 0, _turretPath];
    };
    if (GVAR(level) == 1) then {
        // Fill magazine completely
        _target setMagazineTurretAmmo [_magazineClass, _rounds, _turretPath];
        ["displayTextStructured", [_unit], [[LSTRING(Hint_RearmedTriple), _rounds,
            getText(configFile >> "CfgMagazines" >> _magazineClass >> "displayName"),
            getText(configFile >> "CfgVehicles" >> (typeOf _target) >> "displayName")], 3, _unit]] call EFUNC(common,targetEvent);
    } else {
        // Fill only at most _numRounds
        _target setMagazineTurretAmmo [_magazineClass, ((_target magazineTurretAmmo [_magazineClass, _turretPath]) + _numRounds) min _rounds, _turretPath];
        ["displayTextStructured", [_unit], [[LSTRING(Hint_RearmedTriple), _numRounds,
            getText(configFile >> "CfgMagazines" >> _magazineClass >> "displayName"),
            getText(configFile >> "CfgVehicles" >> (typeOf _target) >> "displayName")], 3, _unit]] call EFUNC(common,targetEvent);
    };
} else {
    for "_idx" from 1 to (_maxMagazines+1) do {
        _currentRounds = _target magazineTurretAmmo [_magazineClass, _turretPath];
        if (_currentRounds > 0 || {_idx == (_maxMagazines+1)}) exitWith {
            if (_idx == (_maxMagazines+1) && {!(_turretPath isEqualTo [-1])}) then {
                _target addMagazineTurret [_magazineClass, _turretPath];
            };
            if (GVAR(level) == 2) then {
                //hint format ["Target: %1\nTurretPath: %2\nNumMagazines: %3\nMaxMagazines %4\nMagazine: %5\nNumRounds: %6\nMagazine: %7", _target, _turretPath, _numMagazines, _maxMagazines, _currentRounds, _numRounds, _magazineClass];
                // Fill only at most _numRounds
                if ((_currentRounds + _numRounds) > _rounds) then {
                    _target setMagazineTurretAmmo [_magazineClass, _rounds, _turretPath];
                    if (_numMagazines  < _maxMagazines) then {
                        _target addMagazineTurret [_magazineClass, _turretPath];
                        _target setMagazineTurretAmmo [_magazineClass, _currentRounds + _numRounds - _rounds, _turretPath];
                    };
                } else {
                    _target setMagazineTurretAmmo [_magazineClass, _currentRounds + _numRounds, _turretPath];
                };
                ["displayTextStructured", [_unit], [[LSTRING(Hint_RearmedTriple), _numRounds,
                    getText(configFile >> "CfgMagazines" >> _magazineClass >> "displayName"),
                    getText(configFile >> "CfgVehicles" >> (typeOf _target) >> "displayName")], 3, _unit]] call EFUNC(common,targetEvent);
            } else {
                // Fill current magazine completely and fill next magazine partially
                _target setMagazineTurretAmmo [_magazineClass, _rounds, _turretPath];
                if (_numMagazines  < _maxMagazines) then {
                    _target addMagazineTurret [_magazineClass, _turretPath];
                    _target setMagazineTurretAmmo [_magazineClass, _currentRounds, _turretPath];
                };
                ["displayTextStructured", [_unit], [[LSTRING(Hint_RearmedTriple), _rounds,
                    getText(configFile >> "CfgMagazines" >> _magazineClass >> "displayName"),
                    getText(configFile >> "CfgVehicles" >> (typeOf _target) >> "displayName")], 3, _unit]] call EFUNC(common,targetEvent);
            };
        };
        _target removeMagazineTurret [_magazineClass, _turretPath];
        _numMagazines = _numMagazines - 1;
    };
};
