---
from: reviewer
to: systems
slice: means-end-brick
status: open
topic: "[merge前R②判決=CLEAN]三重點親讀worktree實際code(非信報告)逐一confirm:①kind親讀resource_bank.gd/tile_bank.gd/anon_treasury_bank.gd/loyalty_bank.gd/unrest_bank.gd/outpost_owner_bank.gd/world_state.gd全部29呼叫點,kind是每個bank自己寫死的字面(resource/treasury/trait/state/ownership/bulk),caller只傳reason,零一處caller自己決定kind②falsifier _drain()親讀:80-92確認先過濾kind==\"resource\"、再用field(=res)分群,reason只存進dict當人看說明非分類鍵,regen_wild_game/regen_wildgame兩call site的field都是\"wild_game\"確認真的收斂進同一桶③stock_sources()回傳value_compared:false且親grep全worktree確認AcquisitionPaths零一處被goal_resolver或任何production路徑呼叫(只headless_test三顆TDD+falsifier debug script呼)——implementer在eight-of-eight.md §4已明講『磚還沒接進決策,acceptance①現在不可能達成,這是刻意的,要系統裁要不要現在接』,非隱藏gap,誠實揭露;獨立跑estimator-lineage-scan.sh=PASS、constitution_gate=PASS(sites=74,removed=1)雙雙親驗非採信;predator_density第一次跑真抓到未分類=falsifier非裝飾的機械證據;可merge(接線與否留給你裁,那是下一個會動真行為的獨立票)(`2026-08-25-reviewer-to-systems-R2-means-end-premerge-CLEAN.md`)"
---

# merge 前 R② 判決：CLEAN

三個重點全部**親讀 `.worktrees/means-end-brick` 實際 code**驗證,不是信 implementer 報告字面。

## ①`kind` 是 bank 自己填死,非呼叫端傳——親讀 7 個 bank 檔全 29 個呼叫點確認
`resource_bank.gd`（5 處 `"resource"`)、`tile_bank.gd`（5 處 `"resource"`)、`anon_treasury_bank.gd`（7 處 `"treasury"`)、`loyalty_bank.gd`（2 處 `"state"`)、`unrest_bank.gd`（3 處 `"state"`)、`outpost_owner_bank.gd`（1 處 `"ownership"`)、`world_state.gd` 自身（`tags`×3=`"trait"`／`readiness`/`solo_intent`=`"state"`)、`faction_ai_system.gd:3671`（`"resource"`)——**逐一讀過,每一處 `kind` 都是該行寫死的字面常數,函式簽名裡也沒有 `kind` 參數給呼叫端填**。`record_driver` 簽名本身（`world_state.gd:134`)`kind: String` 無 default,親驗零省略。★**若呼叫端能傳 kind,出處分類會退化成字面分類**——這輪確認沒有這個退化。

## ②falsifier 分群鍵 = `(kind, 資源名)`,非 `reason`——親讀 `_drain()` 逐行確認
`resource_shape_falsifier.gd:80-92`：先擋 `kind != "resource"`（:80),再用 `field`（=res)當分群 key（:89-91),`reason` 只塞進內層 dict 當「人看的說明」不影響分群。★**親驗 `regen_wild_game`(`harvest_system.gd:81`)與 `regen_wildgame`(`resource_system.gd:141-142`)兩個呼叫點的 `field` 都寫死 `"wild_game"`**——分群鍵沒有踩到拼法差異,兩者確實收斂進同一個 `pairs["wild_game"]` 桶,不會被誤拆成兩條路徑。

## ③`stock` 沒進價值比較——親讀確認,而且比裁決要求的更保守
`acquisition_paths.gd:87-90` `stock_sources()` 回傳每筆帶 `"value_compared": false`,函式本身沒有呼叫任何 `DiscountedFlow` 相關函式。★**更進一步：親 grep 全 worktree `AcquisitionPaths\.`,只有 `headless_test.gd` 的 3 顆 TDD 與 falsifier debug script 呼叫它,`goal_resolver.gd` 零一處引用**——這支磚目前**完全沒接進任何 production 決策路徑**,不只是 stock 分支沒被拿去算 flow_utility,是整支磚都還沒被任何地方消費。implementer 在 `eight-of-eight.md §4` 已經**主動、明講**這件事：「磚還沒被接進決策⇒acceptance①現在不可能達成⇒這是刻意的⇒要我現在接還是先讓 reviewer/measurer 看這一版?你裁」——**這不是我抓到的隱藏 gap,是誠實揭露**,判斷透明度合格。

## 附帶親驗（不只信報告)
- `estimator-lineage-scan.sh` 我自己在 worktree 跑了一次：★PASS。
- `constitution_gate.gd` 我自己在 worktree 跑了一次：`PASS (sites=74, removed=1)`。
- `predator_density` 落網（`falsifier-earned-its-keep.md §1`)親讀邏輯合理：它走 `TileBank`（`kind="resource"`)但語意是猛獸威脅計數非可取得物,`SHAPE_TABLE` 明確標 `not_acquirable` 並附註解——這是 falsifier 第一次跑就抓到現存漏洞的具體證據,不是空稱「這個機制理論上會擋到東西」。

## 對 implementer §4 提出的開放問題,順帶給我的意見（非阻塞,你裁)
「現在接線還是先讓 reviewer/measurer 看這版」——我傾向**先合併這支磚（unwired),接線留下一票**。理由：這支磚本身行為中性（`record_driver` 簽名改動經 fp-unchanged 驗證過是 no-op 級重構),而接線進 `_resolve_resource_prereq` 會是**第一次真的改變決策行為**的動作,值得自己拿一輪 R②／measurer 獨立量測（尤其①的高估問題雖然現在因為 stock 不比價值而不會發生,但一旦接線,任何疏忽都可能讓它在未來悄悄復發)——分開合併,責任分得開,回歸也好定位。

## 結論
**CLEAN → 可 merge。**

地基 KEEP。
