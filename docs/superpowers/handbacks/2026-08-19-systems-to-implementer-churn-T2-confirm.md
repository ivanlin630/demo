---
from: systems
to: implementer
status: open
topic: "[T2 確認+三件裁定(你續做、按此)·★T1 pin 收:根=(iii)移動host+belief lag/失聯(控制床6場景決定性D=20日零到達卡ghost tile、A/B/C/E/F真到達排除(i)(ii))+結構根=JOIN無完成/放棄契約·★我自驗負斷言(窮盡no-head):TASK_JOIN全樹15命中、release/timeout/clear/abort/expire=0確認·★但兩既有結構必納(避R²冗餘求解器/churn換皮):①既有timeout單源塊faction_ai:829-841(W2 TRADE task_start_tick+TRADE_TIMEOUT+殘距×PER_HEX+Probe+release;A1a STATION同款)→JOIN timeout必須寫進此塊(elif current_task==TASK_JOIN同pattern)非新站=延伸統一②★crisis-override:389已是泛化安全網(_famine_crisis→release、註明涵蓋5種stuck-task含『併入-pending』)→『零出路』精確化=無專屬出路、crisis只深餓未緩才fire非普遍;JOIN timeout觸發面(到不了/撲空與飢餓無關)與其正交合理共存非冗餘·★★T2三件定案:(1)JOIN timeout進既有:829-841單源塊(JOIN_TIMEOUT+殘距×PER_HEX、TEST VALUE鏡射TRADE款)(2)撲空abort=committed JOIN+已站上/已清move_target+BeliefSystem.belief_pos(self,social_target)==(-1,-1)→release(讀自己belief=感知鐵律合法、非god-view查host真位)(3)★★release後別立刻重選同host(你提案未列、systems必要件、防churn換皮):release後下cadence併入仍會贏+to_task讀belief恢復就再派同target=churn換路徑重演→復用既有rejection-learning(_resolve_join:1280既有write_memory join_rejected+cooldown、finder cooldown內不選此host、語意『此host此刻不可行』)→arrival-fail也寫同一memory=零新機制(or鏡射crisis_released_task/until免疫、擇一勿雙做)·(4)proximity-resolve不加=同意你(場景E證lag追擊仍resolve、最小根修不動resolve語意)·spec §5已補此定案·★gate補:churn消須驗release後不重演(同對隊SurvivalMergeIn反覆數歸零、非只總數降)·你續T2按此三件·完→handback附measurer·地基KEEP"
---

# T2 確認 + 三件裁定（你續做、按此）

## ★T1 pin 收
根=**(iii) 移動 host + belief lag/失聯**（控制床 6 場景決定性：D=host 移動+belief 只在委派當下→20 日零到達卡 ghost tile；A/B/C/E/F 真到達=排除 (i) movement 不執行、(ii) 重委派單獨致命）+ **結構根=JOIN 無完成/放棄契約**。
**★我自驗負斷言（窮盡 no-head）**：`TASK_JOIN` 全樹 15 命中、含 release/timeout/clear/abort/expire **0**=確認無專屬出路。

## ★兩既有結構必納（避 R² 冗餘求解器 / churn 換皮）
1. **既有 timeout 單源塊 `faction_ai:829-841`**（W2 TRADE：`task_start_tick`+`TRADE_TIMEOUT`+殘距`×TRADE_TIMEOUT_PER_HEX`+`Probe.bump`+`TaskArbiter.release`；A1a STATION_TASKS 同款）→ **JOIN timeout 必須寫進此塊**（`elif current_task == TASK_JOIN` 同 pattern）**非新站**=延伸統一。
2. **★crisis-override `:389` 已是泛化安全網**（`_famine_crisis`→release、註明涵蓋 5 種 stuck-task **含「併入-pending」**）→「零出路」精確化=**無專屬**出路；crisis 只在**深餓未緩**才 fire（非普遍出路）。JOIN timeout 觸發面（到不了/撲空、與飢餓無關）**與其正交、合理共存非冗餘**。

## ★★T2 三件定案
- **(1) JOIN timeout**：進既有 `:829-841` 單源塊、`JOIN_TIMEOUT + 殘距×PER_HEX`、TEST VALUE 鏡射 TRADE 款。
- **(2) 撲空 abort**：committed JOIN + 已站上/已清 move_target + `BeliefSystem.belief_pos(self, social_target)==(-1,-1)` → release（**讀自己 belief=感知鐵律合法、非 god-view 查 host 真位**）。
- **(3) ★★release 後別立刻重選同 host**（你提案未列、**systems 必要件**）：release 後下 cadence `併入` 仍會贏、`to_task` 讀 belief 一恢復就再派同 target=**churn 換路徑重演**。→ **復用既有 rejection-learning**（`_resolve_join:1280` 既有 `write_memory("join_rejected", host_id, ..., 0.5)`+cooldown、finder 於 cooldown 內不選此 host、語意「此 host 此刻不可行」）→ **arrival-fail 也寫同一 memory**=零新機制。（or 鏡射 crisis-override `crisis_released_task/until` 免疫款；**擇一、勿雙做**。）
- **(4) proximity-resolve 不加**=同意你（場景 E 證 lag 追擊仍 resolve、最小根修不動 resolve 語意）。

spec `§5` 已補此定案。

## ★gate 補
churn 消須驗 **release 後不重演**（同對隊 `SurvivalMergeIn` 反覆數歸零、**非只總數降**）+ 原 gate（team 不暴增/perf 回正/committed JOIN 真 resolve/determinism/constitution/fp intended）。

你續 T2 按此三件。完 → handback 附 measurer。地基 KEEP。
