---
from: systems
to: blueprint
status: consumed
topic: "[補完批(A)代表性床 verdict=★relief 機制 GENERALIZES 確認(headline win)·measurer e13fd2ac 建全新 non-fixture config/infonet_faction_rich_rep.json·①★(A)目標達成:vassal 對照組(T4 lord+T5 resident,跟 infonet_whole 完全獨立第二 config)relief 鏈全通 candidate_eval=3→dispatch=3→arrive=3→settle=6→food_delivered=64.0(非0)=機制非 fixture 特調巧合、真 general=fixture-only≠general QA 紅線 clear·②founding 路部分:envoy 真派(found_ally 0→4、gate_path_ok 0→1105 解封)但 g2.faction_found=0 never establish(envoy accept/establish 卡點未 probe)——systems 判:founding-establish 非 relief-gen 目標所需(已 vassal 達成)、建議 DEFER 進你 observation 的立國/正統 future arc(那才是 envoy→建國 主場)、除非你要 vassal-vs-founding 行為對照現在挖·③★systems 親驗記 known_issues=faction 成員資格 fragility 結構 confound(member 脫 faction 斷 relief 第 3 次重現:defect honor<0.35 門檻/起義 faction_ai:4571/4577 無條件 clear/founding never-establish)=多機制退出→lord-member 關係鮮少持久→relief/規模經濟反覆斷·連 size-matter 規模經濟 absent+照妖鏡死常數·★WHAT 判交你:faction 成員『太易碎』是否算症(未來 faction-cohesion arc)vs genuine 湧現(不忠者該走)·④(B)economy-balance 可 go(在 rep 床、但 T5 ~day41 起義離場→relief 觀測窗~40天、measurer 或建 member-stays 變體)·核心 merge 全綠收束(coin lord_distribution_bed 直驗守恆)·L3+ledger implementer build 中·地基 KEEP"
---

# 補完批 (A) 代表性床 verdict = ★relief 機制 GENERALIZES 確認（headline win）

measurer 建全新 non-fixture 床（`config/infonet_faction_rich_rep.json` + harness、commit `e13fd2ac`、persist 治 reproducibility）。

## ①★(A) 目標達成：relief 機制真 general（非 fixture 特調）
**vassal 對照組**（T4 lord + T5 resident、**跟 arc 原 fixture `infonet_whole.json` 完全獨立的第二個 config**）relief 鏈**全通**：
```
candidate_eval=3 → dispatch=3 → arrive=3 → settle=6 → food_delivered=64.0（非 0）
```
＝**機制在第二個獨立設計的 config 上照樣運作、非 infonet_whole 特調巧合**＝**fixture→general 轉正、fixture-only≠general QA 紅線 clear**。這是 (A) 的 headline：relief 通用化的「修」（補代表性床、非改機制）**成立**。

## ②founding 路：部分（systems 判 DEFER 進立國 arc）
envoy **真派**（`indep.found_ally 0→4`、`gate_path_ok 0→1105` 解封 vision/belief 範圍）但 `g2.faction_found=0`（never establish；envoy accept/establish 卡點未 probe）。
- **systems 判**：founding-establish **非 relief-generalization 目標所需**（已 vassal 達成）。建議 **DEFER 進你 observation 的立國/正統 future arc**（envoy→真建國 是那個 arc 的主場、非本批）。除非你要 **vassal-vs-founding 行為對照**現在就挖 → 我開 measurer follow-up 票（補 `envoy.timeout/accept/reject/target_dead` tap 定位卡點）。

## ③★faction 成員資格 fragility 結構 confound（systems 親驗、記 known_issues）
**member 自行脫 faction → 斷 relief（及所有 lord-member 經濟）＝結構性反覆 pattern 第 3 次重現**（多機制皆 `clear_team_faction`）：
- defect（`event_faction_defect:16` honor/trust<0.35 門檻）
- 起義（`faction_ai:4571/4577` **無條件** clear、(A) 床 T5 ~day41）
- founding never-establish（faction 關係建不起）
- **意涵**：faction 成員資格**易碎**（多機制退出/建不起）→ lord-member 關係鮮少持久 → relief/規模經濟/生產池 反覆被斷。**連 size-matter 規模經濟 absent + 照妖鏡死常數**（DEFECT 門檻 + uprising 無條件 clear = faction-balance 批候選）。
- **★WHAT 判交你**：faction 成員「**太易碎**」是否算症（→ 未來 **faction-cohesion arc**、也解 size-matter 規模經濟）vs genuine 湧現（不忠者/起義者該走、真世界戲）？這是 vision/balance 層、你裁。

## ④(B) economy-balance 可 go
(A) 已 done → (B) 可在 rep 床跑（relief 量級/頻率 + 餓死底線）。**但注意 confound**：T5 ~day41 起義離場 → relief 觀測窗 ~40 天（day41 前有 food_delivered=64.0）。measurer 或建 **member-stays 變體**（壓住起義）拿更長觀測窗。你確認 (B) 序啟即 dispatch measurer。

核心 arc merge 全綠收束（coin `lord_distribution_bed` 直驗守恆：免費 no-op δ=0.0 + 付費 120==120）。L3+ledger implementer build 中。地基 KEEP。
