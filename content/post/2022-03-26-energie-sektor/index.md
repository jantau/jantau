---
title: Kein guter Jahresauftakt für den Aktienmarkt
author: Jan Tau
date: '2022-03-28'
slug: energie-sektor
categories: []
tags: [ETF, MSCI World, Gewichtung]
subtitle: 'aber ein Sektor läuft allen davon'
summary: 'aber ein Sektor läuft allen davon'
authors: []
featured: no
image:
  caption: ''
  focal_point: 'center'
  preview_only: true
projects: []
---
Wir nähern uns dem Ende des ersten Quartals des Jahres 2022 und der Aktienmarkt tut sich schwer. Die hohe Inflation, die Straffung der Geldpolitik und natürlich der furchtbare Krieg in der Ukraine wirken sich auf die Märkte aus.

Ein in Euro gehandelter MSCI World-ETF (der etwa 85 % der Marktkapitalisierung von Aktiengesellschaften in Industrieländern abbildet), ist auf Jahressicht mit 
etwa 2,5 % im Minus. Ein S&P 500-ETF steht bei -1,5 % und ein DAX-ETF bei -10 % (Stand 28.3.2022). 

## Sektorenvergleich im 1. Quartal 2022

Es gibt jedoch einen Teil des Aktienmarktes, der durchgehend von den makroökonomischen Rahmenbedingungen profitiert hat. Es handelt sich um die Energie-Werte. Überaus deutlich wird dies, wenn die einzelnen Aktien nach Sektoren gruppiert betrachtet werden. (Über die Implikationen der Klassifikation von Unternehmen nach dem [Global Industry Classification Standard](https://www.msci.com/our-solutions/indexes/gics) habe ich [in einem früheren Beitrag geschrieben](/post/gewichtung/)).

Für die Analyse der Sektoren habe ich die in Europa gehandelten [Sektoren-ETFs von Xtrackers](https://etf.dws.com/de-de/produktfinder/?searchterm=MSCI+World&Asset%20Class%20Calculated=Aktien&Region%20Calculated=Sektor) analysiert. Die bisherige Entwicklung im Jahr 2022 stellt sich so dar:

<iframe height="550" width="100%" frameborder="no" src="https://jantau.github.io/highchart/sector_etfs.html"> </iframe>

Der Unterschied zwischen den Energie-Sektoren und den restlichen Sektoren ist extrem. Es gab Tage im März, da lag der Energie-Sektor über 30 % im Plus, während alle anderen Sektoren ein Minus zu verbuchen hatten. 

Zum Ende des Quartals beträgt die Spanne zwischen dem Energiesektor und dem zweitplatzierten Sektor Materials annähernd 32 %. Die Spanne zum Schlusslicht zyklische Konsumgüter beträgt über 47 %.

## Ranking der Top-10-Werte pro Sektor

Aber was genau sind das für Werte, die von dem jetzigen Umfeld profitieren? Um diese Frage zu beantworten, habe ich mir die Top-10-Werte (nach Marktkapitalisierung) pro Sektor angeschaut (also 110 Aktien) und sie nach ihrer Performance seit Jahresbeginn von 1-110 gerankt. 

So bin ich hierbei vorgegangen: Über iShares habe ich [sämtliche im MSCI World enthaltenen Werte](https://www.ishares.com/de/privatanleger/de/produkte/251882/ishares-msci-world-ucits-etf-acc-fund/1478358465952) mit ihrer Gewichtung und Sektorenzugehörigkeit ermitteln können. Die Top-10-Aktien pro Sektor habe ich über die API von [finance.yahoo.com](https://finance.yahoo.com) abgefragt. Bei den europäischen und japanischen Werten war etwas zusätzliche Datenpflege notwendig, da yahoo.finance.com bei außerhalb der USA gehandelten Aktien einen Börsenplatzzusatz beim Ticker verlangt (etwa 7203.T anstelle von 7203 für Toyota).  

Das Ergebnis dieser Untersuchung zeigt, dass sechs Energie-Werte das Ranking der Top-10-Werte pro Sektor anführen.

<iframe height="550" width="100%" frameborder="no" src="https://jantau.github.io/highchart/single_stocks.html"> </iframe>

Das Unternehmen Canadian Natural Resources ist der Spitzenreiter. Die Firma, die ihr Geld mit Öl und Gas aus Kanada verdient, ist seit Jahresbeginn um 54 % gestiegen. Das US-amerikanische Öl- und Gas-Unternehmen ConocoPhillips liegt mit 48,6 % im Plus auf dem zweiten Rang. Auf den nächsten Plätzen folgen die Ölgiganten Chevron und ExxonMobil sowie mit Pioneer Natural Resources ein weiteres — richtig: Öl- und Gas-Unternehmen. Die schlechteste Top-10-Energie-Aktie ist das französische Unternehmen TotalEnergies, das mit etwa 6 % seit Jahresbeginn im Plus liegt.

Neben den Energie-Werten schneiden auch die Rohstoff-Werte und viele Industrie-Aktien gut ab. So sind die Bergbauunternehmen Glencore oder Newmore seit Jahresbeginn kräftig gestiegen (33 % und 31 %) ebenso wie die Waffenhersteller Lockheed Martin und Raytheon (29 % und 20 %). Das sind somit die Firmen, die vom Krieg in der Ukraine und den hohen Rohstoffpreisen profitieren.

Ganz am Ende des Rankings liegen Netflix und Meta, die sich noch nicht von [den schlechten Quartalszahlen](/post/faang-quarterly-reports/) erholt haben und wie viele andere Wachstumswerte insbesondere unter der Straffung der Geldpolitik leiden.

## Gewichtung der Top-10-Werte im MSCI World

Um die Erkenntnisse aus dem Sektorenvergleich und dem Ranking jedoch richtig einordnen zu können, fehlt noch eine weitere Variable. Welche Bedeutung haben die Energie-Werte eigentlich für den Gesamtmarkt? Die Antwort lautet: Der Einfluss des Energie-Sektors ist nicht wahnsinnig groß. Der MSCI-World besteht aus über 1500 Werten und nicht nur den 110 analysierten. Zusammen machen die 110 analysierten Werte allerdings 46 % des MSCI World aus (Stand 25.03.2022). Die zehn analysierten Energie-Werte haben zuletzt jedoch nur einen Anteil von 2,64 % am MSCI World ausgemacht, wohingegen die Top-10-IT-Aktien mit 12,9 % gewichtet sind. Der Energie-Sektor hat also einen begrenzten Einfluss auf die Wertentwicklung der großen Aktien-Indizes. 

<iframe height="550" width="100%" frameborder="no" src="https://jantau.github.io/highchart/sector_weight.html"> </iframe>

Für eine Einordnung der steigenden Energie- und Rohstoffpreise kann ich das [Finanzfluss-Interview mit Gerd Kommer](https://www.youtube.com/watch?v=V_CD8O3nXhg&t=382s) empfehlen, der betont, dass ein erheblicher Preisanstieg bei Energie und Rohstoffen regelmäßig eine Auswirkung von Krisen ist. Mittelfristig werden die Preise jedoch durch eine sichere wenn auch verzögerte Ausweitung der Förderung von Energie und Rohstoffen in beispielsweise zuvor unrentablen Gebieten sowie durch das Ende der Krise unter Druck geraten und letztendlich sinken. Ich hoffe, dass wir eher früher als später von einem Ende dieser Krise sprechen können.

Den für diesen Beitrag erstellten Code findest du hier: [https://github.com/jantau/jantau](https://github.com/jantau/jantau/tree/main/content/post)

Hat dir der Post gefallen? [Melde dich für meinen Newsletter an](https://tinyletter.com/jantau), um über neue Beiträge informiert zu werden.
