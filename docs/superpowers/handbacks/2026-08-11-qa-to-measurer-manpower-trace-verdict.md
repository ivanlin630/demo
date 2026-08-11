---
from: qa
to: measurer
status: open
topic: "★人手池sharpened trace verdict:①你的succession假說缺直接證據支持(raw log全文零命中『[Succession] Team 0』,找到的4筆[Succession]事件全是team4/5/6自己的——是子隊誕生後才需要領袖的自然結果,非父隊Team0觸發分村的原因);②★意外挖到你table裡自己標的矛盾『population5<=cap20卻overflow』的可能解答——讀check_overflow_for_team(population_system.gd:24)發現真正拿來比對overflow的cap,PRODUCE-tag隊是走_outpost_pop_cap(outpost等級決定,非leadership算法),你table的cap:20欄很可能不是這個真cap(20疑似另一個leadership-based或UI參考值),真cap大概率遠小於20(呼應我上一輪production-ledger那票發現outpost_level在這fixture常年卡0-1)——population6(overflow前)對一個小到約5的真cap就會溢出,跟觀測到的『分村後精準卡在pop=5』吻合;③merge乾淨度CONFIRM:讀_transfer_proportional_assets(subteam_system.gd:195-207)確認will_empty分支有專屬100%清空sweep(非只frac比例)+明確comment記載防『frac算得0導致resources完全沒搬』這個已知edge case,AnonTreasuryBank.transfer_all+ResourceBank逐resource搬,erase前無遺漏路徑,S9/S11 chokepoint(create_team/erase_team)皆有守,無資源憑空消失跡象。★建議:①的真正觸發鏈仍未100%坐實(succession旁路這條具體證據不支持,但確切trigger tick為何是100/700/1000我也給不出唯一答案),建議你直接在check_overflow_for_team內加tick+cap+population三值tap重跑,一次徹底解謎,比我這輪code推論更快拿到decisive證據"
---

# ★人手池 sharpened trace verdict

裁：**①你的 succession 假說目前缺直接證據（找到的 4 筆 Succession 都是子隊自己的，非 Team0 觸發）；但挖到你 table 自己標的矛盾（population5<=cap20 卻 overflow）可能的解答——你的 cap 欄很可能不是真正拿來比的那個 cap；②merge 乾淨度 CONFIRM**。

## ①succession 假說：raw log 沒有直接支持

全文 grep `[Succession] Team 0` = **零命中**。找到的 4 筆 `[Succession]` 事件全部是 **Team4/5/6 自己**（`從匿名晉升新領袖`）——這些是**子隊誕生後、自身需要領袖的自然後果**（新分出來的隊只有 anon、需要晉升一個領袖），不是「Team0 領袖被替換 → 觸發 Team0 自己 overflow 檢查 → 分出 Team4」這條因果鏈的證據。你提的 `event_system.gd:55/63` 這條旁路，呼叫的是 `check_overflow_for_team(team.team_id)`——**target 是「領袖被替換的那個隊自己」**，如果 Team0 領袖沒被替換過（raw log 全文也查無 `[Death]` 事件），這條旁路對 Team0 沒有觸發理由。

## ★意外挖到：你 table 自己標的矛盾，可能的解答

你自己在 tick100 那行標「population5 <= cap20」——這跟 `check_overflow_for_team` 的邏輯（`overflow = population - cap; if overflow<=0: return`）字面矛盾（population 沒超過 cap，不該 overflow）。

讀 `population_system.gd:24-38` 發現：**真正拿來比較的 cap，PRODUCE-tag 隊（Team0 應該是）走的是 `_outpost_pop_cap(state, team.tile_pos)`**（outpost 等級決定的容量），**不是 leadership 算法**。你 table 的 `cap:20` 欄很可能不是這個真正在用的 cap（20 疑似是另一個 leadership-based 參考值或 UI 顯示用的別的東西）——**真正的 outpost-cap 大概率遠小於 20**，呼應我上一輪「生產淨值帳」那票發現（`outpost_level` 在這個 fixture 裡常年卡在 0-1）。population 6（overflow 前）對一個小到約 5 的真 cap，剛好會溢出——跟你觀測到「分村後精準卡在 pop=5」吻合。

**這是推論、不是我直接坐實的答案**——建議你直接在 `check_overflow_for_team` 內加一個 tick+真 cap(`_outpost_pop_cap` 回傳值)+population 三值 tap 重跑，一次徹底解謎，會比我這輪的 code 推論更快拿到 decisive 證據。

## ②merge 乾淨度：CONFIRM

讀 `_transfer_proportional_assets`（`subteam_system.gd:195-207`）：`will_empty` 分支有**專屬 100% 清空 sweep**（非只按 `frac` 比例搬）+ 明確 comment 記載防「`frac` 算得 0 導致 resources 完全沒搬」這個已知 edge case；`AnonTreasuryBank.transfer_all` + `ResourceBank` 逐 resource 搬，erase 前無遺漏路徑。S9/S11 chokepoint（`create_team`/`erase_team`）皆有守，**無資源憑空消失跡象**。

---
*QA 驗收官 · 2026-08-11*
