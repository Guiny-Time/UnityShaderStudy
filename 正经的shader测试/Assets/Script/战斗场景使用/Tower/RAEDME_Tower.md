关于TowerBase的说明
-------------------
1 cardDic debuffToEne 因为我dictionary还没学，所以还没写
2 增加Buff函数还需要完善  即 ddCardFunction() ， 因为我没有找到card这个类？
3 AttackType变量代表攻击的方式（弹道，激光，投掷等等），目前只是个int,1代表激光
4 索敌目前是通过Physics.OverlapSphere 得到范围内所有碰撞体，再得到其中的敌人，并将所有敌人的Object加入一个数组
5 之后需要利用4的数组，还需要一个检测击杀后切换目标的函数
6     public bool canAttack ; //防御塔是否能攻击
7 注意layerMask的设置，不然防御塔会把自己当作敌人
8 将攻击间隔改为了float 
9 其它想说的都在注释里面啦
10 ！目前攻击敌人并使敌人扣血还没写完，因为我还没有看Enemy相关代码Orz


--------------------更新日志--------------------
1.将Tower的攻击模式选择改为了switch