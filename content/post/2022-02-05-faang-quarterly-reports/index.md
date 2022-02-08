---
title: "Ist der Mythos FAANG am Ende?"
author: "Jan Tau"
date: '2022-02-08'
slug: faang-quarterly-reports
categories: []
tags: []
subtitle: Über die FAANG-Werte nach Quartalsberichten
summary: Über die FAANG-Werte nach Quartalsberichten
authors: []
lastmod: '2022-02-08T09:51:04+01:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---
## FAANG Is Dead!
FAANG Is Dead!, [heißt es in letzter Zeit häufiger.](https://www.forbes.com/sites/petercohan/2022/02/07/faang-is-dead-long-live-aaa/?sh=55cce2a2a751) Und das liegt nicht daran, dass durch die Umbenennung von Facebook in Meta das Akronym FAANG (Facebook, Apple, Amazon, Netflix, Google) seine Berechtigung verloren hat und Jim Cramer von "Mad Money", der seinerzeit FAANG popularisiert hatte, bereits [MAAMA](https://www.cnbc.com/2021/10/29/cramer-new-acronym-to-replace-faang-after-facebook-name-change-to-meta.html) (Netflix raus, Microsoft rein) als zukünftigen Motor des Aktienmarktes ankündigte. 

Nein, die Werte selbst schwächeln. Das haben beispielsweise die Berichte zum 4. Quartal 2021 gezeigt, die in den letzten Wochen veröffentlicht wurden. Es begann nach Handelsschluss am 20.1.2022 mit Netflix. Netflix verfehlte die Erwartungen deutlich und gab eine düstere Prognose für das zukünftige Wachstums ab, so dass der Wert im außerbörslichen Handel heftig abschmierte und am nächsten Tag mit 21,2 % im Minus eröffnete. Apple und Google zeigten zwar in den darauffolgenden zwei Wochen gute bis sehr gute Zahlen und Aussichten, aber am 2.2.2022 schockte Meta (*fomerly known as* Facebook) die Märkte, als es im Quartalsbericht bekanntgab, dass im abgelaufenen Quartal zum ersten Mal ein Rückgang der zentralen Metrik "tägliche Nutzer" verzeichnet wurde. Zudem unterschritt die Umsatzvorhersage für das 1. Quartal 2022 die Erwartungen der Analysten erheblich. Es ist zurzeit völlig unklar, ob sich die hohen Investitionen in das [Metaverse](https://www.wired.com/story/what-is-the-metaverse/) — das *next generation internet* — jemals bezahlt machen. Facebook verlor über Nacht 24,3 % und damit mehr als 230 Milliarden USD Marktwert, womit es einen neuen Rekord für den größten Eintagesverlust bezogen auf die absolute Marktkapitalisierung aufstellte. 

Die schlechten Zahlen von Facebook würgten umgehend den Rebound nach den deutlichen Marktrücksetzern im Januar ab. Letztendlich wurde dieser am darauffolgenden Tag (3.2.2022) von Amazons sehr guten Quartalszahlen gerettet.

## Nachbörsliche Kursreaktion auf Quartalsberichte

Das Hin und Her und die heftigen Ausschläge der aktuellen Berichtssaison (Facebook und Netflix über 20 % runter, Amazon und Google über 10 % rauf) zeigen, dass die Veröffentlichung eines Quartalsberichts die Erwartungen der Aktionäre durch offizielle Zahlen und Ausblicke kalibriert. Das veranlasst mich dazu, einmal genauer auf die unmittelbaren Auswirkungen der Quartalsberichte auf den Börsenkurs der berichtenden Unternehmen zu schauen. 

Die Quartalsberichte werden in der Regel nach Börsenschluss, also nach 16 Uhr EST, veröffentlicht. Die unmittelbaren Kursreaktionen finden somit nachbörslich statt. Um zu ermitteln, wie der Quartalsbericht aufgenommen wurde, kann demnach der Eröffnungskurs am nächsten Tag mit dem Schlusskurs des Berichtstages verglichen werden. Dies führe ich für die FAANG-Werte für den Zeitraum 2. Quartal 2012 bis 4. Quartal 2021 durch, was den Zeitraum umfasst, in dem alle FAANG-Unternehmen börsennotiert sind. (Zur Erinnerung, Facebooks IPO (Initial Public Offering) war am 18.5.2012.)

Die historischen Daten zu den Tagen der Quartalsberichte zu bekommen, war etwas umständlich, da es für diese Daten keine offenen Schnittstellen gibt und ich mich mit Webscraping behelfen musste, was immer etwas *messy* und mit anschließender Datenbereinigung verbunden ist. Die Kursdaten der betreffenden Tage habe ich über die Yahoo!-Finance-Schnittstelle bezogen. (Der Code kann wie immer auf [GitHub nachvollzogen werden](https://github.com/jantau/jantau/tree/main/content/post).) Durch das Zusammenführen dieser beiden Datenströme kann ich analysieren und visualisieren, welche Auswirkungen die Quartalsberichte auf den Aktienkurs haben.

Der Chart zeigt den Abstand des Eröffnungskurses zum Schlusskurs des Vortages nach der nachbörslichen Veröffentlichung von Quartalszahlen für die fünf FAANG-Werte von Q2 2012 bis Q4 2021.

<iframe height="700" width="100%" frameborder="no" src="https://jantau.github.io/highchart/faang_openings.html"> </iframe>

Die Auswirkungen der Quartalsberichte auf die direkte nachbörsliche Kursentwicklung sind erheblich! Zusammen haben die FAANG-Unternehmen in den 39 Quartalen von 2012 bis 2021 195 Quartalsberichte veröffentlicht. In 80 % der Fälle waren die Kursprünge stärker als 1,5 % nach oben oder nach unten, was bedeutet, dass in vier von fünf Fällen die Erwartungen der Aktionäre und Analysten entweder übertroffen oder unterboten wurden. In der Regel wurden die Erwartungen dabei übertroffen. Der durchschnittliche Kursgewinn nach Quartalszahlen liegt bei 1,36 %, wobei die Standardabweichung 8,35 % beträgt, was bedeutet, dass 65 % der Handelstage nach Quartalsberichten in der Spanne zwischen -6,99 % (1,36-8,35) und +9,71 % (1,36+8,35) eröffneten. Die maximalen Kursausschläge betrugen 39,4 % Prozent nach oben (Netflix im Q4 2012) und 25,8 % nach unten (Netflix im Q3 2013).

Um diese Zahlen besser beurteilen zu können, habe ich die durch Quartalszahlen beeinflussten Tage einmal herausgefiltert und nur die "normalen Handelstage" berücksichtigt. Im Durchschnitt starteten die FAANG-Werte dann lediglich 0,07 % über dem Schlusskurs des Vortages. Die Standardabweichung betrug in diesen Fällen 1,01 %, was bedeutet, dass an 65 % der normalen Handelstage die Kurse in der Spanne zwischen -0,94 % und +1,08 % im Vergleich zum Vortagesschlusskurs eröffneten.

Die unterschiedliche Verteilung der nachbörslichen Kursentwicklung nach Quartalszahlen kann gut durch einen Density-Chart (oder Dichtediagramm, gewissermaßen ein geglättetes Histogramm) visualisiert werden. (Durch Doppelklick auf Elemente der Legende kann nach Werten gefiltert werden.)

<iframe height="450" width="100%" frameborder="no" src="https://jantau.github.io/highchart/faang_density.html"> </iframe>

Facebooks Kurve zeigt eine Schulterformation. Es gibt eine Reihe recht extremer Reaktionen, die sowohl positiv als auch negativ waren (die Schultern). Die Mehrzahl der Daten liegt jedoch eng an der Nulllinie beziehungsweise am Durchschnitt, der für Facebook bei 1,6 % liegt (der Kopf). Netflix zeigt mit Abstand die breiteste und damit auch flachste Verteilung. Bei Netflix überraschen die Zahlen somit regelmäßig Aktionäre und Analysten erheblich. Bei Apple und Google liegt der Höhepunkt der Dichte deutlich rechts der Nulllinie, was auf viele positive Überraschungen hinweist, wobei die Verteilung nicht so breit ist wie bei Netflix oder Facebook oder auch Amazon, und die extremen Ausschläge über 20 % fehlen. 

Die wichtigsten Kennzahlen in tabellarischer Form zeigen, dass Google der beste Wert ist, den man vor Veröffentlichung der Quartalsberichte in den letzten zehn Jahren haben konnte. Im Mittel ging es um 2,3 % nach oben, wobei Google die geringste Standardabweichung (SD) aufwies, die meisten Werte also relativ eng um den Mittelwert schwankten. Etwas anders sieht es bei Facebook und Netflix aus. Sie belegen mit 1,6 % und 1,5 % Platz 2 und 3, wobei Investoren jedoch eine wesentlich höhere Volatilität (SD 9,6 % und SD 13,1 %) verkraften mussten.


| Aktie | ⌀ Öffnungskurs zum<br>Schlusskurs Vortag| SD|
|--------|:--------------------:|--------------------:|
| FB     | 1.6 %                | 9.6 %               |
| AAPL   | 0.6 %                | 4.8 %               |
| AMZN   | 0.9 %                | 6.8 %               |
| NFLX   | 1.5 %                | 13.1 %              |
| GOOG   | 2.3 %                | 4.7 %               |


Nicht nur die Einzelwerte unterscheiden sich voneinander, auch von Quartal zu Quartal sind die Reaktionen verschieden. Die Zahlen des 4. Quartals riefen bei hoher Volatilität im Mittel die stärkste Kursreaktion hervor, wohingegen die Ergebnisse des 2. Quartals als einzige im Durchschnitt eine leicht negative Kursreaktion nachsichzogen.


| Quartal 	| ⌀ Öffnungskurs zum<br>Schlusskurs Vortag 	| SD   	|
|---------	|:------:|------:|
| 1       	| 2.3 %  	| 6.3 %  	|
| 2       	| -0.1 % 	| 8.3 %  	|
| 3       	| 0.6 %  	| 7.9 %  	|
| 4       	| 2.7 %  	| 10.2 % 	|


## Hat FAANG eine Zukunft?

Was sagen diese Analysen nun über die Zukunft der FAANG-Werte aus? Grundsätzlich sind starke Kursausschläge nach Quartalszahlen für die FAANG-Unternehmen nichts Ungewöhnliches. Die Kurse sprangen auch in der Vergangenheit teilweise heftig in beide Richtungen. Im Durchschnitt ging es nach Quartalszahlen jedoch nach oben, was in den letzten zehn Jahren sicherlich auch den Mythos der FAANG-Aktien genährt hat, der endloses, hohes Wachstum und positive Überraschungen versprach.

Die Kursreaktionen auf das abgelaufene Quartal zeigten vier negative Besonderheiten, die andeuten, dass der Mythos FAANG deutliche Kratzer bekommen hat. 1. Von 39 Quartalen im Untersuchungszeitraum waren die Reaktionen auf das abgelaufene die viertschlechtesten. Schlechter schnitten nur Q3 2014, Q2 2012 und Q2 2018 ab. 2. Das abgelaufene Quartal war  das schlechteste 4. Quartal im Untersuchungszeitraum. Das ist bemerkenswert, da das 4. Quartal im Mittel das stärkste ist. 3. Das letzte Quartal war zudem das erste Quartal, in dem zwei Werte mehr als 20 % eingebüßt haben. Und 4. zum ersten Mal zogen Quartalsberichte dreimal in Folge negative Kursentwicklungen nach sich. Zuvor gab es nur maximal zwei negative Quartale nacheinander (Q2 2014 und Q3 2014 sowie Q2 und Q3 2018). Diese Ergebnisse sind beunruhigend für den weiteren Ausblick und es ist spannend, wie Q1 2022 bewertet wird. 

Meines Erachtens ist es zu früh, das Ende von FAANG auszurufen und sich auf [AAA](https://www.forbes.com/sites/petercohan/2022/02/07/faang-is-dead-long-live-aaa/?sh=55cce2a2a751) (Apple, Amazon, Alphabeth (alias Google)) zu konzentrieren. Facebook und Netflix sind traditionell am volatilsten und haben es in den letzten Jahren wiederholt geschafft, von schlechten Ergebnissen gestärkt zurückzukommen. Darüber hinaus sind Facebook und Netflix zwar bedeutende Werte, sie sind jedoch nicht so groß und wichtig wie Apple, Google und Amazon. Die drei Werte mit der höheren Marktkapitalisierung haben die Erwartungen im letzten Quartal deutlich überdurchschnittlich übertroffen. Sollte das nächste Quartal einen weiteren Kursrutsch nach sich ziehen, müssen wir noch einmal über die Zukunft von FAANG sprechen.

Den für diesen Beitrag erstellten Code findest du hier: [https://github.com/jantau/jantau](https://github.com/jantau/jantau/tree/main/content/post)

Hat dir der Post gefallen? [Melde dich für meinen Newsletter an](https://tinyletter.com/jantau), um über neue Beiträge informiert zu werden.