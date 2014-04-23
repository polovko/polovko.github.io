---
layout: post
title: "noNamePost(2)"
date: 2012-10-01 01:43
comments: true
keywords: java новости, статьи о java, книги о java
categories: news articles books fun
---

## Новости

* Вышла первая бета библиотеки логирования - [Log4j 2](http://logging.apache.org/log4j/2.x/). Улучшили [производительность](http://logging.apache.org/log4j/2.x/performance.html), добавили [асинхронный аппендер](http://logging.apache.org/log4j/2.x/manual/appenders.html#AsynchAppender), пофиксили [много багов](http://logging.apache.org/log4j/2.x/changes-report.html#a2.0-beta1). {% tags log4j %}
* Oracle выложила видео и слайды с прошедшей этим летом конференции [JVM Language Summit](http://openjdk.java.net/projects/mlvm/jvmlangsummit/), посвященной разработке языков программирования под JVM и разработке самой JVM. {% tags conference video %}
* Вышли новые версии Java Embeded от Oracle - [Java ME Embeded 3.2](http://www.oracle.com/technetwork/java/embedded/overview/javame/index.html) (Java ME, оптимизированная для работы на устройствах с очень маленькими микроконтроллерами) и [Java Embedded Suite 7.0](http://www.oracle.com/technetwork/java/embedded/overview/java-embedded-suite/index.html) (интегрированный стек промежуточного ПО для встраиваемых устройств). {% tags jme embeded %}
* [Jigsaw отложили](http://mreinhold.org/blog/on-the-next-train) до выхода Java 9. Целью проекта Jigsaw является разработка и внедрение стандартной модульной системы для платформы Java SE, а также применение этой системы к самой платформе и JDK. Что-то среднее между модулями в maven (этап сборки) и модулями OSGi (этап выполнения). {% tags jigsaw jcp %}
* Проект [Apache Hadoop выиграл](http://www.cloudera.com/blog/2012/09/apache-hadoop-wins-dukes-choice-award-is-a-java-ecosystem-mvp/) награду Duke's Choice Award тем самым получив статус наиболее значимого продукта в экосистеме Java (MVP, Most Valuable Player). [Проекты](http://java.com/en/dukeschoice/), получившие награду в прошлом году. {% tags hadoop %} <!-- more -->
* В предстоящий [релизе MySQL 5.6.7](http://www.oracle.com/us/corporate/press/1855300) включили [усовершенствования InnoDB Memcached](https://blogs.oracle. com/mysqlinnodb/entry/new_enhancements_for_innodb_memcached). Из фич: поддержка маппинга нескольких таблиц; добавлен фоновый поток, выполняющий автокоммит длительных транзакций; улучшена производительность бинлога. {% tags mysql nosql %}
* Сегодня на Coursera стартовала вторая версия [курса, посвященного разработке компиляторов](https://class.coursera.org/compilers-2012-002/). Ведет курс профессор стэндфордского университета Алекс Эйкен. По опыту первой версии могу сказать, что теория будет рассматриваться на примере языка программирования COOL (Classroom Object Oriented Language), а также вся последняя лекция будет посвящена Java. {% tags compilers coursera %}
* [Сентябрьский выпуск](http://www.oracle.com/technetwork/java/javamagazine/index.html) журнала Java Magazine. Если кто еще не подписался очень советую это сделать. {% tags magazine %}

## Статьи

* Авторы книги [Akka in Action](http://www.manning.com/roestenburg/) - Raymond Roestenburg и Rob Bakker написали про то [как тестировать акторы в Scala](http://weblogs.java.net/blog/manningpubs/archive/2012/09/28/testing-actors-akka). {% tags akka testing %}
* [Статья](http://habrahabr.ru/post/152765/) о том как запускать DBDeploy из скрипта Gradle. {% tags db gradle %}
* [Шаблоны проектирования для функционального программирования](http://www.ibm.com/developerworks/ru/library/j-ft10/index.html). На примерах в Scala и Groovy Нил Форд рассмотрел шаблоны Factory, Strategy, Singleton и Template Method реализованные в функциональном стиле. {% tags funprog %}
* [5 шагов](http://blogs.atlassian.com/2012/09/5-steps-to-build-a-killer-dashboard/) как настроить удобный дашборд в Jira. Взял на заметку. {% tags jira tips %}

## Книги

Недавно вышедшие книги по Java и связанным с ней технологиям:

* Второе издание [Real World Java EE Patterns-Rethinking Best Practices](http://www.lulu.com/shop/adam-bien/real-world-java-ee-patterns-rethinking-best-practices/paperback/product-20372080.html) по Java EE 6. {% tags jee %}
* Arun Gupta - [Java EE 6 Pocket Guide](http://shop.oreilly.com/product/0636920026464.do). {% tags jee %}
* Edward Capriolo, Dean Wampler, Jason Rutherglen - [Programming Hive](http://shop.oreilly.com/product/0636920023555.do). {% tags hive %}

## Разное

* ["Локаничное" имя класса](http://javadoc.bugaco.com/com/sun/java/swing/plaf/nimbus/InternalFrameInternalFrameTitlePaneInternalFrameTitlePaneMaximizeButtonPainter.html) в Swing длинной 79 символов. Интересно как такое могли принять? {% tags geekfun %}
* Еще один [видео-прикол](http://www.youtube.com/watch?v=gR1PujzQ53Q&feature=plcp) на тему .NET vs Java. Плакал после "мой сын монстр!" :) {% tags geekfun video %}
