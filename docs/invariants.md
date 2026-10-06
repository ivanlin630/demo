# Invariants

> 每 session 開頭讀一次。★一條一行（≤200 字）；血證、enforcement 細節、file:line 在 `process/detail/invariants-cases.md`（〔detail#錨〕＝同名小節；〔detail 快照〕＝2026-10-07 全文快照同標題節）。

## ★ 沙盒憲法（governing invariant，凌駕級，藍圖 2026-07-05）

**凡 NPC 行為必經統一決策引擎（means-end 子需求＋utility weigh，人格調製）；禁繞過引擎的行為規則／判斷器／行為 subsystem。行為是引擎輸出，永不是輸入。**〔detail 快照〕

- **作者寫世界，不寫決策**：世界規則（物理、代價、資訊霧）該有；行為規則（`if 食物<X then…`、prescribe 的判斷器）＝違憲。
- **強制閘**：`constitution_gate.gd` 掃 simulation 的 transition／try_set 呼叫面比對 baseline；新增＝FAIL、移除＝PASS。〔詳 detail#inv-site-freeze〕
- **零例外**：絕境＝survival utility 在引擎內支配；遠方＝疏非慢非笨。既有行為 subsystem 一律溶進引擎。
- **北極星**：遭遇＝統一反應——五結局是同一 encounter 評估的不同 option，不溶成孤島。〔詳 detail#inv-encounter-north-star〕
- **★感知鐵律**：威脅／身分感知只吃可見表象＋已知關係（belief＋`known_reputations`）；禁讀對方 tag 或真實意圖。〔詳 detail#inv-perception-iron-law〕
- **★細則 1a**：決策路徑上每個他隊欄位都必須是 belief 欄位（閘前閘後都算）；belief 三態，unknown 不通過、禁 fallback live。〔詳 detail#inv-belief-fields〕
- **★深度靠感知非規則**：加深度＝讓更多狀態可被感知；禁為每種社交組合寫新規則。〔詳 detail#inv-depth-by-perception〕
- **★孿生條**：引擎零 scenario 假設；規模／結局／好戲旋鈕活在 seed／param 層；believability 尺不越線變硬限制。〔detail 快照〕

## ★決策模型：感知→腦→行為（藍圖 2026-07-06）

- **引擎是唯一的秤**：技能過濾感知 → 人格＋記憶＋現況能力三腳秤 → utility argmax；同一感知不同腦 ⇒ 不同行為。〔detail 快照〕
- **★B 重框**：塑造行為的全域常數門檻不該存在，門檻只活在世界代價或人格／記憶／現況裡；冒出具名 margin／gate 常數＝照妖鏡響。〔詳 detail#inv-b-reframe〕
- **★域專判斷器**：合法＝真穿人格／記憶／現況＋讀同一組人格值。〔詳 detail#inv-domain-scorer〕
- **★人格 WEIGH 不 GATE**：人格只加權、不開關選項；世界物理約束不算。〔詳 detail#inv-weigh-not-gate〕
- **① 下游零決策**：下游純執行，供狀態給思考層讀＝OK。〔詳 detail#inv-downstream-no-decision〕
- **★手不聽腦**：所有 current_task 寫入守 arbiter 鎖；emergency 正當退場走 release。〔詳 detail#inv-hand-obeys-brain〕
- **② 下游零干擾**：一狀態一 owner；同概念不各算（單一源 oracle）；tick 順序走 registry。〔詳 detail#inv-downstream-no-interference〕
- **RNG 三案**：純骰無人格選行為＝de-patch；世界不確定 outcome＝合法；人格加權機率＝合法 IF 曲線陡。〔詳 detail#inv-weighted-random〕
- **★單一源 oracle**：oracle 外另算同概念＝違規必遷；oracle 內暫為常數＝可接受 deferred。〔詳 detail#inv-single-source-oracle〕

## ★ 全量暫態可觀測性（governing invariant，憲法同級，用戶 2026-07-14）

- **任何改動不准製造量測盲點**：新增決策層／資源／狀態機必同步接 tap（想法／狀態／資源三類）；dump 可 scope，tap 不打折。〔detail 快照〕
- **已坐實**：隊伍資源層零不經 ResourceBank 的寫入；tile 倉庫／自然池／person.coin 由帳本守恆床證。〔詳 detail#inv-ledger-proven〕
- **★觀測者中性**：不耗 global RNG、不污染 Probe；specimen A／B／無三跑 byte-identical。〔詳 detail#inv-observer-neutral〕
- **★specimen 完整性**：完整一生（≤6h 無洞）＋全決策路徑（含 commit-fail）。〔詳 detail#inv-specimen-complete〕
- **★決策用聚合必附 3–10 個樣本**（`Probe.bump_sample`）。〔詳 detail#inv-aggregate-samples〕
- **enforcement**：`observability_gate.gd`＋`tracer_completeness_test`＋`_begin/_end_observe`。〔詳 detail#inv-observability-enforcement〕

## ★執行失敗反饋鐵律（用戶立法 2026-08-21；憲法級）

- **執行失敗＝事件，必反饋決策層（失敗記憶／壓分或 T0 喚醒），禁靜默丟棄；同一原因禁無記憶反覆撞。**〔detail 快照〕

## ★感知鐵律的鏡像：決策不得讀不到自己的狀態（2026-08-25）

- **blind-view**：同一流程裡「產出／檢查」與「投入／扣款」若讀不同的池集，就是腦沒有眼睛。〔detail 快照〕
- **第三端（顯示）**：玩家走法不印真值·debug 區；它只活在明確的 debug 走法下，自驗雙向。〔詳 detail#inv-display-boundary〕

## ★可慢不可卡（用戶立法 2026-09-10；憲法級）

- **畫面節奏均勻＝硬要求、吞吐＝軟要求**：一次做完一大批的設計先問會不會凍 frame；正解是跨 frame 分攤，不是做得更快。〔detail 快照〕

## ★其餘不變量 → 索引（全文在 detail 同標題節；搬家不是廢止）

域：World／Map／Time／Information／Simulation／關鍵設計規則／對稱性／玩法節奏／UI 邊界／NPC／Interaction／Anon／Task／財產 / 守恆／飢餓 / 人口／team reference 契約／Leader 繼承單一 owner／訂單系統／隊目標單一 owner = leader 野心階梯
另有：三條對稱不變量｜意圖驅動完備｜統一搬運脊椎｜統一勞力池｜資料模型不變量｜關係圖｜私人脫軌｜混合協調｜perf 優化 arc｜resource 分類學｜競爭範圍與承諾優先級解耦｜死亡窗口決策紀律｜LOD 降頻補償｜長跑量測床三硬規｜承諾態只能經仲裁移轉｜specimen 血緣封閉｜means-end 無手段終止不得靜默
- ★**觀測器禁任何副作用**：不耗 RNG、查詢面不交出本體、被當查詢用的指令其寫入路徑在查詢版走不到。〔詳 detail#inv-observer-no-side-effect〕

## ★近期立的不變量（一條一行；血證在 detail 同標題節）

1. **跑 tick 的床必接 `advance_tick` 回傳值**，印首次非推進的 tick 與原因；分母＝有效窗。〔詳 detail#inv-1〕
2. **T0 事件瞬醒**：喚醒單一真值＝`WorldEvents`、排程＝`CadenceStagger`；預設全喚醒、例外寫理由。〔詳 detail#inv-2〕
3. **守衛掛在一定會發生的事上**（每 tick 的 dispatch），不掛在有人來問才走的估算器上。〔detail 快照〕
4. **儀器要自述盲區**，形式＝印在它的輸出上。〔詳 detail#inv-4〕
5. **文件引用 tick 常數寫時長不寫 tick 數**（「＝2 天，值見 code」）。〔detail 快照〕
6. **回傳決定的介面必須同時回傳依據**（孿生視圖），不讓下游重算。〔詳 detail#inv-6〕
7. **記帳可以閘，語意不可以**：`Probe.enabled` 後只掛 tap；至少一格驗收跑在 Probe 關閉下。〔詳 detail#inv-7〕
8. **只動相位不等於行為中立**：頻率拆計數與間距；錯開的單位＝系統的粒度。〔詳 detail#inv-8〕
9. **`state.teams` 有真隊／野獸／在外子隊三種**，量測必須聲明指哪一種。〔詳 detail#inv-9〕
10. **按鍵意義不得由同一 tick 內會變的計數決定**；判別子是玩家改的狀態；強制回應獨佔字母、數字母體各自獨佔。〔詳 detail#inv-10〕
11. **床把本來會紅的格登成「已知」時，DONE 行必印「已知紅排除: N（id…）」**；N>0 不得稱全綠（runner 結語照此印）；交玩的綠＝已知紅 0。
