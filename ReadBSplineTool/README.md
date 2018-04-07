# 读取BSpline工具简介
## 工具目的及生成
该工具用于读取文件中的G代码（BSpline对应的G代码标识为G6.2），并画出对应的轨迹。
使用命令`guide`打开`ReadBSplineTool.fig`，可以查看并修改该工具的界面布局及功能按钮。
使用命令`mcc -m ReadBSplineTool.m `，可以编译生成可执行文件`ReadBSplineTool.exe`。
## 参数
### 视图
画轨迹图时的视图，可供选择的视图有：X-Y平面，Y-Z平面，Z-X平面，三维视图。
### 显示NURBS曲线的控制点
画图时是否画NURBS曲线的控制点，若勾选则画，不勾选则不画。
### 圆心编程IJK增量方式
G代码表示圆弧时，IJK表示的圆心是否是增量方式，不勾选则为绝对值，IJK的值直接表示圆心，否则需要加上起点的值才能作为圆心的坐标。
### 曲线离散精度
画图时用离散的点代替曲线，这里的精度表示用散点逼近曲线的精度。
## 加工文件
可以手动输入欲分析的文件路径，或者通过`导入文件`按钮导入欲分析的文件路径。
## 画图颜色
这里可以设置文件中不同线形所对应的颜色。
## 导入文件
选择欲分析的文件，导入后，可以加工文件框内查看或修改导入的文件。
## 画图比较
导入欲分析的文件，设置相应的参数，然后点击该按钮，可以画出文件对应的轨迹图。
## 清空图像
关闭前面执行`画图比较`画的所有图像。
## 关闭工具
先`清空图像`，然后关闭该工具。