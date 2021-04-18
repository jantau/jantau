---
title: Ist der Nasdaq wieder in der Bubble?
author: Jan Taubitz
date: '2021-04-18'
slug: nasdaq-bubble
categories: []
tags: [NASDAQ 100, Allzeithoch]
subtitle: 'Über die Jahre vor der Dotcom-Blase im Vergleich zur heutigen Situation.'
summary: 'Über die Jahre vor der Dotcom-Blase im Vergleich zur heutigen Situation.'
authors: []
lastmod: '2021-04-18T11:00:30+02:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---

## Der Nasdaq erreicht im April 2021 neue Höchststände

Nachdem in den vergangen Wochen der Dax 30 und der S&P 500 neue Höchststände erreichten, hat nun auch der NASDAQ 100 aufgeschlossen und die Höchststände aus dem Februar (und die 14000-Punkte-Marke) übertroffen.

Neue Höchststände sind regelmäßig der Anlass, um vor Börsenblasen oder dem nächsten Crash zu warnen. [So auch in dieser Woche.](https://seekingalpha.com/article/4419329-nasdaq-entering-mighty-bubble) 

Und betrachtet man den Chartverlauf seit 1995, sieht es tatsächlich bedrohlich aus. Selbst die berüchtigte Dotcom-Blase erscheint im Vergleich der letzten Jahre harmlos. Bereits seit fünf Jahren entwickelt sich der Nasdaq ausgesprochen gut. In den letzten zwei Jahren hat er dann noch weiter Fahrt aufgenommen.

<iframe height="500" width="150%" frameborder="no" src="https://jantau.github.io/highchart/ndx_1995_today"> </iframe>

Dass die Entwicklung so extrem erscheint, liegt an der linearen Skalierung der Y-Achse, die die imposanten Entwicklungen bei den niedrigeren absoluten Kursständen der Vergangenheit herunterspielt.

## Logarithmische Darstellung

Um sowohl die Entwicklung bei den niedrigen als auch bei den hohen Werten gleichwertig darzustellen, bietet sich eine logarithmische Skalierung an. Bei dieser ist der [Abstand zwischen jeder Vervielfachung identisch](https://www.youtube.com/watch?v=PyIaVNwY4vE). Das bedeutet beispielsweise, dass der Abstand zwischen 10 und 20 genauso groß ist wie der zwischen 1000 und 2000. In der linearen Darstellung ist der Abstand zwischen 1000 und 2000 hingegen einhundertmal so groß wie der zwischen 10 und 20.

<iframe height="500" width="100%" frameborder="no" src="https://jantau.github.io/highchart/ndx_1995_today_logs"></iframe>

Die logarithmische Visualisierung zeigt, dass der Kursverlauf in den Jahren vor der Dotcom-Blase steiler war als die derzeitige Entwicklung.

Besonders deutlich werden die Unterschiede jedoch erst, wenn man die prozentuale Entwicklung gleichlanger Zeitabschnitte betrachtet.

## Die Jahre vor der Dotcom-Blase im Vergleich zur heutigen Situation 

Ich schaue mir also den prozentualen Kursgewinn der letzten fünf Jahre vor der Dotcom-Blase, der Finanzkrise und den aktuellen Höchstständen an und beginne bei allen drei Perioden bei 0 %.

<iframe height="500" width="100%" frameborder="no" src="https://jantau.github.io/highchart/ndx_periods"> </iframe>

Diese Darstellung zeigt, wie extrem die in der Dotcom-Blase gipfelnde Entwicklung war. Der Nasdaq hat in den fünf Jahren vor dem Platzen der Blase über 900 % zugelegt und eine jährliche Wachstumsrate oder [Compound Annual Growth Rate (CAGR)](https://www.investopedia.com/terms/c/cagr.asp) von spektakulären 59 % erzielt. Dagegen wirken die etwa 200 % Kursgewinn der letzten fünf Jahre, die eine jährliche Wachstumsrate von 25 % bedeuten, regelrecht unauffällig. 

Das soll nicht bedeuten, dass es nicht zu einem Crash kommen kann. Wie die Finanzkrise gezeigt hat, muss es nicht eine platzende Aktienblase sein, um die Weltwirtschaft in eine große Krise zu stürzen. In den fünf Jahren vor der Finanzkrise hat der Nasdaq beispielsweise etwa 125 % zugelegt (jährliche Wachstumsrate 18 %) und stand beim Ausbruch der Krise noch über 50 % unter den Dotcom-Höchstständen, die sieben Jahre zuvor erreicht worden waren. 

Es bedeutet auch nicht, dass wir nicht in einer Blase sind, denn auch die Entwicklung der letzten Jahre ist weit überdurchschnittlich, wenn man sie in Bezug zur jährlichen Wachstumsrate von 1995 bis 2020 setzt, die 14 % betrug. 

Die Darstellung zeigt jedoch, dass die derzeitigen Kurse noch lange nicht im Dotcom-Blasen-Territorium sind. Hierfür muss noch einiges passieren. Gegen die 900 % Kursanstieg vor der Dotcom-Blase nehmen sich die 200 % Kursanstieg der letzten fünf Jahre jedenfalls deutlich weniger spektakulär aus. 

Den für diesen Beitrag erstellten Code findest du hier: [https://github.com/jantau/jantau](https://github.com/jantau/jantau/tree/main/content/post)


