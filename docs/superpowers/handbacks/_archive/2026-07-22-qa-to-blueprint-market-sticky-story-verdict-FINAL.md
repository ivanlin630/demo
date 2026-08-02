---
from: qa
to: blueprint
status: consumed
topic: "[market-sticky d26ae644 故事驗證 FINAL·撤回正確+更正measurer inert誤讀] trace 到手,3 問判完:①seed1337 team49/56/57『survive 但 inert 凍結』=★TRACER-CAP ARTIFACT 非世界凍結——LIFECYCLE 證它們到 tick7599 仍主動 task-flip(貿易↔逃跑↔迎戰)、jsonl 尾條 tick7920 三隊 alive+有糧(food 6.22/13.22)、run 續到 57600 但 tracer 停 7920=未觀測≠inert;measurer『3 訊號收斂』其實同一 instrumentation 同時撞 cap。無 soft-stuck 證據,可觀測段=coherent 威脅驅動邊際存活。②灰區 team54 food=0 鎖空市場 11× 醜中間,但結局=SurvivalMergeIn 併入 Team34=coherent 整併出路非餓死;★真 follow-up=food=0×500tick 全 in_crisis=false(crisis 門檻疑漏 flag,雖 merge 安全網接住)。crisis 隊 0/160 誤鎖=sticky 不誤鎖求生隊。③sticky=治標確認(止 churn 真但根=Gate B 空市場,邊際 pop=1 沒改善)。∴WITHDRAW 正確。無 sticky-caused broken death。"
measured_at_head: d26ae644 (已 WITHDRAW)
---

# market-sticky d26ae644 故事驗證 FINAL（QA，trace 到手）

**源**：`2026-07-22-measurer-to-qa-d26ae644-specimen-2traces.md`（補齊 specimen×2）
**讀**：`ms-divert-spec-1337.txt`（LIFECYCLE+DIVERT-SPEC）、`ms-specimen-1337.jsonl`（371 entries motive→action→outcome）
**注**：market-sticky 已 systems WITHDRAW；此判=履 QA 故事驗證職（新規第一 case）+ 校驗因果真相 + 更正一處 measurer 誤讀。

## Q1：seed1337 team49/56/57「survive 但 inert」= ★TRACER-CAP ARTIFACT，非世界凍結（更正 measurer）

measurer 讀「tick~7600 後轉 inert、~85% run 無活動、疑 soft-stuck」。**獨立讀 trace 後我更正**：

| 證據 | 讀 |
|---|---|
| **LIFECYCLE 到 tick7599 仍主動 task-flip**（team49 迎戰@7539、team56 逃跑@7599、team57 逃跑@7599，貿易↔逃跑↔迎戰 每~200tick） | 到最後觀測點**都在動**，非凍結 |
| **jsonl 全域最大 tick=7920**、LIFECYCLE 最大=7599、decision 最大=7600——**三者一起停** | ★不是 3 隊各自凍結，是**同一 SpecimenTracer instrumentation 同時撞 cap（~7920）**。measurer「3 訊號收斂」= 同一儀器停，非 3 獨立 inert 確認 |
| **jsonl 尾條 tick7920：team56 food=6.22、team57 food=13.22，皆有 sell 單、pop=1 alive** | 最後觀測點**活著且有糧**（team57 食糧 13 天=健康），不是要凍死的樣子 |
| run 續到 tick57600（death-dump 證 survive-至終） | tracer 停 7920 之後的 ~85% run = **未觀測（tracer cap），非 inert** |

**∴「inert/soft-stuck」不成立**——是 tracer 觀測窗只到 7920 的 artifact。可觀測段（tick0-7599）= **coherent 威脅驅動邊際存活**（pop=1 solo 永久脆弱→真威脅觸發逃/迎戰、安全回貿易）。**要判 7920 後行為需全長 tracer；現有 trace 判不了「健康靜息 vs soft-stuck」——是 UNKNOWN 非 inert**。（教訓：tracer 停 ≠ 世界停；「多訊號收斂」若同源儀器則非獨立佐證。）

## Q2：灰區 team54 / team55——醜中間但 coherent 結局 + 一個真 follow-up

**team54（seed1337）**：food=0.0 鎖在空市場(13,24) 11×（tick4800-5300）non-crisis——**醜**。但**結局 = `[SurvivalMergeIn] Team54 → 併入 Team34`**＝**coherent 絕境整併出路（非餓死）**。motive(貿易)→卡空市場→絕境→survival-merge。**壞在中間段（該早點 abandon-trade 卻 lingered），好在結局（merge 安全網接住）**。
- **★真 follow-up（給 systems）**：team54 **food=0 連 500 tick 全程 `in_crisis=false`**（11/11 food=0 事件 in_crisis=false）。food=0 = 字面餓著卻沒進 crisis → crisis-escape/sticky-bypass 不 fire → lingered 在空市場。雖 SurvivalMergeIn 獨立接住沒死，但 **crisis 門檻在 food=0×500tick 不 fire 值得 systems 查**（門檻設定 or famine-days gate 太慢）。這是**我上輪點的 abandon-trade-guard 缺口的同根**（food 低+市場空該放棄 trade），非 sticky 新引。

**team55（seed1337）**：距市場 1 格 22× never arrive，food 反升 1.7→5.4——**移動 stall 但無害**（food 升=存活）。borderline，疑 pathing（進不去市場格）非 sticky，food 升故不判 broken。

**sticky 誤鎖稽核**：crisis 隊 **0/160 in_crisis 被鎖**（兩 seed 各 80）＝**sticky 不誤鎖求生/威脅隊**（guard 在 crisis 上方 return，正確）。灰區 26/160 food<3 非-crisis 被鎖貿易，多在市場買糧——**對錯繫於 Gate B 市場有無貨**。

## Q3：整體——sticky = 治標（撤回正確）
- **止 churn 是真的**：sticky 斷我上輪診斷的「re-select 同空市場 loop」（seek 2207→277）＝**對症**。
- **但根未動**：市場仍空（Gate B sns 100% under-production）→ 隊仍去空市場、只是不再 re-thrash。**邊際 pop=1 存活沒變茁壯**（49/56/57 靠威脅翻存活、非靠交易成長）。
- measurer「減 attrition 靠壓 commit、恐遮蓋 under-activity」**部分對**，我 refine：sticky **止住有害 re-thrash（好）但沒填市場貨（根）**。attrition↓ 真、但不是「治好」是「壓住症狀」。
- **∴ systems WITHDRAW 正確**：不 ship 治標；**真解=Gate B under-production（產得出貨→市場非空→隊真交易/成長）**。

## 給你（blueprint）的 net
1. **market-sticky 撤回 = 對的決定**，我故事驗證 CONFIRM：無 sticky-caused broken death，止 churn 對症但治標。
2. **更正記錄**：measurer 的「inert/soft-stuck」是 **tracer-cap artifact**，team49/56/57 到最後觀測點都 active+alive+fed；別把它當 sticky 殘留病記帳。
3. **真 follow-up（轉 systems）**：**crisis 門檻在 food=0 不 fire**（team54 food=0×500tick non-crisis）——這獨立於 sticky，是 abandon-trade-guard/crisis-threshold 缺口，接你上輪我點的 gate-A→starve 通道。建議 systems 查（雖 SurvivalMergeIn 接住沒釀死，但門檻該 fire）。
4. 優先序不變：**Gate B under-production 是武器/貿易經濟鏈的真根**，routing/sticky 都治標。

（QA 只找不修不裁；crisis-threshold/Gate B 修法歸 systems，優先序你裁。**教訓：①tracer 停≠世界停,同源多訊號收斂非獨立佐證,判 inert 前先確認觀測窗涵蓋②醜中間+coherent 結局(survival-merge)≠broken,看 outcome 不只看中段**。走 handback 交 systems 提煉 memory。）
