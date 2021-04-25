---
title: Der kontrafaktische Aktiensparplanrechner
author: Jan Tau
date: '2021-04-25'
slug: kontrafaktischer-sparrechner
categories: []
tags: [Durchschnittskosteneffekt, Zinseszinseffekt, Shiny, App]
subtitle: 'Was wäre, wenn ich monatlich in Wertpapier XY investiert hätte?'
summary: 'Was wäre, wenn ich monatlich in Wertpapier XY investiert hätte?'
authors: []
lastmod: '2021-04-25T10:24:43+02:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---
## Was wäre wenn

Kontrafaktische Geschichte spekuliert, wie sich die Vergangenheit entwickelt hätte, wenn entscheidende Ereignisse anders ausgegangen wären. Was wäre geschehen, wenn das Attentat von Sarajevo nicht stattgefunden hätte? Wie wäre die Geschichte verlaufen, wenn die amerikanischen Südstaaten den Bürgerkrieg gewonnen hätten? In der Geschichtswissenschaft sind solche Betrachtungen nicht sonderlich beliebt, da den spekulativen Narrativen keine Belege zugrunde liegen. Aufgrund der fehlenden Evidenz sind sie daher nicht falsifizierbar und somit unwissenschaftlich.

Im Bereich persönliche Finanzen gibt es ebenfalls kontrafaktische Überlegungen und ich nehme an, sie sind hier noch unbeliebter als in der Geschichte. Sie offenbaren nämlich persönliche verpasste Chancen oder Fehlentscheidungen. Sie sind zwar komplett hypothetisch, jedoch nicht sonderlich spekulativ, da die historischen Kursverläufe präzise zeigen, was unter verschiedenen Szenarien geschehen wäre. Was wäre, wenn ich seit 2015 monatlich 10 USD-Dollar in Bitcoin gesteckt und bis heute nicht verkauft hätte? (Spoiler: Die 740 investierten Dollar wären Stand 25.04.2021 40 310 Dollar wert.) Oder welchen Wert hätte mein Portfolio heute, wenn ich seit 20 Jahren jeden Monat 100 Euro in Amazon-Aktien investiert hätte? (Spoiler: Das Portfolio wäre ohne Berücksichtigung von Währungsschwankungen 1 274 187 Euro wert.) 

Für solche Fragen habe ich den **kontrafaktischen Aktiensparplanrechner** programmiert. Er benötigt drei Eingaben:
1. den Namen einer Aktie oder eines Fonds (Es können alle an der New York Stock Exchange (NYSE) oder Nasdaq gelisteten Wertpapiere, zusätzlich die größten an der Börse gehandelten deutschen Unternehmen sowie Bitcoin, Ethereum und Litecoin ausgewählt werden.)
2. einen Zeitraum
3. eine monatliche Sparrate

Die Grundlage der Kursberechnung bildet der bereinigte Schlusskurs ([adjusted closing price](https://www.investopedia.com/terms/a/adjusted_closing_price.asp)), der den Wert eines Wertpapiers nach Berücksichtigung aller Kapitalmaßnahmen, wie Dividendenzahlungen oder Aktiensplits, anzeigt. Dividendenzahlungen sind somit rechnerisch in dem angegebenen Kurs reinvestiert.

Aber versucht es selbst. (Bitte beachtet, dass der Aufbau des Charts ein paar Sekunden dauern kann, da die Daten erst über die [finance.yahoo.com-Schnittstelle](https://finance.yahoo.com) geladen und anschließend analysiert werden müssen.)

<iframe height="800" width="100%" frameborder="no" src="https://jantau.shinyapps.io/counterfactual-stock-savings-plan-calculator/"> </iframe>

Das Ziel der Rechenoperation ist es nicht, die verpassten Chancen schmerzhaft bewusst zu machen, die etwa zur finanziellen Unabhängigkeit geführt hätten, wenn man nicht nur zur richtigen Zeit gekauft, sondern auch noch bei allen Hochs und Tiefs beharrlich weiter investiert hätte. Der Rechner soll vielmehr den Hype um Kryptowährungen, Memestocks und r/wallstreetbets relativieren. Er zeigt nämlich, dass es ein grundlegendes Element der Märkte ist, dass sich Chancen auftun, deren Ausmaß erst rückblickend offensichtlich wird. Vor Gamestop und Bitcoin gab es andere Möglichkeiten, mit denen man Wahnsinnsrenditen erzielen konnte. 

Der kontrafaktische Aktiensparplanrechner zeigt, die nächste Gelegenheit kommt bestimmt und wird ziemlich sicher ebenso verpasst werden. Lasst euch also nicht verrückt machen von den aberwitzigen Geschichten, die die Märkte schreiben, sondern konzentriert euch darauf, was wirklich zählt, haltet euren Kurs und verfolgt den Irrsinn aus der Ferne. 

Den für diesen Beitrag erstellten Code findest du hier: [https://github.com/jantau/jantau](https://github.com/jantau/jantau/tree/main/content/post)

Hat dir der Post gefallen? [Melde dich für meinen Newsletter an](https://tinyletter.com/jantau), um über neue Beiträge informiert zu werden.