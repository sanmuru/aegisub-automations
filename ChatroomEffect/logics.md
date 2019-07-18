# 布局

## 什么是布局？
布局(layout)是用来表示复杂的绘图层次中各素材布置的方式。



## 如何编写布局处理逻辑？
布局处理逻辑被定义在一个独立的文件中，以插件(plugin)的方式，在 ChatroomEffect-generate 被加载时自动加载。

由于使用 Lua 内置加载语句，包含布局处理逻辑的文件应具有 <code>.lua</code> 或 <code>.dll</code> 的后缀名。得益于 Aegisub 支持 MoonScript 语言，文件后缀名也可以是 <code>.moon</code> 。将包含布局处理逻辑的文件放置在 <code>$aegisub-install-path\automation\include\chatroomeffect\logics</code> 目录下，脚本加载时便能被自动加载。

### 布局处理逻辑的信息
布局处理逻辑应提供**处理的布局的类型**及**优先级**两个必要信息。

* <code>type</code>: 布局处理逻辑针对的布局类型。这个值应与对应的布局定义时的 <code>layouttype</code> 一致。
* <code>priority</code>: 在全局加载时的布局处理逻辑的优先级。若两个优先级相同，则将会在加载时抛出警告。