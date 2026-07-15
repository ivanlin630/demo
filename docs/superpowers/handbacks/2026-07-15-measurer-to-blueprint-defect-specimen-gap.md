---
from: measurer
to: blueprint
status: consumed
topic: "[補觀察·內政維·工具缺口] 高-defect specimen嘗試——proxy法(pop掉+food健康)誤判:候選Team12早段掉是建國/envoy成本非defect,晚段掉是food=0餓死非riot;根因=specimen trace不記『哪個reaction(P1/N2/N3)觸發』,只記task/pop/food快照,測不出defect/riot敘事,需implementer在reaction_system.gd補person-level tap才能精準抓"
---

# 高-defect/riot specimen：proxy 法失敗，揭工具真缺口

## 嘗試過程
擴大網（seed1337/2674 各15隊 specimen 全開）+ proxy 判準（pop 下降時 food 仍健康(>2)＝疑似defect/riot非餓死）掃出候選：seed1337 Team12（10次pop drop，4次「健康食物時掉」，看似最強信號）。

## ★逐筆核對後：proxy 判準失效，Team12 其實是「建國成本+餓死」，非defect/riot
```
tick120  pop9→7 food=109.2 opt=建設 intent=建國(found_ally)   ← 建國派envoy成本，非defect
tick1070 pop8→7 food=60.9  opt=建設 intent=建國(found_ally)   ← 同上
tick5700 pop9→8 food=11.1  opt=覓食 intent=致富(trade)         ← 單次小掉，原因不明
tick9390-10270（連續7次掉：9→8→7→5→4→3→2→1）food 全部=0        ← 明確餓死cascade，非riot
```
**判讀**：早段的「健康食物時掉」不是defect/riot，是**建國機制派envoy出去**(_form_alliance流程消耗成員)；晚段的大量掉全是food=0的**餓死連鎖**。我的proxy(pop掉+food健康=疑似defect)誤把「建國成本」也算進去，實際上沒有一次乾淨對應到 `reaction.N2_riot`/`N3_defect`。

## ★根因：specimen trace 結構上抓不到「哪個 reaction 觸發了這次掉」
`SpecimenTracer` 現有 tap 是**團隊決策層**（task/target/candidates，`FactionAISystem._trigger_survival`/`_decide_subteam`/`_decide_unified` 的 winner commit）。但 P1_comply/N2_riot/N3_defect 是**`reaction_system.gd` 的 person 級別**反應（讀 person.stress/loyalty 擲反應），跟團隊決策 tap **是兩條不相交的路徑**——現有 jsonl 的「狀態」快照只有 pop/food/coin/material，不含「這個 tick 是哪個人因為什麼 reaction 離隊」。

**這代表**：靠現有 specimen 工具 + proxy 猜（pop 掉+食物水位）**結構上無法乾淨分離** defect/riot vs 建國成本 vs 餓死 vs 戰鬥——四種都會讓 pop 掉，trace 不記原因標籤。

## 待 blueprint / systems 裁
1. **要精準抓 defect/riot specimen，需要新 tap**（`reaction_system.gd:259/264/274/278` 的 `Probe.bump("death.defect_leave")` 旁補一個 `SpecimenTracer` 呼叫，標明 `reaction_type`(N2_riot/N3_defect/N1_flee)+`team_id`+`person_id`）——這是**新增觀測點**，非我能自建的 debug script 範疇（要動 `reaction_system.gd` 這支正式模擬檔案，不是純 debug/infra），建議走 implementer 一刀（很小，L3量級，鏡射 tracer-completeness 的 attempt-tap 模式）。
2. 若不想開新工具刀——**接受目前 aggregate 數字(riot 806-1526/defect_leave 1057-3703)作為唯一證據**，內政連貫性判斷改用 aggregate 趨勢+抽樣讀（非全生命specimen），精度較低但零額外開發成本。
3. 我這邊已產出 `2026-07-15-fullhd-observe-seed1337-Team12-defect-specimen.jsonl`（727 entries）供參考——它本身是個「建國+餓死」的另一個連貫故事樣本，只是不是blueprint要的defect/riot敘事，若QA仍想讀可當額外樣本。

---
