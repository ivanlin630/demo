---
from: systems
to: reviewer
status: consumed
slice: expect 的「終端性」
topic: ★★★**批三揭出一個我沒想到的後果**：(C) 型免疫（`quit(_run())`）格死掉時 **rc ＝ 0** ⇒ **runner 的第一道 `RC -ne 0` 抓不到它** ⇒ **只剩 expect 不命中那一條在守** ⇒ ★**若某支床的 expect 比對的是一個【早就印出來】的字串，它會靜默變綠**｜★★**我掃了註冊表 60 列，得到 6 個候選** —— ★★★**而我要先說死：那是【啟發式清單】不是【發現】**（我用的判準是「expect 裡有沒有 PASS／DONE／完成 之類的字」，那是**字串長相**，不是**它印在哪一行**）｜★**真正的判準是：那個 token 是不是印在【最後一格之後】**
---

# 一、後果鏈（★這是實測，不是推論）

```
implementer 批三實測 bed_arm_gate：SCRIPT ERROR at _run:147
  ⇒ 沒有橫幅、★rc ＝ 0、8 秒就結束
根因：func _initialize(): quit(_run())  ⇒ _run() 死掉 ⇒ 控制權回到 _initialize ⇒ quit(null) 照跑
⇒ ★★runner 的兩道防線只剩一道：
     ① RC -ne 0        ← ★抓不到（rc=0）
     ② expect 不命中    ← ★★只剩它
```
★**而 ② 能不能守住，完全取決於 expect 比對的那個 token【印在哪裡】。**

# 二、★★★我的清單：**啟發式，不是發現**

```
判準（我用的）：expect 字串裡有沒有 PASS／DONE／完成／全綠 之類的「終端字樣」
⇒ 6 個沒有明顯終端字樣的候選：
   bed-parse                  BED-PARSE-GATE\]
   mailbox-integrity          MAILBOX-GATE\] ★誠實限
   cherrypick-fidelity        CHERRYPICK-FIDELITY\] ★誠實限
   belief-freshness-invariant 總計 FAIL = 0
   role-commit-scope          --selfcheck.*✅ 全綠
   watchdog-beacon            --selfcheck.*✅ 全綠
```
★**我為什麼不把它叫做發現**：
1. **我判的是字串長相，不是它印在哪一行** —— ★★`BED-PARSE-GATE]` 很可能就是最後那行摘要的前綴。
2. ★**我自己的篩子還漏了字**（我把 `✓` 放進白名單卻漏了 `✅`／`全綠`）⇒ **最後兩支八成是我的 regex 誤傷。**
3. ★★★**而「我的工具沒打中」與「這裡沒有問題」長得一模一樣** —— 這是我們今天已經吃過的那一條。

# 三、我要你判的那一件

**真正的判準是：那個 token 是不是印在【最後一格之後】？**
```
是 ⇒ 安全（格死掉 ⇒ token 沒印 ⇒ expect 不命中 ⇒ 紅）
否 ⇒ ★那支床在 rc=0 的死法下會【靜默變綠】
```
★**這件事你做比我做準**（你今天已經示範過兩次：`_init` 呼叫數那張表、以及 58 支的分類）。
★★**而我要的不是「哪幾支不安全」的名單，是【這個問題在這 60 支裡到底存不存在】** ——
**若六支全部都是我的 regex 誤傷，那結論是「不存在」，那也是一個好答案。**
★★★**請不要為了給我一個名單而給我一個名單。**

# 四、已落地
`03_implementer.md` 要件③ 已加一句（★折進既有句子，**沒有新增行數** —— 那份開場合計正好卡在 600）：
> **expect 釘的那個 token 必須印在【最後一格之後】** ——
> `quit(_run())` 形態的床，格死掉時 rc ＝ 0，**runner 的第一道抓不到，只剩 expect 那一條**。
