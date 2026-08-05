---
from: measurer
to: qa
status: open
topic: "cohesion①natural最終考(care-loop,feat/lord-care-loop a24d4c71)結果→QA故事稽核(specimen 2285 entries):用既有moderate-distress ex-ante判準床(D=5hex,44天calm buffer)測。★決策層乾淨分化(care/ignore argmax真依人格分化,lord0好領主全選care/lord2壞領主全選ignore,零交叉)——但★執行層斷:care.scout_dispatched=0(47次care決定,0次真派scout)。temp-print定位到_dispatch_care_scout的SubteamSystem.dispatch_anon_messenger回傳sid=-1(population始終12-15正常≥2,vpos/dist皆正確解析(21,16)/dist=5,唯一剩候選=AnonTierSystem.total_pop(parent)<1即anon池耗盡)。結果T1/T3仍同day44/45退出,跟care-loop前完全相同exit_day——這輪cohesion①natural的分化仍未展現,但這次卡點已精確定位到執行層(非決策層/非target-resolution/非race-timing),請讀specimen判斷是否為anon池耗盡+建議systems查AnonTierSystem.total_pop在此fixture下為何耗盡。"
---

# cohesion①natural最終考（care-loop）→ QA 故事稽核

## 背景

工單要求驗證 `feat/lord-care-loop`(`a24d4c71`) 的cohesion①natural收官：好領主proactive care→建恩義史→分化活。用既有 `infonet_moderate_distress_fragility.json`（ex-ante判準：D=5hex/44天calm buffer/物理最短relief延遲≈2.02天，已persist）床，同seed7070/65天。已persist commit `1e474797`（`.worktrees/lord-care-loop`）。

## 原始輸出（已ls/wc驗證落地）

- `docs/measurements/2026-08-05-care-loop-cohesion1natural-65d.txt`（8635行）
- `docs/measurements/2026-08-05-care-scout-debug.txt`（1100行，`_dispatch_care_scout`定位診斷）
- `docs/measurements/2026-08-05-infonet-care-loop-cohesion1natural.json`（1385行聚合，含`care_sample`per-lord歸因）
- `docs/measurements/2026-08-05-infonet-care-loop-cohesion1natural.specimen.jsonl`（2285行）

## 結果

```
T1(GoodMember)/T3(BadMember): 仍同day44/45退出（跟care-loop前完全一樣的exit_day）
contact.overdue=96  contact.care_check=47  contact.care_ignore=47
care.scout_dispatched=0  care.firsthand_distress=0

★per-lord care_sample歸因（乾淨分化，非交叉污染）：
  lord0(GoodLord,義氣0.8/統領0.7): 47次全部"care"
  lord2(BadLord,野心0.85/義氣0.15): 47次全部"ignore"
```

## ★★決策層 vs 執行層：乾淨分化 vs 完全斷鏈

**決策層（care/ignore argmax）100%乾淨分化**——好領主lord0面對overdue holding entry，47次全部選"care"；壞領主lord2 47次全部選"ignore"，零交叉。這正是spec要的「人格秤決定」。

**但執行層（真派scout）完全斷鏈**：`care.scout_dispatched=0`——lord0的47次"care"決定，**一次scout都沒真的派出去**。

## ★temp-print定位（已補到`_dispatch_care_scout`，量完revert確認乾淨）

```
[CSDBG] lord=0 vid=1 vpos=(21, 16) dist=5 sid=-1   （重複47次，數字完全一致）
```

- `population`全程12-15（早期log顯示，遠高於`<2`門檻——非population不足）。
- `vpos`正確解析到resident的真實位置`(21,16)`，`dist=5`跟fixture設計一致——非belief/position問題（跟先前`_resolve_help_target`那次不同，這次belief鏈路是通的）。
- **唯一剩下的候選**：`SubteamSystem.dispatch_anon_messenger`內部`AnonTierSystem.total_pop(parent)<1`（無anon可分當信使）——這是`sid=-1`的另一個可能return點（`subteam_system.gd:75-76`），population檢查(`<2`)已排除，剩這個。**我沒有進一步深挖AnonTierSystem在這個fixture下為何耗盡**（可能是lord0這65天期間其他side-dispatch/redispatch reaction把「平民」anon tier耗光，也可能有別的原因）——這超出temp-print能直接看到的範圍，交系統判斷是否要繼續深挖或這就是答案。

## 誠實淨判

- cohesion①natural**仍未展現真分化**（T1/T3 exit_day不變）——但**故事比之前任何一輪都精確**：不是target-resolution問題（已排除）、不是race-timing問題（決策層48小時內就做出care決定，遠早於day44危機）、是**執行層的資源可用性問題（anon池，疑似耗盡）**擋住了整條鏈。
- 決策層本身（care/ignore人格分化）**做對了**，這是好消息——如果執行層的anon耗盡問題解決，理論上鏈條後面該接得上（我已確認的`distribute.dispatch`/`cohesion.benefactor_write`等既有tap路徑仍在，只是這輪從未有機會被觸發到）。

## 下游

QA讀specimen判斷lord0這65天anon消耗軌跡是否支持「anon池耗盡」假說，或有別的解讀；供systems判斷是否要查`AnonTierSystem`層面的fix。

## 清理

- temp print（`_dispatch_care_scout`診斷）+temp bump_sample（`care.reaction_sample`per-lord歸因）皆已`git checkout --`revert確認乾淨。
- bed script（新增5個care-loop tap）已persist commit `1e474797`。
