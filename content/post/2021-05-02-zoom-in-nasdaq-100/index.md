---
title: Zoom In Nasdaq 100
author: Jan Tau
date: '2021-05-02'
slug: zoom-in-nasdaq-100
categories: []
tags: [Nasdaq 100, Highcharter]
subtitle: 'Über die verschiedenen Dimensionen eines Aktienindizes und wie sie visualisiert werden können'
summary: 'Über die verschiedenen Dimensionen eines Aktienindizes und wie sie visualisiert werden können'
authors: []
lastmod: '2021-05-02T22:30:36+02:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
draft: true
---

## Visualisierung von Aktienindizes

Aktienindizes lassen sich einfach visualisieren. Sie haben einen Kurs, der in Punkten angegeben wird und eine Zeit, die in Jahren, Monaten, Tagen, Stunden usw. angegezeigt werden kann. Auf der X-Achse wird in der Regel die Zeit aufgetragen, auf der Y-Achse der Kursstand. Für den Nasdaq 100 kann das dann so aussehen.


Ein Aktienindex hat jedoch mehr Dimensionen als sein Kurstand zu einem bestimmten Zeitpunkt. Ein Aktienindex besteht aus Einzelwerten, die in unterschiedlicher Gewichtung im Index enthalten sind und die unterschiedlichen Wirtschaftssektoren zugeordnet sind. Darüber hinaus haben die Einzelwerte einen individuellen Kursverlauf, der sich stark vom Kursverlauf des Indizes unterscheiden kann.

Ich habe verschiedene Visualisierungen ausprobiert.

Am besten gefällt mir der Barplot. Er enthält vier Dimensionen. Es ist eine bekannte Visualisierung, die Gewichtung der Sektoren lässt sich gut abbilden, die Einzelwerte sind recht gut erkennbar und die Performance von Einzelwerten und von den Sektoren lassen sich gut erkennen.

Auch der Treemap Chart gefällt mir gut. Die Gewichtung von Sektoren und Einzelwerten lassen sich gut ablesen. Was mir jedoch nicht gelungen ist, ist die Kursentwicklung anhand der Farbhelligkeit darzustellen.

Der Bubble Chart enthält als einziger Chart fünf Dimensionen. Er zeigt die Ausreißer wie Tesla oder Moderna gut an. Leider führt das dazu, dass durchschnittliche Werte sich überschneiden und unübersichtlich geraten.

Der Packed Bubble Chart hat eine nette Animation. Er ist jedoch nicht sehr übersichtlich und stellt die Dimensionen nicht gut dar.


