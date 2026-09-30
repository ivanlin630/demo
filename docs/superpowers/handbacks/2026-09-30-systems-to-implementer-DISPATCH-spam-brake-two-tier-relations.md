---
from: systems
to: implementer
status: consumed
topic: 派工：濫按煞車（兩層關係帳版）——R² CLEAN｜★權威是 spec §9／§10／§11，§1–§8 有一半作廢（(A) 撤回）｜排在你現有四件之後
---

# 派工：濫按索貢的煞車 ＝ 好感層（不是恨意層）

**spec** `docs/superpowers/specs/2026-09-30-spam-brake-feud-on-tribute-HOW.md`
**R²** CLEAN（`2026-09-30-reviewer-to-systems-two-tier-relations-fp-ratified-clean.md`）
**序**：排在你現有四件（提案字串三件／反向提案守衛／專屬鍵位／同格檢查票）**之後**。

## ★★★讀 spec 的順序很重要：**後面的節推翻前面的節**

```
§1  前提（file:line）              ← 有效
§2  算術（三個分支）               ← 有效，但★結論句的量級我抽錯過一次（§9d① 訂正）
§3  「FEUD_MIN 是補丁閘」          ← ★病名錯了（§9e①）：它是【分流器】不是【損失】
§4① add_edge 移到門檻前            ← ★★**作廢**（(A) 撤回）
§8  藍圖 (A) 的追裁                ← ★★**整節作廢**，留著留理由
§9  兩層關係帳                     ← ★★★**這是現行設計**
§10 D2 訂正（我兩半都錯）          ← 有效
§11 好感【已經在指紋裡】           ← ★★★**取消 §9b⑤ 的 tap**
```

## 做什麼（§9b，扣掉已作廢的 ⑤）

```
①`form_feud` **一行不動**（(A) 撤回）
②新名字 `tributed`，兩層同時接：
  ·`_write_relation_edge` 的 feud 那一組加 "tributed"
    ⇒ 索貢的嚴重度（遠程 0.1／同格 0.25）× 人格乘子幾乎一定不過 0.30
    ⇒ ★**不寫邊是正確行為**（小事不入記憶＝用戶逐字）
  ·`_update_relations` 加 `"tributed": delta = -intensity * 0.5`（同 special_taxed 的係數，零新常數）
    ⇒ ★**這一行才是煞車的本體**
  ★★★而 `tributed` **不得進 FEUD_SEVERITY 表** —— 一進表，`.get(type, intensity)` 就會
    把「拿走幾成」靜默換成表裡的固定值（P1′ 的負對照 b 就是守這件事）
③寫入點兩個，都在執行端不在秤裡（`player_command_system.gd:316`／
  `interaction_system.gd:488 _resolve_extortion` 的 coin 那一項）；`coin_before <= 0` 不寫
④`tribute_accept` 加好感項：`score += affinity * <好感權重>`
  ★好感權重取 `_calc_diplomacy_score:103` 那一項用的同一個（若那裡是 inline 數字，先提成常數再共用）
  ★★而它**不得與 `TRIBUTE_W_FEUD` 共用**（藍圖：兩項各自獨立可改）——審查核過這兩條不矛盾
⑤~~新增 fingerprint tap~~ **作廢**（§11）
```

## ★★動工前第一件事（唯讀，一行輸出）

```
印一次 `FpCoverage.fields_for("PersonData")`，把 `relations` 在不在清單裡**印上卷面**。
·在（我預期）⇒ 不要加任何 tap
·不在 ⇒ **回報**，不要自己改回去加 tap（推理鏈裡有我沒看到的一環，那件事本身要先弄清楚）
★這一步是用【一行實測】坐實一條【正面呼叫鏈】：
  state_fingerprint.gd:412 → :349 → fp_coverage.gd:119/:99。
```

## 驗收（§9c，全部負對照要實測紅）

```
P1′ 索貢成功一次 ⇒ 印【實際進公式的 severity】＋人格兩值＋factor＋好感前後＋feud 邊前後
    斷言：好感下降 **且 feud 邊仍然是 0**
    ｜負對照 a：拿掉 `_update_relations` 那一列 ⇒ 好感不動 ⇒ 必紅
    ｜★★負對照 b：把 `"tributed": 0.30` 加進 FEUD_SEVERITY ⇒ 小索貢突然寫起 feud 邊 ⇒ 必紅
P2′ 連索 20 次，逐次印 accept／refuse、好感、feud_i、coin_before、**score_no_edge**
    斷言：①第 1 次 accept ②好感單調不增 ③至少一次 refuse ④refuse 之後仍 refuse
    ★**不釘第幾次**；序列要進卷面（它是衰減那張票的基線）
    ★★母體地板三道：coin_before 每次 >0／印 score_no_edge／**領袖人格釘死**
      ＋床自己算出「理論上第幾次翻」再跟實測序列對一次 ⇒ 兩行自相矛盾＝紅燈
    ★★★負對照：拿掉 ④ 的好感項 ⇒ 20／20 全 accept ⇒ 必紅
P3b 第一次 refuse 之後推三天再索 ⇒ 仍 refuse（沒有衰減＝永久）
    ★這是【兩向格】：衰減那張票落地時**改斷言不要刪格**
P4  NPC↔NPC 同格勒索（玩家不在場）也走同一條路 ⇒ 玩家零特殊物理
    ｜負對照：把寫入只掛在玩家那一支 ⇒ 必紅
P5′ 兩層不串：severity 0.9 ⇒ 邊有了且好感也動；severity 0.1 ⇒ 只有好感動、邊仍 0
    ｜負對照：把 `_update_relations` 搬到門檻後面 ⇒ 小事好感不動 ⇒ 必紅
P6  `grudge_ledger_bed` 格7 名字表加一列 `["tributed","feud","<寫入點 file:line>"]`
    ★格7-b（`extorted` 是死名字）**不動**，必須維持綠
P7′ 好感層要有自己的母體：新增 `affinity.delta.<type>` 計數
    ★理由：好感一直有人在寫，而它**從來沒有任何 tap**（不是本票製造的盲點，是本票照到的）
P8  headless ≥1000 tick、ui-flow 綠、全電池 BATTERY_RC=0
    ★★fp：**先量再換基準**（預測不是授權）—— 變了就換、同 commit；沒變**不要動**，
      並把「為什麼沒變」寫進卷面
```

## 不在本票

```
·feud 衰減（藍圖：另一張 WHAT 票，先量各 type 的邊齡分佈）
·好感「會回中」（同上）
·D1 同格索貢談成零轉移 ⇒ 已登 defer `npc-tribute-accepted-zero-transfer`
·`views-as-foe-reads-any-nonzero-feud` ⇒ 已登 defer（★本票不寫門檻下小邊 ⇒ 它今天無害）
```
