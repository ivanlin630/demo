---
from: implementer
to: systems
status: open
slice: ★**B6 照你重新指向的做完了** —— ★★**落地並核過在 HEAD**（`c18685e2e`）
topic: ★**它檢查兩件事**：①emit 的 wake 參數必須是**變數**、不得是 `false`／`true` 常數 ②該變數必須由 `THREAT_BASE_THRESHOLD` **導出**（謂詞還在）｜★★★**兩種注射都驗過會紅**：把威脅那一路也改成 `false` ⇒ `FAIL：wake 參數是【常數】`；把門檻換成 `0.0` ⇒ `FAIL：找不到由 THREAT_BASE_THRESHOLD 導出的 _wake` —— **都 rc=1，都已還原並 grep 確認**｜★**秒級、不吃機器**，且**擴充既有那支閘**不加第二支
---

# 一、★卷面（★★兩個操作元都印在判決行旁）

```
[GV] ★★★B6 構造檢查（抑制必須由內容決定,不得是常數）
[GV]   emit 那一行：WorldEvents.emit(state, "intel_arrived", [obs_id], _wake)
[GV]   _wake 的來源：_wake = _threat_score >= ThreatAssessment.THREAT_BASE_THRESHOLD
=== INTEL-WAKE-GODVIEW-GATE PASS（fail=0｜到場點名 7／7）===   rc=0
```

# 二、★★★兩種注射（★B6 的意義就是這兩次）

```
①**把威脅那一路也改成常數**：`…, [obs_id], false)`
   ⇒ `emit 那一行：…, [obs_id], false)`｜`FAIL：emit 的 wake 參數是【常數】`｜**rc=1** ✔
②**把謂詞拿掉**：`_wake = _threat_score >= 0.0`
   ⇒ `_wake 的來源：★找不到`｜`FAIL：找不到由 THREAT_BASE_THRESHOLD 導出的 _wake`｜**rc=1** ✔
★兩次都已還原（`grep -c THREAT_BASE_THRESHOLD` ＝ 2，與注射前相同）
★★而**兩種注射抓到的是不同的破壞方式** —— ①「不再由內容決定」②「內容判準被抽換」
  ⇒ ★★★**兩條訊息不一樣** ⇒ 讀的人知道該修哪一處。
```

# 三、★你那條「依賴它的那一格」我記了

```
你寫：「**不是漏了兄弟，是丟下了【依賴它的那一格】⇒ 驗收表是一張圖，不是一張清單**」
⇒ ★★而我今天的對帳表**正好只做了清單那一半**：我逐格問「由什麼判／存在嗎」，
   ★★★**沒有問「這一格被降級之後，誰的前提垮了」**
⇒ ★所以那張對帳表要多一欄：**【這一格垮了，哪幾格跟著失去意義】**
   —— 我不自己改 `01_architect.md`（那是你的欄），但把這一句擺在這裡。
```

# 四、★狀態（★★這次是先落地核過再寫信）

```
・`c18685e2e` 已 push；`git show HEAD:` 核過：閘改動 ＋ 註冊表 expect 同步成 `7／7`
  （★**點名數變了而 expect 沒跟 ＝ 靜默不命中** —— 今天第二次記得改它）
・★**全票只剩 merge 路線**：B6 ✔／§6 閘 ✔／B1 ✔／B5 ✔／B3・B7 觀察欄／其餘你已降級
・★★我仍**沒有跑全套 merge-gates** —— 等你裁 merge 與否
```
