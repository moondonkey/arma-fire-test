# Arma 3 plahvatuste tekitamise märkmed

## Moona tüüp

Parim valik 81mm miina simuleerimiseks: **`Sh_82mm_AMOS`**

## Plahvatuse tekitamine

```sqf
private _shell = createVehicle ["Sh_82mm_AMOS", _pos, [], 0, "CAN_COLLIDE"];
_shell setVelocity [0, 0, -100];
```

- `setVelocity [0, 0, -100]` on VAJALIK — ilma selleta projektiil ei plahvata korrektselt
- Z kõrgus: `getTerrainHeightASL` - 50 annab parima tulemuse (mürsk tekib maapinnal, plahvatab koheselt ilma viiteta)
- Z = 0 (maapinnal): plahvatus toimub aga väikese viitega
- Z > 0 (kõrgemal): nähtav kukkumine enne plahvatust

## Testitud moona tüübid

| Tüüp | Tulemus |
|------|---------|
| `Sh_82mm_AMOS` | **Parim** — realistlik 82mm miina plahvatus, Z=-50 korral kohene |
| `Bomb_03_F` | Töötab aga liiga suur plahvatus (lennukipomm) |
| `R_80mm_HE` | Projektiil — lendab suunas edasi kui setVelocity pole õige |
| `Bo_Mk82` | Sarnane Bomb_03_F-le |
| `HelicopterExploSmall` | Puhas efekt, ei vaja setVelocity |
| `HelicopterExploBig` | Suur puhas efekt |

## SQF eripärad (dedicated server)

- `sleep` töötab ainult **scheduled environment**-is — kasuta `spawn`, mitte `execVM`
- `loadFile` on **cachitud** — failipõhine suhtlus vajab callExtension DLL-i
- `systemChat` kuvab sõnumid mängu chat-is (hea debug jaoks)
- `diag_log` kirjutab RPT faili (`%LOCALAPPDATA%\Arma 3\`)
- Arma 3 dedicated serveri käivitamine on 2-sammuline protsess (mõlemad peavad käima enne kui skriptid töötavad)
