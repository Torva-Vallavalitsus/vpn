# VPN-ühenduse seadistamine

See skript aitab automatiseerida Windowsisse Tõrva Vallavalitsusega seotud asutuste VPN ühenduse loomist. Skript on loodud eelkõige automaatikasüsteemide spetsialistide jaoks, kes vajavad juurdepääsu sisevõrgus paiknevatele seadmetele. Skript on avalikult kättesaadav ega sisalda konfidentsiaalset teavet, lihtsalt automatiseerib samme.

## Skripti Funktsionaalsus
1. **SSL Sertifikaadi lisamine:** Lisab Tõrva Vallavalitsuse VPN-serveri (vpn.torva.ee) SSL sertifikaadi Windowsi usaldatavate juursertifikaatide hoidlasse, et Windows oleks nõus ühendust selle serveriga looma.
2. **VPN Profiili loomine:** Loob uue VPN-profiili kasutaja määratud nimega.
3. **Marsruudi seadistamine:** Seadistab VPN-profiilile kasutaja määratud marsruudi, mille abil suunatakse VPN ühenduse loomisel sellesse võrguvahemikku adresseeritud liiklus ümber VPN-tunnelisse.
4. **Vaikelüüsina kasutamise keelamine:** Keelab VPN profiilil "Use default gateway on remote network" funktsiooni, et Windowsi ei üritaks saata kogu internetiliiklust läbi Tõrva VPN serveri.

## Kasutusjuhend

**Käivita käsk Windowsi Powershellis:**

```powershell
iwr -useb https://raw.githubusercontent.com/Torva-Vallavalitsus/vpn/main/vpn.torva.ee.ps1 | iex -connectionName "ÜHENDUSE_NIMI" -destinationPrefix "SISEVÕRGU_PREFIKS"
```

- **ÜHENDUSE_NIMI:** Asenda see soovitud VPN-ühenduse nimega. Näiteks "Tõrva tänavavalgustus" vms.
- **SISEVÕRGU_PREFIKS:** Asenda see sisevõrgu prefiksiga, millele soovid juurdepääsu (näiteks 192.168.2.0/24).

**Edasised sammud:**

1. Kontrolli, kas Windowsis on loodud uus VPN-ühendus määratud nimega.
2. Ühendu VPN-iga ja sisesta oma kasutajatunnus ja parool, mis sulle antud on Tõrva Vallavalitsuse IT poolt.
3. Testi, kas saad ühenduse soovitud automaatikaseadmega.
