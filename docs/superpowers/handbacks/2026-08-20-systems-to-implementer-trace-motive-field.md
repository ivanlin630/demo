---
from: systems
to: implementer
status: open
topic: "[dispatch 小觀測 slice(考前必做、因為大考主儀器就是 QA 讀故事)·問題:QA 讀 specimen trace 判故事時被 intent 欄誤導——team8 tick720 task=逃跑 winner=survival 但 intent=『致富/貪婪驅動』、team9 整段 7200 tick intent 停在『防衛/備戰守土』即使後段真正驅動決策的是缺糧·★我 code-read 出真相=不是 stale bug,是【兩層混用同一欄名】:trace 的 intent 來自 SpecimenTracer.capture_intent(:78) tap,而該 tap 掛在【戰略層】(_emit_goal / _evaluate_independent_strategy、慢 cadence)=戰略姿態,不是本 tick 決策 winner 的動機·★T1 改名:trace 輸出欄 intent→strategic_intent(含 why/mode 一起)、讓讀者一眼知道它是慢層姿態·★T2 補【本 tick 動機】欄:至少要能答『這個 winner 為什麼贏』——最低限度=winner 的主需求層(need_urgency argmax 的 narrative_label,現成)+已有的 candidates util 陣列;若成本可控再加 winner 的最大貢獻 term(rank_scored 已算 term 值,若能無損取出就給,取不出【不要】為此重算 term loop=觀測禁改被觀測物、且 EWMA 解耦剛修完同族病)·★T3 禁踩:capture 路徑仍在 _begin_observe 內(禁耗 global RNG/禁寫 state);新欄純讀現成值·gate:specimen bed 跑一次看新欄有值+★specimen_neutrality_bed 零分岔(必跑、這正是剛修好的東西)+det×3+headless 0-new+fp 應 byte-identical(純觀測)·完→handback to:systems·地基KEEP"
---

# dispatch：specimen trace 的「動機」欄修（考前必做）

**為什麼考前**：大考的主儀器就是 **QA 讀故事**；欄位誤導會讓整場大考的故事判讀失真。

**問題**：QA 讀 trace 判故事時被 `intent` 欄誤導——team8 `tick720` `task=逃跑 winner=survival` 卻 `intent=致富/貪婪驅動`；team9 整段 7200 tick `intent` 停在「防衛/備戰守土」，即使後段真正驅動決策的是**缺糧**。

★**我 code-read 出的真相：不是 stale bug，是「兩層混用同一欄名」**——trace 的 `intent` 來自 `SpecimenTracer.capture_intent`(:78) tap，而該 tap 掛在**戰略層**（`_emit_goal`／`_evaluate_independent_strategy`、**慢 cadence**）＝**戰略姿態**，不是本 tick 決策 winner 的動機。

- **T1 改名**：trace 輸出欄 `intent` → **`strategic_intent`**（連 `why`/`mode` 一起），讓讀者一眼知道它是**慢層姿態**。
- **T2 補「本 tick 動機」欄**：至少要能答「**這個 winner 為什麼贏**」——最低限度＝winner 的**主需求層**（`need_urgency` argmax 的 `narrative_label`，**現成**）+ 已有的 candidates util 陣列。若成本可控再加 winner 的**最大貢獻 term**（`rank_scored` 已算 term 值；**若能無損取出**就給，**取不出就不要**為此重算 term loop——觀測禁改被觀測物，且 EWMA 解耦剛修完同族病）。
- **T3 禁踩**：capture 路徑仍在 `_begin_observe` 內（禁耗 global RNG／禁寫 state）；新欄**純讀現成值**。

**gate**：specimen bed 跑一次看新欄有值 + ★`specimen_neutrality_bed` **零分岔**（必跑，這正是剛修好的東西）+ det×3 + headless 0-new + **fp 應 byte-identical**（純觀測）。完 → handback to:systems。地基 KEEP。
