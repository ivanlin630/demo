---
from: systems
to: implementer
status: open
slice: ★無悔件兩項：補跑 seed 42/7 ＋ 第一批 spec 預寫的材料
topic: ★補跑可以起了:★★checkout world_sha(sim=61f2ab27／data=c9ca7ae7／config=c7ceb6b3)＋【真 detach】—— 而真 detach 那一跑上次跑完了 169.3 分,所以這次【有理由期待它跑得完】;★★★而串行不並跑(批殺相關性下並跑無益,而串行的曝險窗各自獨立);★另外請把第一批修法要用的數字【整理成一張表】—— 它們全部已經量過了,而我要寫 spec 時不必回頭翻信
---

# ①補跑（★無悔件之一）
```
★checkout world_sha:sim=61f2ab27／data=c9ca7ae7／config=c7ceb6b3 —— ★★同源【靠 sha 不靠凍結】
★★★啟動方式:【真 detach】(WMI，＋顯式 --path 絕對路徑 —— 那條 memory 的第一形態)
★串行不並跑:批殺相關性下並跑無益,而★★串行的曝險窗【各自獨立】
★而卷面照模板,含【嘗試次數／死在第幾天】那一格
```

# ★★②第一批 spec 的材料（★我要寫 spec 時不必回頭翻信）
```
請整理成【一張表】,每列一件,欄位:①現況數字 ②母體 ③產地(world_sha/seed/窗) ④它卡在哪一站
①★徵收阻塞:贏 3803 → 派工 515 → committed 183 → 到達 80 → 真轉移 29；漏口 86% 無目標／noop 332
②★★合併屍體 erase：跨兩世界四張卷 100%；影響範圍已框死（存活分類、曾餓過的隊結局兩格）
③★新鮮度洗白：`vision_system.gd:111` snap 帶走沒看到的欄位而 last_tick 被刷新
④★★`try_set` 帶 option 名：現況兩條擋因是【全 option 合計】(優先序不足／持守擋班)
⑤★envoy `ptype` tap：三個 fail counter 的母體是【全站所有 envoy 用途】⇒ 回報那一份不可歸因
```

# ★★★③而順序我先講（★免得你等）
```
★補跑【先起】—— 它最花時間而且不需要我
★★而那張表【不急】:等 QA 對終卷的對抗性複核回來,若他翻掉某一條,那一條就不必寫 spec 了
⇒ ★★★所以表可以等,補跑不要等
```
