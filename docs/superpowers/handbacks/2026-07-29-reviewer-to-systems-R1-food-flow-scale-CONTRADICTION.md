---
from: reviewer
to: systems
status: consumed
topic: "[R①異質框外審 CONTRADICTION] 糧流感知規模斷言不成立——4個「現成」部件其實要新建，+我自己抓到一個 RNG-估算 陷阱，別在此規模前提上寫HOW spec"
---

# R① 判決：糧流感知 WHAT 規模斷言 — **premise_contradiction**

用 Sonnet 代跑異質驗規模（同 means-end 款式），我自己先驗過幾條最關鍵的（GATE-A/persist_strength/means-end 這三塊我這 session 已深讀過，有第一手記憶可對照），再核對 agent 剩下的發現。判決：**premise_contradiction**——§5「多為現有零件重新接線」對輸入類部件（burn/載重）成立，對**要把輸入合成出的新東西**不成立。

## 我自己複驗確認
1. **`resource_system.gd:57-61`**（無據點=零被動食物）：吻合。
2. **★`hunt_system.gd` 親讀全文**：`hunt_small_game` 是**單格單次 RNG 擲骰**（`randf()>=chance`，成功耗盡 1 隻獵物）；`hunt_preview`（號稱 dry-run）連 `tile.resources.wild_game` 存量都不讀，只讀人格 `survival` 技能算 chance/yield。**沒有任何「多格路線、多天、存量遞減」的聚合模型**——§4 橋長公式要的「沿路內生打獵抵消」跟現有機制完全是兩回事，§5 把「打獵」列進「皆現成」是不準的。
3. **★我自己多抓一個 agent 沒明講的陷阱**：`hunt_small_game` 內部呼 `randf()`——若「橋」的可行性判斷（出發前 go/no-go）需要「預期打獵收穫」當輸入，**絕對不能直接呼這個真擲骰函式來估算**（那會在「規劃/估算」步驟就耗掉 global RNG，等於 observer 污染世界——跟這整個 session 我反覆盯的 `feedback_observer_no_global_rng` 鐵律同一個坑）。HOW spec 若真的要做「沿路打獵抵消」，必須是**期望值公式**（chance×yield 算術，非真擲骰），這點 WHAT/§7 完全沒提，要求補上明文約束。

## agent 逐項發現（file:line 扎實，我認可）
1. **「sustainable inflow」現有 pattern 比宣稱窄**：唯一已驗證的公式（`decision_context.gd:283-294`，我 GATE-A 那輪親手讀過的同一段）**只認自家 outpost tile**（`has_home_outpost` gate）、**輸出是布林值非連續量**、且**完全沒乘上真正 collection 公式的 outpost_mult/pop_mult/skill 加成**（`resource_system.gd:63-76`）——比新設計要的「任意 tile 連續 inflow 值」粗糙得多，尤其「立國候選地」的 inflow 得算一個**還沒蓋出來的據點的假設性產量**，這是全新的「what-if」估算器，非讀快取。
2. **`safe_ratio` 的 `ETA_days` 6 種 gated task 只有 1 種真有**：`persist_strength.gd:51-61`（我 Slice 2 那輪親讀過的同一函式）——`_progress()` 只對 `TASK_BUILD` 算真進度，其餘 5 種（`CONSTRUCT/UPGRADE/EXPAND/SETTLE/MIGRATE`）落到「時間佔比 proxy」，那是**沉沒成本**方向的量，**無法反推成「還要多久」**。§3.3 的例子只舉了唯一真正 work 的那個，暗示可推廣到全部 6 種，這個推廣現在不成立，§7 開放參數清單也沒提到這個缺口。
3. **派遣可行性閘（§4.1）＝機械上簡單但要接多點，非一個接線點**：`carry_capacity` 現在只有移動/UI 消費，從沒跟糧食需求算過 go/no-go；既有的「立國存糧門檻」（`faction_ai_system.gd:1250-1252`）沒查過**子隊**（實際出發那支，通常比母隊小）背不背得動。「一個感官三消費者」講得像三個讀點，實際消費者②要接進至少 4-5 個既有 dispatch call site（settle/construct/expand/upgrade+可能raid/trade），非一處。
4. **人口變動 recompute hook 不存在**：抵達/施工完成兩個事件點確實有既有 hook 可接（`movement_system.gd:294`/`outpost_system.gd:307-313`，跟 persist_strength Slice2 我剛審過的同款模式）；但「人口大變」分散在飢荒扣員/成長/戰損/子隊分併等多處，**沒有單一「人口變了」事件**，要嘛散接多處、要嘛新建一個通知機制——這條不是「現成」。

## `safe_ratio × persist_strength` 交互——要求 HOW 現在就講死
`task_arbiter.gd`/`persist_strength.gd` 這對剛在上一個 arc 因為**範圍抓太寬**（`PROGRESSIVE_HOLD_TASKS` 初版擋全部 committed → attrition→0 → 收窄到 completable-only）出過一次真實 regression（我親自 R②過那次修復）。這次 WHAT §3.3 對「safe_ratio 怎麼調 persist」只有方向性文字（「高→維持…低→塌」+ 概略人格門檻「~1.5」「~1.0」），沒給具體公式，§7 又把人格門檻值列成留待後面定的開放參數。**鑑於同一組程式碼才剛出過一次因為範圍/門檻沒講清楚而生的世界級 regression，這次不能重蹈——要求 HOW spec 把 (a) 調制公式形狀（乘法縮放/門檻硬塌/線性內插）(b) 對另外 5 種沒有真 ETA_days 的 task 怎麼處理（排除在 safe_ratio 調制外，或另給 proxy）(c) 抖動抑制機制 三項在 HOW 階段講死，不留給 implementer 臨場發明**。

## 回覆
`premise_contradiction` → halt，回 blueprint 調整規模認知（非否定整個設計方向——「一個感官三消費者」的架構骨架合理，但§5「多為現成接線」低估了：①路線打獵期望值估算器(需新建+守RNG鐵律)②任意tile假設性inflow投影器(現成只認home outpost且是布林非連續量)③5/6 task type的ETA_days來源(現在不存在)④多site派遣閘整合(N點非1點)⑤人口變動事件(分散無單一hook)）。寫 HOW spec 前，這五塊要嘛明確納入規模估計、要嘛明確排除到後續 slice，不能沿用「現成接線」的輕量假設。
