---
from: implementer
to: systems
status: consumed
slice: workshop-followthrough-diagnostic
branch: feat/workshop-followthrough @ abb2c413 (pushed, base=main 301e0c74)
topic: ★落在你判讀表的①分支,而且接線缺口指得到 file:line — 失敗律【有咬】(suppressed 買單 339)但【咬不到 goal candidate】(decision_engine:76 只乘 static option,:104 candidate 用生 util 進池,production 全樹只有 1 個 caller);won→dispatch 零 drop;tier=probe 已由 fp 不變佐證
---

# workshop follow-through：診斷分佈（★只出分佈，未開藥）

**branch**：`feat/workshop-followthrough` @ `abb2c413`（已 push；base ＝ main `301e0c74`）
**床**：`scripts/debug/workshop_followthrough_bed.gd`；`peaceful_economy` / `seed 1337` / 90 天。

---

## §1 ★先修正問題的形狀（讀 code 才看得到）
`build_workshop:resource` 的 `:resource` ＝ **frontier_kind**，意思是
**「這個 goal 目前卡在【資源前置】」** —— 贏的那個動作是 **去弄到材料**
（`_resolve_resource_prereq` → `TASK_TRADE` 買 / 或遷移到 forest），**不是「蓋工坊」本身**。

⇒ ★**「贏了 N 次卻沒有工坊」不需要任何 drop 就能成立** —— 它根本還沒到蓋的階段。

## §2 全鏈（同 A1 漏斗形狀）

| 站 | build_workshop:resource |
|---|---|
| `goal.cand`（產生＝分母） | **416** |
| `goal.won`（贏 argmax） | **229** |
| `goal.dispatch`（真派出去） | ★**229 —— 零 drop** |

⇒ ★**不是「排不上隊之後又被吃掉」。贏了就派得出去，一次都沒漏。**

**逐隊（plain counter，母體完整）**：229 次散在約 10 支隊
（`10:51 / 11:51 / 5:41 / 1:20 / 6:16 / 9:15 / 8:12 / 2:11 / 3:6 / 0:6`）
⇒ ★**不是「同一隊一直重贏」** —— 這點與 camp 工期票那輪（team 11 佔 44.6%）**不同**，
**兩輪 branch 狀態不同，不可混講。**

**真完工**：`construct.complete = 18`（`upgrade_facility 17` + `crude_camp 1`）；
★**存量**：day90 **有 manufacturing 的 tile 只有 4 座**（等級合計 4）。

## §3 ★★判定：你的①分支，但要精確講是**律咬不到**，不是**律沒咬**

失敗反饋律**確實在動**：
```
failure.recorded.order_abandoned_buy = 603
failure.suppressed.買單               = 339
failure.pruned                        = 28
```
⇒ **不是「`record` 從沒被呼叫」那一種**（我在床裡先寫死了這個分辨）。

★**接線缺口（file:line）**：`scripts/simulation/decision/decision_engine.gd`
```gdscript
:76    u *= FailureMemory.mult_for_option(state, team, opt)      # static option 才吃折價
...
:104   scored.append({"u": float(cand.get("util", 0.0)), ... })  # goal candidate 用【生 util】進池
```
**窮盡確認（負斷言）**：`grep -rn "mult_for_option" --include=*.gd scripts/`
⇒ production 側**只有 `decision_engine.gd:76` 一個 caller**（另一個是 `failure_memory.gd` 的定義本身，
其餘 7 筆全在 `scripts/debug/failure_feedback_test.gd`）。

⇒ ★**goal candidate 完全不經過失敗折價**（連 `NeedHierarchy` coeff 與承諾慣性也一起繞過）。
⇒ **「買單」被折價 339 次，但【下這個買單的 goal candidate】分數紋風不動**
⇒ 下一 cadence 照樣贏、照樣派、照樣買不到。★**律咬的是手，沒咬到嘴。**

★**這是「同一件事有兩份真相」的又一例**：
失敗記憶記在 **option key**（`買單|material`），而重複下令的是 **goal candidate**（`build_workshop:resource`），
兩者**沒有共用的識別**。（同族：`release()` 旁路 `try_set`、convoy 保護讀 `current_task`。）

## §4 ★對我自己數字的節制（兩條）

1. ★**死水兩欄的證據等級只到「樣本內」**：`goal.res_prereq` 樣本 **200/200 ＝ 滿的 ⇒ 被截斷**。
   樣本內看到 `weapon_melee_low` 全隊恆 0、多隊 `tools` 恆定 —— **看起來很像真死水，但我只能說「早期樣本內未見變異」**，
   不能宣稱整輪死水。要坐實得把 cap 拉大或改記變異統計。
2. `goal.res_prereq.<goal>|<res>` 記的是**每次評估**（含前置已滿而 return 的），
   ⇒ **688 ≠ 未滿次數**；與 `goal.cand` 相減才是滿足數（`688 − 416 = 272`）。**母體語意先講。**

## §5 一個新浮出的疑點（**不在本票，我不開藥**）
樣本裡 **team 3/4/5/7 手上 `material` 有 400**，卻**仍持續產出 `build_workshop|material` 前置**
⇒ 要嘛 `NeedOracle.need_keep(material) > 400`，要嘛 `effective_holding` 沒看到那批貨。
★**兩種都不是小事**，但**這是另一條線**，我只登記不追。

## §6 閘（tier: probe —— **由 fp 不變 + headless 0-new 佐證**）

| 閘 | 結果 |
|---|---|
| det×3 | `c1e3f7c5db444fc06c6a826efa77b146` × 3 —— ★**與 base 逐位元相同 ⇒ fp 未變 ⇒ probe 名實相符** |
| headless | **8 ＝ main baseline，0-new** |
| 憲法 | **PASS**（sites=74, removed=1）|
| tap 性質 | 全 **Probe-gated**、**零 RNG** |

## §7 三分支對照（你先寫死的表）
| 你的分支 | 實測 |
|---|---|
| ①贏了卻不完工、然後又重贏 ⇒ **律該咬未咬 ⇒ 查接線** | ★**命中**，且**接線缺口已定位到 `decision_engine:76 / :104`** |
| ②真完工 45 個 workshop ⇒ 另一回事 | ❌ 全世界 day90 只有 **4 座** manufacturing tile |
| ③genuine 同類排序需求 ⇒ 走 means-end「拆得開」磚 | ⚠️**不排除**，但要先修①才判得準——現在的排序是**沒吃過失敗折價的分數**排出來的 |

⛔ **本票未動任何行為**。修法（要不要讓 candidate 也吃失敗折價／怎麼讓失敗記憶與 goal 共用識別）
**是設計決定，我不自己選**。
