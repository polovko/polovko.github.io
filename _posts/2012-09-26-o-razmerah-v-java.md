---
layout: post
title: "О размерах в Java"
date: 2012-09-26 12:17
comments: true
keywords: java, jvm, hotspot, размер объекта, типы данных в java
categories: hotspot jvm
---

Задался недавно вопросом: "Как правильно оценить размер выделяемой памяти под объекты в Java?". На хабре есть несколько статей [[1]](http://habrahabr.ru/post/134102/), [[2]](http://habrahabr.ru/post/134910/) посвященных этому вопросу. Но мне не совсем понравился подход, использованный авторами. Поэтому решил заглянуть внутрь OpenJDK Hotspot VM (далее по тексту Hotspot) и попытаться понять как все устроено на самом деле.

## Типы данных в Java

* Примитивы. (byte, short, char, int, float, long, double, boolean).
* Объекты. Размер объекта зависит от конкретной реализации VM и архитектуры процессора. Поэтому дать однозначный ответ не получится. Все же хочется понять (на примере конкретной VM) какой размер памяти выделяется под java-объект.
* Массивы. Одномерные линейные структуры, которые могут содержать все перечисленные типы (включая другие  массивы). Массивы также являются объектами, но со специфичной структурой. <!-- more -->

### Примитивы

С размером примитивов все понятно - их размер определен в спецификации языка ([JLS 4.2](http://docs.oracle.com/javase/specs/jls/se7/html/jls-4.html#jls-4.2)) и спецификации jvm ([JVMS 2.3](http://docs.oracle.com/javase/specs/jvms/se7/html/jvms-2.html#jvms-2.3)). Интересно заметить, что для типа boolean jvm использует int, а не byte как могло бы показаться ([JMS 2.3.4](http://docs.oracle.com/javase/specs/jvms/se7/html/jvms-2.html#jvms-2.3.4)). Также интересно, что при создании массива boolean[] под каждый элемент массива будет выделен 1 байт, а не 4.

<table class="table table-bordered table-center">
<thead>
	<tr>
		<th>тип</th>
		<th>размер (байт)</th>
		<th>размер в массиве (байт)</th>
		<th>допустимые значения</th>
	</tr>
</thead>
<tbody>
	<tr><td>byte</td><td>1</td><td>1</td><td>-128 .. 127</td></tr>
	<tr><td>short</td><td>2</td><td>2</td><td>-32768 .. 32767</td></tr>
	<tr><td>chart</td><td>2</td><td>2</td><td>'\u0000' .. '\uffff'</td></tr>
	<tr><td>int</td><td>4</td><td>4</td><td>-2147483648 .. 2147483647</td></tr>
	<tr><td>float</td><td>4</td><td>4</td><td>-3.4028235e+38f .. 3.4028235e+38f</td></tr>
	<tr><td>long</td><td>8</td><td>8</td><td>-9223372036854775808 .. 9223372036854775807</td></tr>
	<tr><td>double</td><td>8</td><td>8</td><td>-1.7976931348623157e+308 .. 1.7976931348623157e+308</td></tr>
	<tr><td>boolean</td><td>4</td><td>1</td><td>false, true</td></tr>
</tbody>
</table>


### Объекты

Для описания экземпляров массивов Hotspot использует класс [arrayOopDesc](http://hg.openjdk.java.net/jdk6/jdk6/hotspot/file/tip/src/share/vm/oops/arrayOop.hpp), для описания остальных Java-классов используется класс [instanceOopDesc](http://hg.openjdk.java.net/jdk6/jdk6/hotspot/file/tip/src/share/vm/oops/instanceOop.hpp). Оба эти класса наследуются от [oopDesc](http://hg.openjdk.java.net/jdk6/jdk6/hotspot/file/tip/src/share/vm/oops/oop.hpp) и оба содержат методы для вычисления размера заголовка. Так например a instabceOopDesc вычисляет размер заголовка (в машинных словах) следующим образом:

{% highlight cpp %}
static int header_size() { return sizeof(instanceOopDesc)/HeapWordSize; }
{% endhighlight %}

 где HeapWordSize определяется как размер указателя. В зависимости от архитектуры CPU 4 и 8 байт для x86 и x86_64 (в Oracle именуют x64) соответственно.
 Чтобы понять размер instanceOopDesc надо заглянуть в oopDesc, так как в самом instanceOopDesc никаких полей не объявлено. Вот что мы там увидим:

{% highlight cpp %}
class oopDesc {
   // ...
	volatile markOop  _mark;
	union _metadata {
		wideKlassOop    _klass;
		narrowOop       _compressed_klass;
	} _metadata;
	// ...
};
{% endhighlight %}


В файле [oopsHierarchy.hpp](http://hg.openjdk.java.net/jdk6/jdk6/hotspot/file/tip/src/share/vm/oops/oopsHierarchy.hpp) объявлены необходимые типы данных для работы с иерархией объектов oop (ordinary object pointer). Посмотрим как объявлены те типы, которые используются в oopDesc:

{% highlight cpp %}
// ...
typedef juint narrowOop; // Offset instead of address for an oop within a java object
typedef class klassOopDesc* wideKlassOop; // to keep SA happy and unhandled
                                          // oop detector happy.
// ...
typedef class markOopDesc*  markOop;
// ...
{% endhighlight %}

То есть это два указателя (читай два машинных слова) для конкретной архитектуры - так называемое маркировочное слово (mark word) и адрес (который может быть представлен указателем или смещением) на метаданные класса.
Идея этого union metadata состоит в том, что при включенной опции `-XX:+UseCompressedOops` будет использоваться 32х битное смещение (*_compressed_klass*) а не 64х битный адрес (*_klass*).
Получается размер заголовка java-объекта 8 байт для x86 и 16 байт для x86_64 в не зависимости от параметра UseCompressedOops:

<table class="table table-bordered table-center">
<thead>
	<tr>
		<th>Архитектура</th>
		<th>-XX:+UseCompressedOops</th>
		<th>-XX:-UseCompressedOops</th>
	</tr>
</thead>
<tbody>
	<tr><td>x86</td><td colspan="2">8 байт (<code>4 + 4</code>)</td></tr>
	<tr><td>x86_64</td><td colspan="2">16 байт (<code>8 + 8</code>)</td></tr>
</tbody>
</table>

### Массивы

В arrayOopDesc размер заголовка вычисляется следующим образом:

{% highlight cpp %}
static int header_size_in_bytes() {
    size_t hs = align_size_up(length_offset_in_bytes() + sizeof(int), HeapWordSize);
    // ...
    return (int)hs;
}
{% endhighlight %}

где

* *align_size_up* - инлайнер для выравнивания первого аргумента по второму. Например `align_size_up(12, 8) = 16`.
* *length_offset_in_bytes* - возвращает размер заголовка в байтах в зависимости от опции `-XX:+UseCompressedOops`. Если она включена, то размер равен `sizeof(markOop) + sizeof(narrowOop)` = 8 (4 + 4) байт для x86 и 12 (8 + 4) байт для x86_64. При выключенной опции размер равен `sizeof(arrayOopDesc)` = 8 байт для x86 и 16 байт для x86_64.
* заметьте, что к вычисленному размеру прибавляется `sizeof(int)`. Это делается для того чтобы "зарезервировать место" под поле *length* массива, так как оно явно не определено в классе. При включенной ссылочной компрессии (актуально только для 64x битной архитектуры) это поле займет вторую половину поля *_klass* (см. класс oopDesc)

Посчитаем, что у нас получается. Размер заголовка массива после выравнивания:
<table class="table table-bordered table-center">
<thead>
	<tr>
		<th>Архитектура</th>
		<th>-XX:+UseCompressedOops</th>
		<th>-XX:-UseCompressedOops</th>
	</tr>
</thead>
<tbody>
	<tr>
		<td>x86</td>
		<td colspan="2">12 байт (<code>4 + 4 + 4 align 4</code>)</td>
	</tr>
	<tr>
		<td>x86_64</td>
		<td>16 байт (<code>8 + 4 + 4 align 8</code>)</td>
		<td>24 байта (<code>8 + 8 + 4 align 8</code>)</td>
	</tr>
</tbody>
</table>


## Выравнивание

Для предотвращения ситуаций ложного совместного использования строки кэша (cache-line [false sharing](http://en.wikipedia.org/wiki/False_sharing)) размер объекта в Hotspot выравнивается по 8 байтовой границе. То есть если объект будет занимать даже 1 байт под него выделится 8 байт. Размер границы выравнивания выбирается таким образом, чтобы строка кэша была кратна этой границе, а также эта граница должна быть степенью двойки, а также кратна машинному слову. Так как у большинства современных процессоров размер строки кэша составляет 64 байта, а размер машинного слова - 4/8 байт, то размер границы был выбран равным 8 байт. В файле [globalDefinitions.hpp](http://hg.openjdk.java.net/jdk6/jdk6/hotspot/file/tip/src/share/vm/utilities/globalDefinitions.hpp) есть соответствующие определения (строки 372 - 390). Здесь не буду приводить, интересующиеся могут сходить и посмотреть.

Начиная с версии jdk6u21 размер выравнивания стал настраиваемым параметром. Его можно задать при помощи параметра `-XX:ObjectAlignmentInBytes=n`. Допустимы значения 8 и 16.

## И что же получается?

А получается следующая картина (для x86_64):

{% highlight java %}
public class Point {                         // 0x00 +------------------+
    private int x;                           //      | mark word        |  8 bytes
    private int y;                           // 0x08 +------------------+
    private byte color;                      //      | klass oop        |  8 bytes
                                             // 0x10 +------------------+
    public Point(int x, int y, byte color) { //      | x                |  4 bytes
        this.x = x;                          //      | y                |  4 bytes
        this.y = y;                          //      | color            |  1 byte
        this.color = color;                  // 0x19 +------------------+
    }                                        //      | padding          |  7 bytes
                                             //      |                  |
    // ...                                   // 0x20 +------------------+
}                                            //                    total: 32 bytes
{% endhighlight %}

Для массива char[] из 11 элементов (для x86_64):

{% highlight java %}
char[] str = new char[] {                    // 0x00 +------------------+
    'H', 'e', 'l', 'l', 'o', ' ',            //      | mark word        |  8 bytes
    'W', 'o', 'r', 'l', 'd' };               // 0x08 +------------------+
                                             //      | klass oop        |  4 bytes
                                             // 0x0c +------------------+
                                             //      | length           |  4 bytes
                                             // 0x10 +------------------+
                                             //      | 'H'              | 22 bytes
                                             //      | 'e'              |
                                             //      | 'l'              |
                                             //      | 'l'              |
                                             //      | 'o'              |
                                             //      | ' '              |
                                             //      | 'W'              |
                                             //      | 'o'              |
                                             //      | 'r'              |
                                             //      | 'l'              |
                                             //      | 'd'              |
                                             // 0x26 +------------------+
                                             //      | padding          |  2 bytes
                                             // 0x28 +------------------+
                                             //                    total: 40 bytes
{% endhighlight %}


## Что почитать по теме

* [Java Objects Memory Structure](http://www.codeinstructions.com/2008/12/java-objects-memory-structure.html)
* [HotSpotInternals](https://wikis.oracle.com/display/HotSpotInternals/Home)
* [FOSDEM-2007-HotSpot.pdf](http://openjdk.java.net/groups/hotspot/docs/FOSDEM-2007-HotSpot.pdf)
* [HotspotOverview.pdf](http://www.cs.princeton.edu/picasso/mats/HotspotOverview.pdf)
* [Wimmer08PhD.pdf](http://ssw.jku.at/Research/Papers/Wimmer08PhD/Wimmer08PhD.pdf)
