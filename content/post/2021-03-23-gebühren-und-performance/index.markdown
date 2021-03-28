---
title: Renditeverlust durch Gebühren
author: Jan Tau
date: '2021-03-23'
slug: renditeverlust
categories: []
tags: [ETF, "S&P 500", "NASDAQ 100", "Dax 30", Shiny]
subtitle: 'Über die Bedeutung von Verwaltungs- und Ordergebühren für die Performance von ETF-Sparplänen'
summary: 'Über die Bedeutung von Verwaltungs- und Ordergebühren für die Performance von ETF-Sparplänen'
authors: []
lastmod: '2021-03-23T22:04:26+01:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
math: true
---



## Verwaltungs- und Ordergebühren

Ich habe mich gefragt, welche Auswirkungen Gebühren auf die Performance von ETF-Sparplänen haben.

Die Gebühren für ETFs bestehen in der Regel aus einer jährlichen Verwaltungsgebühr (Total Expense Ratio) und aus Transaktionskosten oder Ordergebühren, die beim Kauf und Verkauf anfallen. Die jährliche Verwaltungsgebühr wird von dem ETF-Anbieter erhoben und beträgt bei [sehr günstige ETFs 0,04 %](https://www.justetf.com/de-en/find-etf.html?assetClass=class-equity&sortField=ter&sortOrder=asc&groupField=none&tab=overview) und bei [teuren ETFs bis zu 0,95 %](https://www.justetf.com/de-en/find-etf.html?assetClass=class-equity&sortField=ter&sortOrder=desc&groupField=none&tab=overview). Die Transaktionskosten fließen an die depotführende Bank und betragen [zwischen 0 % und 2,5 %](https://www.finanzfluss.de/vergleich/etf-sparplan/).

Auch aktiv gemanagte Investmentfonds erheben eine jährliche Verwaltungsgebühr (oft Managementgebühr genannt) und eine Transaktionsgebühr (Ausgabeaufschlag). Diese sind jedoch wesentlich höher als bei passiven Anlageprodukten. So kann von einer jährlichen Managementgebühr von 1,5 % ausgegangen werden und von einem Ausgabeaufschlag von 4 % ([siehe beispielsweise Deka-Fonds](<https://www.deka.de/privatkunden/fondssuche>)).

Klar, diese Gebühren wirken sich negativ auf die Performance der Index- oder Investmentfonds im Vergleich zu ihren Benchmarks aus. Indexfonds oder ETFs verlieren jährlich die Verwaltungsgebühr auf den replizierten Index (es sei denn, der Tracking Error ist negativ) und Investmentfonds müssten ihren Bench jährlich um die Managementgebühr von beispielsweise 1,5 % schlagen, um eine identische Performance zu erzielen. Hinzu kommen die Transaktionsgebühren, die nicht monatlich oder jährlich zu Buche schlagen, sondern beim Einstieg (und ggf. beim Ausstieg).

Die Gebühren werden von den Depotbanken und den ETF- beziehungsweise Fondsanbietern genannt und sind somit ziemlich transparent. Nicht transparent ist jedoch, wie sich diese Gebühren tatsächlich auf die Rendite auswirken. Das liegt am Zinseszinseffekt, dessen negatives exponentielles Wachstum erst nach einigen Jahren deutlich wird und dessen Auswirkungen intuitiv schwer abzuschätzen sind.

Was bedeutet es also für die langjährige Rendite, wenn ein passiver Indexfonds eine Verwaltungsgebühr von 0,2 % und eine Ordergebühr von 1 % hat oder ein aktiver Investmentfond eine Managementgebühr von 1,5 % und einen Ausgabeaufschlag von 4 %?

## Renditeverlust

Ich habe einen Kostenrechner programmiert, der den Renditeverlust durch diese Gebühren berechnet.

Die Datengrundlage sind nicht eine angenommene feste Verzinsung (wie in existierenden Rechnern), sondern die historischen Kursverläufe von S&P 500, NASDAQ 100 und Dax 30.

Im Rechner können monatliche Einzahlungen und/oder eine einmalige Zahlung zu Beginn des Anlagezeitraums definiert werden. Zusätzlich können Gebühren festgelegt werden. Bei der jährl. Verwaltungsgebühr (TER) oder dem Tracking Error in % wird ein Zwölftel der Gebühr monatlich vom Investitionsvolumen abgezogen. Die Ordergebühr in % wird einmalig von den Einlagen (monatlich oder einmalig) abgezogen.

Der Kostenrechner visualisiert die Entwicklung der Anlage vor und nach Gebühren. Zusätzlich werden die Gebühren im Verhältnis zum Endbetrag des gesamten Investitionsvolumen.

Zusätzlich wird der Renditeverlust berechnet. Er ist definiert als:

$$
1-\frac{Endbetrag\_nach\_Kosten-Ansparsumme}{Endbetrag\_vor\_Kosten-Ansparsumme}
$$

Für mich ist der Renditeverlust die entscheidende Größe. Beim Investieren interessiert mich, um wieviel Prozent oder um welchen Wert der investierte Betrag gewachsen (oder gesunken) ist. Analog hierzu möchte ich wissen, um wie viel Prozent meine Rendite durch die Gebühren reduziert wurde. Der Renditeverlust über den gesamten Investitionszeitraum zeigt meines Erachtens deutlicher die Bedeutung von Gebühren.

Über den Kostenrechner können die historischen Kursverläufe von 1990 bis heute genutzt werden, um die Auswirkungen von Gebühren auf die Renite bei monatlichen Einzahlungen oder bei einer einmaligen Einzahlung zu überprüfen.

<iframe height="1200" width="100%" frameborder="no" src="https://jantau.shinyapps.io/ter_surcharge/"> </iframe>

Ein paar Beispiele:

Bei einem thesaurierenden ETF auf den S&P 500 mit einer jährlichen Gebühr von 0,1 % und einer Ordergebühr von 1 % hätte ich bei einem monatlichen Sparplan von 2010 bis 2021 einen Renditeverlust von 2,9 % zu verzeichnen.

Bei einem fiktiven Investmentfonds auf den S&P 500 mit einer jährlichen Gebühr von 1,5 % und einer Ordergebühr von 4 % hätte ich bei einem monatlichen Sparplan von 2010 bis 2021 einen Renditeverlust von 23 % zu verzeichnen.

Der gleiche Sparplan nicht für 11 Jahre bespart, sondern für 31 Jahre (Anfang 1990 bis Anfang 2021) verzeichnet bei derselben Kostenstruktur einen Renditeverlust von 36 %.

Das Beispiel mit dem Investmentfonds zeigt eindrucksvoll, warum das Investieren mit einer solchen Kostenstruktur keinen Sinn ergibt, da Fonds ihre Benchmark deutlich übertreffen müssen, um den durch Gebühren verursachten Renditeverlust zu übertreffen.

Die Zahlen täuschen. 1,5 % Verwaltungsgebühr und 4 % Ausgabeaufschlag klingen bereits heftig. Dass das nach zehn Jahren bei einem S&P 500 Kursverlauf einen Renditeverlust von 29 % bedeutet, geben die Zahlen nicht ohne einen fokussierten Blick her.

Den für diesen Beitrag erstellten Code findest du hier: [https://github.com/jantau/jantau](https://github.com/jantau/jantau/tree/main/content/post){target="_blank"}

Das Problem ist die jährliche Gebühr. Die bei den Kosten verschleiert wird. So lässt der [Deka Wertentwicklungsrechner](https://www.deka.de/privatkunden/wertentwicklungsrechner?_eventId=indexWithIsin&isin=LU1138302630) den Ausgabeaufschlag integrieren, aber nicht die Verwaltungsgebühr und auch nicht die Erfolgsprämie.

Ich habe einen historischen Kostenrechner programmiert, der die Bedeutung von Gebühren un

Kostenrechner gibt es bereits. Sie berücksichtigen keine Sparpläne und sie beziehen sich auf angenommene Renditen.

Hier der [Rechner von der Australian Securities and Investments Commission](https://moneysmart.gov.au/managed-funds-and-etfs/managed-funds-fee-calculator){target="_blank"}

Oder die Rechner von [zinsen-berchnen.de](https://www.zinsen-berechnen.de/fondsrechner.php){target="_blank"}

[justetf](https://www.justetf.com/de/cost-calculator.html){target="_blank"}

[ETFs sind dummes Geld](https://www.youtube.com/watch?v=8LWCupBMXqc){target="_blank"}
