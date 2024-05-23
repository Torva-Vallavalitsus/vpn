# VPN ühenduse loomise abimees

Käesolev repo sisaldab skripti, mis konfigureerib Windowsi Powershellis automaatselt arvutisse Tõrva Vallavalitsusega seotud asutuse sisevõrgu. Peamiselt on sihtgrupiks erinevad automaatikasüsteemide spetsialistid, kes vajavad sisevõrgus asuvatele seadmetele ligipääsu, kuid skript on avalik, see ei sisalda mingeid saladusi, vaid ainult lihtsustab arvutis tehtavaid samme (automatiseerib VPN ühenduse lisamist Windowsisse).

```
iwr -useb https://raw.githubusercontent.com/Torva-Vallavalitsus/vpn/main/vpn.torva.ee.ps1 | iex -connectionName "ÜHENDUSE_NIMI" -destinationPrefix "SISEVÕRGU_PREFIKS"

Asenda ÜHENDUSE_NIMI soovitud nimega, mida Windows VPN nimena kuvama hakkab.
Asenda SISEVÕRGU_PREFIKS selle sisevõrgu prefiksiga, kuhu võrku sa tahad pääseda (näiteks 192.168.2.0/24)
