[![en](https://img.shields.io/badge/lang-en-red.svg)](README.md)
[![pl](https://img.shields.io/badge/lang-pl-blue.svg)](README.pl.md)

# Ratslinger - gra typu wave defense w klimacie dzikiego zachodu
![tytuł](.github/readme_assets/title.png)

## Opis
Ratslinger to gra, w której gracz wciela się w szeryfa zrujnowanego szczurzego miasta na dzikim zachodzie. Celem jest obrona przed falami atakujących zwierząt, które pojawiają się po interakcji na środku areny. Zabici wrogowie upuszczają monety, za które można kupić ulepszenia zapewniające specjalne umiejętności w sklepie. Gracz może również wchodzić w interakcje z postaciami niezależnymi w mieście, aby wykonywać misje poboczne i poznawać historię miasta. Gra wykorzystuje kreskówkową grafikę pixel-art, z perspektywy z góry na dół.

## Mechaniki
- System celności:<br>
![pasek celności](.github/readme_assets/accuracy_bar.gif)<br>
W prawym górnym rogu ekranu znajduje się pasek celności z czerwonymi, żółtymi i zielonymi obszarami. Kluczem jest wyczucie czasu, strzelenie gdy kursor jest na zielonym kolorze zwiększa moc strzałów, a czerwony sprawia, że pudłujesz.
- Specjalne pociski:<br>
![efekty specjalnych pocisków](.github/readme_assets/special_bullets.gif)<br>
Kupuj je i ulepszaj w sklepie za monety. Na tą chwilę dostępne są trzy rodzaje pocisków: wampiryczne, piekielne i trujące. Pojawiają się one w slotach na pociski, im wyższy poziom, tym częściej. Musisz trafić w zielony obszar, aby specjalny pocisk zadziałał.
- Przeciwnicy:<br>
<img src=".github/readme_assets/enemies/fox.gif" width="10%" alt="lis"><img src=".github/readme_assets/enemies/beaver.gif" width="10%" alt="bóbr"><img src=".github/readme_assets/enemies/snake.gif" width="10%" alt="wąż"><img src=".github/readme_assets/enemies/owl.gif" width="10%" alt="sowa"><br>
Obecnie w grze dostępnych jest 4 unikalnych wrogów: Lis Strzelec, Bóbr ze Strzelbą, Wąż i Sowa.
- Postacie niezależne (NPC):<br>
![NPC w mieście](.github/readme_assets/npcs.gif)<br>
Istnieją 3 różne postacie niezależne (NPC):
  - Burmistrz - opowiada historię i zleca misje,
  - Budowniczy - naprawia miasto pomiędzy falami,
  - Dzeciak - cieszy się życiem konsumując swój ogromny lizak.

## Wsparcie na platformach
W [releases](../../releases) można znaleźć wersję skompilowaną dla architektury 64-bitowej. Ponieważ projekt to otwarte oprogramowanie (open-source), można go łatwo otworzyć w silniku [Godot (4.6+)](https://godotengine.org/download/windows/#platforms) i samodzielnie skompilować. Będzie to działać na każdej platformie obsługiwanej przez Godot, takiej jak Linux i macOS, razem z Windows (na wszystkich platformach program był testowany i działa).

Gra teoretycznie mogłaby trafić na urządzenia mobilne, ale nie obsługuje takeigo sterowania. Nie planujemy oficjalnego wydania takiej wersji, ponieważ naszym zdaniem nie pasowałoby to do rozgrywki.

## Sterowania
|akcja|klawisz|
|------|-----|
|ruch w górę|w|
|ruch w dół|s|
|ruch w lewo|a|
|ruch w prawo|d|
|skalowanie w dół|q|
|skalowanie w górę|e|
|przełączanie błysku i dźwięku przy perfekcyjej celności (debugowanie)|r|
|przełączanie pomijania ekranu tytułowego (debugowanie)|t|
|interakcja|z|
|pauza/wznów|x|
|strzał|lewy przycisk myszy|
|postęp w dialogu|enter, lewy przycisk myszy, spacja|
|przełączanie trybu pełnoekranowego|f11|
|wyjście|escape|

Konfiguracja niestandardowych klawiszy nie są jeszcze obsługiwana.

## Posłowie
Ta gra powstała w ramach praktyk zawodowych w technikum informatycznym SCI.