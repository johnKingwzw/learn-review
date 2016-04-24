<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Insert title here</title>
</head>
<body>

js中自定义方法实现停留几秒sleep
js中不存在自带的sleep方法，要想休眠要自己定义个方法,需要的朋友可以参考下


js中不存在自带的sleep方法，要想休眠要自己定义个方法

 <script type"text/javascript">
function sleep(numberMillis) { 
var now = new Date(); 
var exitTime = now.getTime() + numberMillis; 
while (true) { 
now = new Date(); 
if (now.getTime() > exitTime) 
return; 
} 
}
 </script>

以下是补充：

除了Narrative JS，jwacs(Javascript With Advanced Continuation Support) 
也致力于通过扩展JavaScript语法来避免编写让人头痛的异步调用的回调函数。用jwacs 实现的sleep，代码是这样：


复制代码 代码如下:

<script type"text/javascript">
 function sleep(msec) {
     var k = function_continuation;
     setTimeout(function() { resume k <- mesc; }, msec);
     suspend;
 }

</script>

这个语法更吓人了，而且还是java里不被推荐使用的线程方法名。坦白说我倾向于 Narrative JS。

同Narrative JS一样，jwacs也需要预编译，预编译器是用 LISP 语言编写。目前也是 Alpha 的版本。
两者的更多介绍和比较可以参阅 SitePoint 上的新文章： Eliminating async Javascript callbacks by preprocessing

编写复杂的JavaScript脚本时，有时会有需求希望脚本能停滞指定的一段时间，
类似于 java 中的 Thread.sleep 或者 sh 脚本中的 sleep 命令所实现的效果。

众所周知，JavaScript 并没有提供类似于 Java 的线程控制的功能， 
虽然有 setTimeout 和 setInterval 两个方法可以做一些定时执行控制，但并不能满足所有的要求。
一直以来，都有很多人问如何在JavaScript中实现 sleep/pause/wait ，也确实有些很蹩脚的解决方案:

最简单也最糟糕的方法就是写一个循环，代码可能如下：

复制代码 代码如下:

<script type"text/javascript">
 function sleep(numberMillis) {
     var now = new Date();
     var exitTime = now.getTime() + numberMillis;
     while (true) {
         now = new Date();
         if (now.getTime() > exitTime)
             return;
     }
 }
</script>


如上的代码其实并没有让脚本解释器sleep下来，而且有让CPU迅速上到高负荷的附作用。浏览器甚至会在该段时间内处于假死状态。

其二有聪明人利用IE特殊的对话框实现来曲径通幽，代码可能如下：


复制代码 代码如下:

<script type"text/javascript">
 function sleep(timeout) {
  window.showModalDialog("javascript:document.writeln('<script>window.setTimeout(function () { window.close(); }, " 
		  + timeout + ");<\/script>');");
 }window.alert("before sleep ...");
 sleep(2000);
 window.alert("after sleep ...");
</script>


缺点不用多说，只有IE支持(IE7因为安全限制也而不能达到目的)。
除上之外，还有利用Applet或者调用Windows Script Host的WScript.Sleep()等等鬼点子，这些都是万不得已的权宜之计。
终于有了更聪明的人，开发出了也许是最佳的方案，先看代码：
复制代码 代码如下:

<script type"text/javascript">
 function sleep(millis) {
     var notifier = NjsRuntime.createNotifier();
     setTimeout(notifier, millis);
     notifier.wait->();
 }
</script>


没错，看到 ->() 这样的语法，就象刚看到Prototype的 $() 函数一样让我惊为天人。
不过直接在浏览器中这段脚本是会报告语法错误的。实际上它们需要经过预编译成客户端浏览器认可的JavaScript。编译后的脚本如下：


复制代码 代码如下:

<script type"text/javascript">
 function sleep(millis){
 var njf1 = njen(this,arguments,"millis");
 nj:while(1) {
 try{switch(njf1.cp) { 
 case 0:njf1._notifier=NjsRuntime.createNotifier();
 setTimeout(njf1._notifier,njf1._millis);
 njf1.cp = 1;
 njf1._notifier.wait(njf1);
 return;
 case 1:break nj;
 }} catch(ex) { 
 if(!njf1.except(ex,1)) 
 return; 
 }} 
 njf1.pf();
 }
</script>


我看不懂，也不想去看懂了。这些工作全部会由 Narrative JavaScript ———— 一个提供异步阻塞功能的JS扩展帮我们实现。
我们只需要编写之前那个怪异的 ->() 语法， 然后通过后台预先静态编译或者前台动态编译后执行就可以实现 sleep 的效果。 
 Narrative JavaScript 宣称可以让你从头昏眼花的回调函数中解脱出来，
 编写清晰的Long Running Tasks。目前还是 alpha 的版本，在 Example 页面上有一个移动的按钮的范例。
 首页上也提供了源码下载。以我薄弱的基础知识，我只能勉强的看出代码中模拟了状态机的实现，希望有精通算法的朋友能为我们解析。 
 最后，还是我一直以来的观点： 除非很必要，否则请保持JavaScript的简单。在JavaScript 能提供原生的线程支持之前，
 或许我们可以改变设计以避免异步阻塞的应用。

有bug的曲折实现


 
<script type"text/javascript">
/*Javascript中暂停功能的实现
Javascript本身没有暂停功能（sleep不能使用）同时 vbscript也不能使用doEvents，故编写此函数实现此功能。
javascript作为弱对象语言，一个函数也可以作为一个对象使用。
比如：
[code]
function Test(){
 alert("hellow");
 this.NextStep=function(){
 alert("NextStep");
 }
}
我们可以这样调用 var myTest=new Test();myTest.NextStep();
我们做暂停的时候可以吧一个函数分为两部分，暂停操作前的不变，把要在暂停后执行的代码放在this.NextStep中。
为了控制暂停和继续，我们需要编写两个函数来分别实现暂停和继续功能。
暂停函数如下：
*/
function Pause(obj, iMinSecond) {
	if (window.eventList == null)
		window.eventList = new Array();
	var ind = -1;
	for (var i = 0; i < window.eventList.length; i++) {
		if (window.eventList[i] == null) {
			window.eventList[i] = obj;
			ind = i;
			break;
		}
	}

	if (ind == -1) {
		ind = window.eventList.length;
		window.eventList[ind] = obj;
	}
	setTimeout("GoOn(" + ind + ")", 1000);
}
/*
该函数把要暂停的函数放到数组window.eventList里，同时通过setTimeout来调用继续函数。
继续函数如下：
*/

/*
该函数调用被暂停的函数的NextStep方法，如果没有这个方法则重新调用该函数。
函数编写完毕，我们可以作如下册是：
*/
function Test(){
 alert("hellow");
 Pause(this,1000);//调用暂停函数
 this.NextStep=function(){
 alert("NextStep");
 }
}
</script>
 





</body>
</html>