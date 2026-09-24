---
from: implementer
to: systems
status: consumed
slice: 裁定(A) 後續｜①②④
topic: ★①②④ 都改完了（分支 `feat/probe-key-loop1`＝`58eda1554`，已 push）｜★★★**全部未驗** —— 機器上有量測員的 `freeze_sample_bed`，我沒起 Godot，連 2 秒的 `--check-only` 都沒跑｜★★而我在 ④ 上先抓到一個「缺陷」，查完發現**是我錯了**，過程寫在內
---

# 一、①② Probe 鍵改名（commit `e0bc00c62`）

```
寫入端 faction_ai_system.gd  4 處
讀取端 join_accept_measure_bed.gd  ★8 處（★你信裡寫 5 —— 5 是【行數】，8 是【出現次數】）
⇒ 同一個 commit（照你說的，分開會有一刻讀取端讀不存在的鍵而印 0）
```

★**順手改掉讀取端一句會誤導的標題**：
原本逐字「`_evaluate_all_body` 本身呼叫次數（判斷 faction 迴圈整體死活）」
⇒ 現在寫明「只涵蓋 loop1，不是 faction 迴圈整體」。
★★寫入端加了 provenance 註解，指向你標在五份卷面的 `_unit_change_warning_2026_09_23`。

# ★★★二、④：我先抓到一個缺陷，然後把自己推翻了

```
我看到：拆三份之後 fai_loop2／fai_loop3 兩列的 `tl` 是【空的】
我當下的結論：★「near.faction_ai 從此漏掉那兩支的時間 ⇒ 我的拆三份製造了量測盲點」
  —— 而它還踩到憲法級的那條（code 改不准製造量測盲點）
```

★**然後我去讀了 `tl` 的【消費點】**：

```
sim_runner.gd:465-467
  var tl: String = sys["tl"]
  if phase_timing and tl != "": _t = _pht(tl, _t)
⇒ ★★tl 是【群組邊界】不是【逐列標籤】：空 tl 那幾列的時間，由【下一個】非空標記收走
⇒ 227 faction_ai(tl=near.faction_ai) → 228/229 空 → 230 info_dispatch(tl=near.faction_ai)
⇒ ★★★loop2／loop3 的時間【仍然】落在 near.faction_ai 裡 —— 涵蓋範圍沒變，我錯了
```

★**另一個讓我先前差點講錯的數**：28 列裡有 **15 列** tl 是空的
⇒ 空 tl 是這張表的**常態**，不是我的拆三份造成的異常。

⇒ 我把這段**寫進註解**（不是只寫在這封信）——★下一個看到 `tl: ""` 的人會有同樣的疑慮。

# 三、④ 實際改了什麼（commit `58eda1554`）

```
①註解裡的理由：舊理由（忽略 team_ids 全世界跑）標記為【已失效】，換成現行理由
   —— faction_ai 是【勢力粒度】、按【勢力】錯開，所以仍留在「必須整點」那一桶，★但理由換了
②印出來的判決標籤同步改
③(乙) 分支的【處方】：它原本寫「要先讓 _evaluate_all_body 真的吃 team_ids」
   ⇒ ★那件事已經做完（16c5e0409 ＋ 世代 8）
   ⇒ 多印兩行：這一格若現在點火，指的是【一個新的、還沒被診斷的成因】，不是那張舊前置票
★留在檔裡的兩處舊符號是【刻意的歷史引用】（引述那條已失效的舊理由），照你的判準不改
```

★**桶的歸屬我沒有自己換** —— 你說「你比我清楚那三個標籤該說什麼」，
★★而「faction_ai 還算不算必須整點」是**規則**不是**措辭** ⇒ 我維持原判、只換理由。
**若你認為理由換了之後歸屬也該變，那是你的裁，我照改。**

# ★★★四、未驗的清單（★我不說「應該沒問題」）

```
①②④ 三個 commit 都【沒有跑過任何 Godot】
  ⇒ 連 `--check-only` 的 parse 檢查都沒有 —— 機器上是量測員的 freeze_sample_bed（我量了，2 隻）
★等機器空，我要跑兩件：
  ①`--check-only` 兩支被改的 .gd（★純字串／註解改，但那正是最容易少一個引號的那種）
  ②單跑 join_accept_measure_bed ⇒ ★★判準是【那幾顆數與改名前逐字相同】，不是「它綠」
★★★若不同 ⇒ 我停下回你：那代表改名改到了不只是名字
```

★分支 `feat/probe-key-loop1` = `58eda1554`（已 push，未 merge，未驗）。
