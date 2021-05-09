---
title: Zoom In Nasdaq 100
author: Jan Tau
date: '2021-05-09'
slug: zoom-in-nasdaq-100
categories: []
tags: [Nasdaq 100, Highcharter]
subtitle: 'Über die verschiedenen Dimensionen eines Aktienindex und wie sie visualisiert werden können.'
summary: 'Über die verschiedenen Dimensionen eines Aktienindex und wie sie visualisiert werden können.'
authors: []
lastmod: '2021-05-09T00:30:36+02:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---

<style >
.article-container {
  max-width: 1200px;
  padding: 0 20px 0 20px;
  margin: 0 auto 0 auto;
  
}

.pt-3 {
  max-width: 800px;
  margin: 0 auto 0 auto;
}

.text {
  max-width: 760px;
  margin: 0 auto 0 auto;
}

.full {
  max-width: 1200px;
  margin: auto;
  left:0;
  right:0;
  top:auto;
  bottom:auto;
  padding: 20px 0 20px 0;
}

/* Alternative attempt to change the width of the charts */
.child {
    position:absolute;
    max-width: 1000px;
    margin: auto;
    left:0;
    right:0;
    top:auto;
    bottom:auto;
}

</style>

<div class = "text">

## Visualisierung von Aktienindizes

Aktienindizes lassen sich recht einfach visualisieren. Sie haben einen Kurs, der in Punkten angegeben wird, und eine Zeit, die in Jahren, Monaten, Tagen, Stunden usw. angezeigt werden kann. Auf der x-Achse wird in der Regel die Zeit aufgetragen, auf der y-Achse der Kursstand. Als Darstellungsform bietet sich ein Liniendiagramm an, dessen y-Achse wahlweise linear oder bei stark anwachsenden Werten logarithmisch skaliert ist.  Für den Nasdaq 100 sähe das dann für den Kursverlauf der letzten drei Jahre so aus:

<div class="full">
<iframe height="600" width="100%" frameborder="no" src="https://jantau.github.io/highchart/nasdaq_line_chart"> </iframe>
</div>

Ein Aktienindex hat jedoch mehr Dimensionen als seinen Kursstand zu einem bestimmten Zeitpunkt. Er besteht aus Einzelwerten, die in unterschiedlicher Gewichtung im Index enthalten und unterschiedlichen Wirtschaftssektoren zugeordnet sind. Darüber hinaus haben die Einzelwerte einen individuellen Kursverlauf, der sich stark vom Kursverlauf des Index unterscheiden kann.

Um diese Dimensionen eines Aktienindizes darzustellen, habe ich anhand des Nasdaq 100 verschiedene Visualisierungen erstellt. Die vier Charts sind ein Bar Chart, ein Treemap Chart, ein Bubble oder Scatter Chart und zuletzt ein Packed Bubble Chart, deren Vor- und Nachteile ich nun vorstellen möchte.

### Bar Chart
Am besten gefällt mir der Bar Chart für eine alternative Illustrierung des Nasdaq 100. Er enthält die vier Dimensionen Einzelwerte (x-Achse), Gewichtung der Einzelwerte (x-Achse), Gruppierung der Einzelwerte in Sektoren (y-Achse) und die Kursentwicklung über ein Jahr (Farbe). Ein Vorteil des Bar Charts ist zunächst, dass er eine etablierte Visualisierung ist, die einfach zu verstehen ist. Die Gewichtung der Sektoren lässt sich hervorragend durch die gestapelten Einzelwerte erkennen. Die größeren Einzelwerte sind zudem leicht identifizierbar und die Performance von Einzelwerten und Sektoren lässt sich durch die Farbgebung gut überblicken. So wird rasch ersichtlich, dass der IT-Sektor über 47 % am Nasdaq 100 ausmacht und Unternehmen aus dem Sektor Versorger lediglich zu 1 % vertreten sind. Die Farbgebung von hellen bis dunklen Grüntönen zeigt deutlich, dass die Werte aus den Sektoren Versorger und Nichtzyklische Konsumgüter im Vergleich zu den Sektoren IT, Kommunikation oder auch Zyklische Konsumgüter auf Einjahressicht underperformt haben. 

</div>

<div class="full">
<iframe height="600" width="100%" frameborder="no" src="https://jantau.github.io/highchart/nasdaq_bar_chart"> </iframe>
</div>

<div class = "text">

### Treemap Chart
Auch der Treemap Chart gefällt mir gut. Am prägnantesten ist hier die Gewichtung der Sektoren abgebildet. Durch das Anklicken der Sektoren lassen sich die Einzelwerte und ihre Gewichtung einfach überblicken. Was mir jedoch (noch) nicht gelungen ist, ist die Kursentwicklung des letzten Jahres anhand der Farbe darzustellen. Gerne würde ich anhand der Helligkeit der Sektorenfarben die Performance abbilden. Insoweit weist der Treemap Chart in diesem Beispiel nur drei Dimensionen auf, obwohl er durchaus Raum für eine weitere hätte, ohne überfrachtet zu wirken.

</div>

<div class="full">
<iframe height="600" width="100%" frameborder="no" src="https://jantau.github.io/highchart/nasdaq_treemap_chart"> </iframe>
</div>

<div class = "text">

### Bubble Chart
Der Bubble Chart enthält als einziger Chart fünf Dimensionen. Die einjährige Performance ist auf der y-Achse aufgetragen, die dreijährige auf der x-Achse. Die Kreise oder Bubbles sind die Einzelwerte, ihre Größe stellt die Gewichtung der Einzelwerte im Index dar und ihre Farbe die Sektorenzugehörigkeit. 

Der Vorteil dieser Darstellung ist zunächst, dass so fünf Datendimensionen abgebildet werden können. Sie hebt zudem die Ausreißerwerte im Index (wie etwa Tesla oder Moderna) hervor. Der Nachteil ist, dass durchschnittliche Werte nicht besonders gut erkennbar sind, da sie sich überschneiden. Es benötigt zudem etwas Zeit, um sich in die Achsen und verschiedenfarbigen Kreise "hineinzuschauen". Bei genauerer Betrachtung bietet der Bubble Chart jedoch interessante Einsichten, die in den anderen Charts nicht so anschaulich visualisiert werden. So kann man durch Anklicken der Legende einzelne Sektoren auswählen und miteinander vergleichen. Die Werte auf Sektorenebene können zudem explorativ nach möglichen Korrelationen untersucht werden. 

</div>


<div class="full">
<iframe height="600" width="100%" frameborder="no" src="https://jantau.github.io/highchart/nasdaq_bubble_chart"> </iframe>
</div>


<div class = "text">

### Packed Bubble Chart

Zuletzt habe ich noch einen Packed Bubble Chart erstellt. In dieser Visualisierung gibt es keine x-Achse und keine y-Achse. Die Einzelwerte werden als kleine Kreise oder Bubbles dargestellt, ihre Größe ist durch die Gewichtung der Einzelwerte im Index bestimmt. Ihre Farbe gibt die 1-Jahres-Performance wieder, ihre Gruppierung in größere Bubbles zeigt die Sektorenzugehörigkeit der Einzelwerte. Der Packed Bubble Chart hat eine ansprechende Animation. Er ist jedoch nicht sehr übersichtlich und stellt die Dimensionen aufgrund der schwer vergleichbaren Kreise und der fehlenden Achsen nicht optimal dar. So lässt sich beispielsweise anhand der Visualisierung nur schwer quantifizieren, welchen Anteil der IT-Sektor am Nasdaq 100 hat. 

</div>

<div class="full">
<iframe height="600" width="100%" frameborder="no" src="https://jantau.github.io/highchart/nasdaq_packedbubble_chart"> </iframe>
</div>

<div class = "text">

Es gibt also unterschiedliche Möglichkeiten, einen Aktienindex wie den Nasdaq 100 zu visualisieren. Sie haben unterschiedliche Stärken und Schwächen und können somit den Fokus auf verschiedene Aspekte des Index lenken. Der Treemap Chart stellt die Sektoren ins Zentrum, ein Bubble Chart die Einzelwerte, insbesondere die mit einer weit überdurchschnittlichen Performance. Bis auf den Packed Bubble Charts sind sie alle gut geeignet, um die unterschiedlichen Aspekte eines Aktienindex zu illustrieren.

Den für diesen Beitrag erstellten Code findest du hier: [https://github.com/jantau/jantau](https://github.com/jantau/jantau/tree/main/content/post)

Hat dir der Post gefallen? [Melde dich für meinen Newsletter an](https://tinyletter.com/jantau), um über neue Beiträge informiert zu werden.

</div>

