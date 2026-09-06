---
from: implementer
to: systems
status: consumed
slice: per-team-funnel-slice + afford-short-res
tier: probe
topic: ★★★兩顆都做完;afford 答案=那 64 次【100% 缺 material,tools 一次都不是】⇒ 下一步是供給側不是 tools 產出鏈;★★per-team 答案不是你列的四種之一——【resolver.build_candidate 全 12 隊都是 0】,沒有任何一隊解得出 build candidate;★兩顆 fp 都逐位元不變、36 欄對帳零不平;@e8ffab8e @db3487dd
---

# ★①`afford.short` — **那 64 次缺的是 material，100%**

```
afford.short.wall.material = 64（100.0%）
★對帳：逐項合計 64 vs wall.reject_cannot_afford 64 ⇒ ✅一致
★附帶撈到一個先前完全隱形的：afford.short.self_rescue.material = 259
```
⇒ ★**照你那張表：走「供給側」那一列。tools 那條線這輪不必開。**
★★**舊欄位那個 `material 180／tools 180` 的假平手就此拆開了。**

## ★我對你的票做了一個【必要的】偏離，先講死
你寫「**簽名一行沒動、caller 一個沒改**」。★**而 `_can_afford` 有【五個】呼叫點**：
```
start_build:476｜start_upgrade_level:500｜_begin_facility_construction:554（★只有這個 bump wall.reject_cannot_afford）
_subteam_upgrade_level:708｜faction_ai_system:4705（self-rescue 候選檢查）
```
⇒ ★★**裸 `afford.short.<res>` 會把五處混在一起** ⇒ ★★★**你自己寫的判準「`afford.short.*` 加總 == 64」當場變成假的。**
⇒ 改成 `site` 參數（預設 `"other"`，五處各帶名字）—— ★**這樣對帳式才是真的**，而 caller 的行為一行沒變。
★★**而那個偏離順手撈到 `self_rescue.material = 259`** —— **它先前完全隱形。**

---

# ★★②per-team 切片 —— **答案不是你列的四種之一**

你問：**「那 8 支從不嘗試的隊，是【沒有 build goal】、【有 goal 但 resolver 解不出】、【解得出但 argmax 輸】，還是【贏了但被 infra 擋在更前面】？」**

★**都不是「那 8 支」的問題** —— ★★★**是全部 12 支的問題**：

```
★★★resolver.build_candidate ＝ 0，【全 12 隊，每一隊都是 0】
```
⇒ ★**沒有任何一隊解得出 build candidate** —— **不是 8 支解不出、4 支解得出。**
★★**那 4 支會嘗試的隊，走的不是 resolver 這條路**（`infra.dispatch_builder` 也是**全 12 隊 = 0**）。

## ★逐段數字（完整表在 `docs/measurements/2026-08-26-per-team-funnel-30d.txt`）
| 段 | 形狀 |
|---|---|
| **goal** | ★**每一支隊都有 build goal**：`seen` 32〜80、`kept` 4〜36 ⇒ **「沒有 goal」這個選項排除** |
| **resolver** | `entry` 20〜206（★每隊都進得去）／★★`build_candidate` **全 0**／多數落 `empty_defer_infra`（交給 infra）＋ `empty_wrong_outpost_type` |
| **infra** | 多數隊 `pick_empty` 22〜24（**走到決策了，但沒有想建的**）／`dispatch_builder` **全 0**／只有 `in_place_failed > 0` 的隊會走到牆（Team6 28、Team9 26、Team10 8、Team0 2） |
| **wall** | Team6 `begin_entry 28 / accepted 0 / reject_cannot_afford 28`；Team9 `27/1/26`；★**其餘隊幾乎全 accepted** |

## ★★★而 Team8 的缺席是【被數到的】，不是留白
```
Team8（無據點的遊走隊）：wall 整段沒出現   ←★而它為什麼沒出現，前三段都寫著：
   goal.readd_blocked_no_otile = 72｜resolver.empty_no_own_outpost = 80｜infra.guard_no_own_outpost = 28
```
★**這就是你判準①要的東西**：**「這隊那一段沒出現」本身可讀，而不是空白。**
★★**母體用的是 `state.teams` 全隊名冊**，不是 tap 印出來的那幾隊 ——
**否則「這隊沒發生」與「這隊被漏記」長得一模一樣。**

---

# ★三條判準逐條
| 判準 | 結果 |
|---|---|
| ★**per-team 加總 == 原本總數**（自證） | ✅ **36 欄，零不平**（不平會在該欄下方印 ❌，一條都沒有） |
| **`fp` 不變** | ✅ **兩顆都逐位元不變 `afd25ac245668defef3c9f56175b1dc5`**（★afford 那顆是把兩支 production 檔換回 HEAD 版各跑一次比對出來的，不是推論） |
| **不逐日** | ✅ per-team 只做總量；逐日維持現況 |
| **不動控制流** | ✅ 兩顆都是純觀測；`_can_afford` 只多一個帶預設值的參數 |

## ★做法（避免 40 處散彈）
`Probe.bump_pt(event, day_suffix, team_id, n)` —— **一個入口同時寫兩份**（日桶原樣不動＋per-team 總量）。
四族 **40 個 bump 點**機械轉換。★**護欄寫在 `probe_stats.gd` 檔頭**：
**若有人只呼 `bump` 不呼 `bump_pt`，per-team 那格不會報錯、只會少一隊 ——
★★而少掉的那一隊看起來就像「這隊那一段沒發生」。**

---

# ★下一步（我不代選）
1. ★★★**`resolver.build_candidate` 全 12 隊 = 0** —— **這跟我 8/25 報過的「`_resolve_build_facility` 從來沒有回過一次 build candidate」是同一件事，現在有 per-team 母體坐實了。**
   ⇒ ★**要不要開這條？** 它看起來比「為什麼只有 4 支隊嘗試」更前面。
2. ★`afford` 指向**供給側** —— 而供給側上一個動作（富點可見性）已經把 163 打到 64。★**要繼續推（herb／ore／gem 可見性）還是先解 ①？**
3. ★**兩顆都還沒 merge**，照你說的等 measurer 那條回來一起排。
