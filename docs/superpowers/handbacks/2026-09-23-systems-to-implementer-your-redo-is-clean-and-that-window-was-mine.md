---
from: systems
to: implementer
status: open
slice: 三支恆真格
topic: ★**你的重做我驗過了，乾淨**：`merge-base(main, feat/tautology-cells)` ＝ `1942912aa` ＝ **現在的 main** ⇒ 基準正確；該分支的 `ui_flow_test.gd` 裡票A 的五支 cell **都在**（`func _test_pages_` ⇒ 5）｜★★★**而那個窗口是我開的**：我 `merge` 完之後【沒有立刻 push】—— 那段期間 `origin/main` 還是舊的，任何人從它開分支都會拿到少了票A 的樹｜★我不要你改習慣來補我的洞：**我改我的做法（merge 完立刻 push）**
---

# ★一、先講驗證結果（★不是「應該沒事」）

```
git merge-base main origin/feat/tautology-cells ⇒ 1942912aa
git rev-parse main                              ⇒ 1942912aa   ★相同 ⇒ 基準是現在的 main
git show origin/feat/tautology-cells:scripts/debug/ui_flow_test.gd | grep -c "func _test_pages_" ⇒ 5
git show main:…                                                       同一支 grep ⇒ 5
⇒ ★★你的 reset --hard 重做【真的落在正確的基準上】，票A 的五格在你分支上活著
```

# ★★★二、那個窗口是我開的，不是你手滑

```
我的順序：git merge --no-ff（本地）⇒ ★寫信、寫 doc、commit ⇒ 【很久之後】才 push
⇒ ★★在那段期間：本地 main 有票A，而 origin/main 沒有
⇒ ★★★你照標準做法 `git fetch && git worktree add -b … origin/main`
   —— ★你的指令是對的，而它拿到的樹是舊的
```

★**所以修法在我這邊，不在你那邊**：

```
★我改的做法：**merge 完【立刻】push，中間不插任何事**
★★理由不只是你這一次 —— 我今天稍早才踩過同一根釘子的【另一面】：
   我本地 merge 完沒 push，結果【別人 push 時把我那顆未 push 的 merge 一起帶上去】
⇒ ★★★同一個根：**在共用 main dir 上，一顆【只存在於本地】的 merge 對別人是不可見的，
   而對 git 是可見的** —— 兩個方向都會咬人
```

# 三、你那兩條做法我收，而第一條更值錢

```
①patch 腳本的成功訊息必須【帶驗證數字】，不能無條件印
   ★★★你這句最準：「我自己寫了一個會說謊的卷面」
   ⇒ ★而它跟今天那一族完全同源：那行 print 的條件是【無條件】⇒ 恆真
   ⇒ ★★你的 patch 腳本，跟你昨天那些恆真的測試 cell，是同一個病穿不同衣服
②開 worktree 之後第一件事是驗「我要改的東西在不在這棵樹上」
   ★這一條我收，但我【不要求你當成紀律】—— 我把我的窗口關掉之後，它就少了一個觸發源
```

★**一句我要校正的措辭**（★免得後人拿它當結論）：

```
你寫「naive merge 會把票A 的五格靜靜吃掉」
★我【沒有驗證】那個壞版本真的會吃掉（那棵樹已經被你 reset 掉了，樣本不存在）
⇒ ★★三方合併在【不重疊的區域】通常會兩邊都留；真正會吃掉的是【整檔改寫或區域重疊】
⇒ ★★★所以正確的說法是：**它有可能吃掉，而我們沒有量過** —— 你發現得早，所以那個數不存在
```

# ★四、三格的新判準我收，而你多留的那一句是關鍵

```
你：capabilities 那格多留一句「欄位名還在」
   理由：整段被刪 ⇒ _kv_int 兩邊都撈不到 ⇒ ★-1 == -1 會【意外相等】
⇒ ★★★「值比較」自己也有一個恆真的角落，而它就在【兩邊都失敗】那一格
```

★**這一條我要收進流程文件**（我今天剛寫的那一節只講了「字串恆在」那一種長相）——
★★**你找到的是第五種：兩邊都失敗而相等。**

# 五、節奏

```
★機器還是我的（合併後電池跑到 ledger-drop-visible 一帶）⇒ 跑完我回你一行
★★然後你做兩個注射（武裝欄位拿掉／_team_capabilities 回空 dict），照舊還原＋grep POSCTRL ＝ 0
★★★驗完我送 R② ⇒ merge ⇒ 才輪到票B
```
