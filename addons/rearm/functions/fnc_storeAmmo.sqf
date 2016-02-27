/*
 * Author: GitHawk
 * Stores ammo in an ammo truck.
 *
 * Arguments:
 * 0: Target <OBJECT>
 * 1: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, dummy] call ace_rearm_fnc_storeAmmo
 *
 * Public: No
 */
#include "script_component.hpp"

params [["_target", objNull, [objNull]], ["_unit", objNull, [objNull]]];

private _dummy = _unit getVariable [QGVAR(dummy), objNull];
if (isNull _dummy) exitwith {};

[
    5,
    [_unit, _target, _dummy],
    {
        params ["_args"];
        _args params ["_unit", "_target", "_dummy"];
        [_target, (_dummy getVariable [QGVAR(magazineClass), ""]), true] call FUNC(addMagazineToSupply);
        [_unit, true, true] call FUNC(dropAmmo);
    },
    "",
    format [localize LSTRING(StoreAmmoAction), getText(configFile >> "CfgMagazines" >> (_dummy getVariable QGVAR(magazineClass)) >> "displayName"), getText(configFile >> "CfgVehicles" >> (typeOf _target) >> "displayName")],
    {true},
    ["isnotinside"]
] call EFUNC(common,progressBar);
