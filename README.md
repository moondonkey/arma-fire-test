# Arma 3 Fire Mission Test Server

Veebiliides → Railway server → Bridge skript → Arma 3 plahvatused.

## Arhitektuur

```
┌─────────────┐     HTTP      ┌─────────────────┐
│  Veebiliides │  ────────►   │  Railway server  │
│  (telefon)   │              │  /api/fire       │
└─────────────┘              └────────┬────────┘
                                       │
                                       │  HTTP poll (1s)
                                       ▼
                              ┌─────────────────┐     fail       ┌──────────┐
                              │  Bridge skript   │  ──────────►  │  Arma 3  │
                              │  (Python)        │               │  server   │
                              └─────────────────┘               └──────────┘
                                  Arma 3 masinal              callExtension DLL
                                                              loeb + kustutab faili
```

## Paigaldamine

### 1. Railway server

1. Loo Railway-s uus projekt
2. Ühenda see repo
3. Deploy — server käivitub automaatselt

Veebiliides on saadaval Railway URL-i juurkaustas (nt `https://xxx.up.railway.app`).

### 2. DLL kompileerimine (Windowsi Arma masinal)

Vajad MinGW-w64 kompilaatorit. Kui pole paigaldatud:
- Lae alla: https://winlibs.com/ (vali **x86_64**, **UCRT runtime**)
- Paki lahti ja lisa `bin` kaust PATH-i

Kompileeri:

```cmd
cd extension
gcc -shared -o fire_bridge_x64.dll fire_bridge.c -static
```

### 3. Failide paigutamine

```
Arma 3 kaust/
├── arma3server_x64.exe
├── fire_bridge_x64.dll              ← kompileeritud DLL
├── fire_mission.txt                 ← bridge kirjutab siia (automaatne)
└── mpmissions/
    └── sinu_missioon.kaart/
        ├── init.sqf                 ← sqf/ kaustast
        ├── fn_fireMission.sqf       ← sqf/ kaustast
        └── ... (ülejäänud missiooni failid)
```

### 4. init.sqf seadistamine

Ava `sqf/init.sqf` ja muuda `FIRE_MISSION_PATH` vastama tegelikule asukohale:

```sqf
FIRE_MISSION_PATH = "C:\arma3\fire_mission.txt";
```

See peab ühtima bridge skripti `--out` parameetriga.

**NB:** Kui missioonil on juba olemasolev `init.sqf`, lisa selle sisu olemasoleva faili lõppu.

### 5. Bridge skripti käivitamine

Arma 3 masinal (vajab Python 3):

```cmd
python bridge/bridge.py --server https://sinu-railway-url.up.railway.app --out "C:\arma3\fire_mission.txt"
```

Parameetrid:
| Parameeter | Vaikimisi | Kirjeldus |
|------------|-----------|-----------|
| `--server` | (kohustuslik) | Railway serveri URL |
| `--out` | `C:\arma3\fire_mission.txt` | Faili asukoht (peab ühtima init.sqf-iga) |
| `--poll-interval` | `1.0` | Serveri küsitlemise intervall sekundites |

### 6. Kasutamine

1. Käivita Arma 3 missioon (või restarti kui juba jookseb)
2. Käivita bridge skript
3. Ava Railway URL telefonist või arvutist
4. Sisesta Arma 3 maailmakoordinaadid (X, Y)
5. Vali plahvatuste arv, raadius ja intervall
6. Vajuta **TULD!**

## Veebiliidese parameetrid

| Väli | Vaikimisi | Kirjeldus |
|------|-----------|-----------|
| X koordinaat | — | Arma 3 maailma X koordinaat |
| Y koordinaat | — | Arma 3 maailma Y koordinaat |
| Plahvatusi | 6 | Plahvatuste arv |
| Raadius (m) | 50 | Hajuvusringi raadius meetrites |
| Intervall (sek) | 1.5 | Aeg plahvatuste vahel sekundites |

## Veaotsing

- **Bridge ei ühendu** — kontrolli et Railway URL on õige ja server on deploy'tud
- **Arma ei reageeri** — kontrolli et `fire_bridge_x64.dll` on Arma 3 juurkaustas (mitte mpmissions kaustas)
- **Plahvatusi ei teki** — vaata Arma 3 RPT logist `[TULEKASK]` ridu
- **Faili ei kustutata** — DLL-il pole kirjutusõigust, proovi teist asukohta
