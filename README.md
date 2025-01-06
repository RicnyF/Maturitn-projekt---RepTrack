![Version](https://img.shields.io/badge/Verze-Alpha_0.1-green.svg?logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI0MCIgaGVpZ2h0PSI0MCIgdmlld0JveD0iMTIgMTIgNDAgNDAiPjxwYXRoIGZpbGw9IiMzMzMzMzMiIGQ9Ik0zMiwxMy40Yy0xMC41LDAtMTksOC41LTE5LDE5YzAsOC40LDUuNSwxNS41LDEzLDE4YzEsMC4yLDEuMy0wLjQsMS4zLTAuOWMwLTAuNSwwLTEuNywwLTMuMiBjLTUuMywxLjEtNi40LTIuNi02LjQtMi42QzIwLDQxLjYsMTguOCw0MSwxOC44LDQxYy0xLjctMS4yLDAuMS0xLjEsMC4xLTEuMWMxLjksMC4xLDIuOSwyLDIuOSwyYzEuNywyLjksNC41LDIuMSw1LjUsMS42IGMwLjItMS4yLDAuNy0yLjEsMS4yLTIuNmMtNC4yLTAuNS04LjctMi4xLTguNy05LjRjMC0yLjEsMC43LTMuNywyLTUuMWMtMC4yLTAuNS0wLjgtMi40LDAuMi01YzAsMCwxLjYtMC41LDUuMiwyIGMxLjUtMC40LDMuMS0wLjcsNC44LTAuN2MxLjYsMCwzLjMsMC4yLDQuNywwLjdjMy42LTIuNCw1LjItMiw1LjItMmMxLDIuNiwwLjQsNC42LDAuMiw1YzEuMiwxLjMsMiwzLDIsNS4xYzAsNy4zLTQuNSw4LjktOC43LDkuNCBjMC43LDAuNiwxLjMsMS43LDEuMywzLjVjMCwyLjYsMCw0LjYsMCw1LjJjMCwwLjUsMC40LDEuMSwxLjMsMC45YzcuNS0yLjYsMTMtOS43LDEzLTE4LjFDNTEsMjEuOSw0Mi41LDEzLjQsMzIsMTMuNHoiLz48L3N2Zz4%3D)
[![Developer](https://img.shields.io/badge/Developer-Filip_Říčný-green)](https://github.com/Ejdmoss)
[![Framework](https://img.shields.io/badge/Framework-Flutter-blue)](https://flutter.dev/)
[![Framework](https://img.shields.io/badge/Framework-dart-blue)](https://dart.dev/)
[![Database](https://img.shields.io/badge/Database-FireBase-orange)](https://firebase.google.com/)

# **Aplikace pro sledování tréninků ve fitness**

Tato aplikace je určena pro všechny, kteří chtějí mít přehled o svých trénincích, sledovat svůj pokrok a mít možnost si jednoduše plánovat nové tréninky. Umožňuje uživatelům spravovat své rutiny, vytvářet vlastní cvičební plány a sledovat detailní statistiky jednotlivých cviků. Aplikace je vhodná jak pro začátečníky, tak pro zkušené sportovce, kteří chtějí optimalizovat své tréninkové postupy.

---

# **Funkcionality**

- **Úvodní stránka s přepínáním:** Obsahuje dolní navigační lištu pro přepínání mezi stránkami *"Přátelé"*, *"Přidat trénink"* a *"Profil"*.
- **Přidání tréninku:** Možnost výběru mezi prázdným tréninkem, rutinami a jednotlivými cviky. Uživatel může pojmenovat trénink, přidávat cviky, nastavovat opakování a váhy.
- **Detailní správa tréninku:** Uživatel během cvičení zadává jednotlivé série a po splnění série se spustí odpočinkový časovač (standardně nastavený na 3 minuty s možností přidání nebo odebrání 15 sekund).
- **Rutiny:** Uživatel vidí své vlastní rutiny i předdefinované rutiny. Administrátor má možnost upravovat a mazat všechny rutiny. Po spuštění rutiny se otevře tréninková stránka s detaily dané rutiny.
- **Stránka s cviky:** Zobrazuje seznam cviků s možností rozkliknutí na detail cviku. Detail obsahuje popis, historii provedení a nejlepší výkony. Administrátor může cviky editovat a mazat.
- **Profilová stránka:** Obsahuje informace o uživateli a jeho profilový obrázek. Součástí je i kalendář zobrazující dny s provedenými tréninky. Po kliknutí na konkrétní den se zobrazí detaily tréninku s možností jej znovu spustit.
- **Nastavení:** V nastavení může uživatel měnit svůj profilový obrázek, jméno a datum narození, přepínat režim aplikace mezi světlým a tmavým a spravovat účet (odhlášení, smazání účtu).

---

# **Technologie**

- **Flutter** – framework pro rychlý multiplatformní vývoj moderních mobilních aplikací s jednoduchou a přehlednou syntaxí.
- **Firebase** – slouží k autentizaci uživatelů a správě dat v reálném čase.
- **Cloud Firestore** – cloudová NoSQL databáze pro ukládání tréninků, rutin a uživatelských profilů.

Aplikace klade důraz na jednoduché ovládání, moderní design a přizpůsobitelnost podle preferencí uživatele.
