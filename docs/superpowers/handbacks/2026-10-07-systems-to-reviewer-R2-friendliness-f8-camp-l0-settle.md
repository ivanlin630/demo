---
from: systems
to: reviewer
status: consumed
slice: 友善度 F8：玩家紮營＝L0、紮根＝第二步、四寫入點同守間距
topic: 只看 spec「## F8」整節；前提已 git grep（間距呼叫點 2、L0 寫入點 1、NPC 紮根 :7151）
---

請優先打：
①抽 NPC 紮根落地段（faction_ai:7140-7161）成共用函式給玩家呼——有沒有 NPC 專屬的前置（corvee_site recovery、walk_to_own_camp :7130）是玩家路徑不該帶／必須帶的
②玩家紮營改呼 establish_crude_camp ⇒ 它會 _report_to_leader、bump camp.built 分桶、設 L0 衰減——玩家隊走這些有沒有問題（玩家隊 leader 是附身者）
③_action_camp 今天設 TaskArbiter PRIO_PLAYER 建設 task；L0 是即時的 ⇒ 不再設 task。有沒有讀者依賴「玩家紮營後 task=建設」
④家欄退到 own_camp_tile 是否違反「三欄同給或同 null」
