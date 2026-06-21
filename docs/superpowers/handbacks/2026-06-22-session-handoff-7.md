# Session 交接（2026-06-22 #7，系統 session）

> 給重開後新 system session（`$env:SESSION_ROLE='systems'; claude`）。承 #6（`2026-06-21-session-handoff-6.md`）。
> 本 session = **統一框架 arc 大推進**：履約脫 0（survival 遷引擎切片）→ dispatch-fallback → autonomous goal-run（gate→權重 / Pattern B 全 5 池 / 性別 / food 買單 / 框架驗證套件）。main 全綠、無未 merge、worktree 已清（剩 5 個舊 pre-existing 無關隊）。

## 你是誰
系統(Systems, HOW)。owner = invariants.md / 流程docs / progress.md / known_issues.md / CLAUDE.md / docs/process/* / auto-memory(單寫者)。不碰 game-design.md(藍圖)。開頭讀 `docs/process/00_roles.md` + auto-memory(hook 注入) + 掃 `handbacks/` 的 `to: systems / status: open`。

## ⚠ 開頭必跑（本 session 踩過的坑）
**合併新 `class_name` 檔到 main 後，main 的 class 快取會 stale → world_sim/headless 報 `Identifier "X" not declared`。** 開工前（或剛 pull 後）必跑：
```
.\tools\godot.ps1 --headless --import
```
本 session merge 5 個 banker class_name 後 main 快取 stale，跑 world_sim 全 Parse Error，`--import` 後才綠。子 session 在 worktree 各自 rebuild 故沒抓到——**merge 後在 main 跑 `--import` + 一次 headless 確認合體綠**。

## 本 session 主線（全 merged、各 2yr world_sim + 回歸綠 + coin_eq/InvariantAudit 0）

### 履約脫 0 弧（承 #6 sub-project A）
1. **返家補給 option 地基**（`c97fc5b`）：caravan 迴路骨架（當時無牙）。
2. **統一隊 survival 切片**（`b57c79c`）→ **履約首次脫 0**（`order_fulfilled 0→5`、`restock_chosen 0→131`、`[Market]成交`常態）。真根（measure-first 三次剝洋蔥，我兩次估算錯=carry-cap 漏 food weight 0.1 / restock util 沒實算→作廢一 spec）= 引擎 utility-survival **無牙**（survival_pressure cap 1.5 < 貪婪 trade ~1.8），逼停貿易的是引擎外 785 latch。修=survival-class term **量級重標度**（危時碾壓 trade）+ 退 785 latch(僅 unified)+survival 威脅化+覓食接真格+切片邊界。
3. **dispatch-fallback**（`1181b67`）：`DecisionEngine.rank`(util 降序+tiebreak)+`_decide_unified` 退次佳「可派」option→修 unified 經濟隊覓食無格凍死（藍圖標記 2 達標）。

### Autonomous goal-run（`/goal` A/B/D/E 除非未決，每項 2yr sim）
4. **A gate→權重**（`b15297a`）：貿易去 is_merchant 硬 gate+economic_opp 角色因子 0.3=清藍圖 gate 債第一條。
5. **A Pattern B 所有權 banker 全 5 池**（框架債「所有權圖縫」收編，各單一 owner+禁裸寫(grep 驗)+守恆閘）：UnrestBank `3a883a6` / LoyaltyBank `6bfc719`(cap 參數保 clamp) / AnonTreasuryBank `05ba648`(原子 transfer;揭 off-map leak 記 known_issues) / OutpostOwnerBank `7631aa3`(集中化保 last-writer-wins) / ResourceBank `3a72fc9`(124 寫/21 檔,簡 wrapper 保原數學=守恆 by construction)。
6. **D 性別**（`e3828d4`）：PersonData.sex + anon_female_ratio + 生育需兩性（全男隊不繁衍 emergent；team-level ratio 避 cohort schema 重構）。
7. **E food 買單側**（`a4c4cf8`）：缺糧隊發 food buy=食物雙向市集。
8. **B 框架驗證套件**（`1a5eee3`）：TC2/TC5 headless + `framework_validation.gd` S1-6 魂場景全 PASS（證 6 魂可 fire）。TC3 他域 skip。揭 mint 供給 gap。

## ⏸ 未決（全卡 1 個藍圖 ruling）
**他域遷入協調語意 WHAT**（handback `2026-06-22-systems-to-blueprint-otherdomain-coordination.md` → blueprint，**status: open**）：faction-goal 頂層 vs 個體人格驅動 + 主動開戰 feel。**藍圖一裁，連鎖解鎖**：
| 卡住項 | 屬 | 解鎖需 |
|---|---|---|
| 他域域（攻擊/掠奪/徵收/結盟/立國/scout/誘殺/鑄幣） | A | 他域 ruling → 各加 Option row |
| survival 全隊退役 + loot/join 還經濟隊 | A | 他域 ruling（loot/join 經濟隊=藍圖標記1債） |
| TC3（feud→脫軌攻擊） | B | 引擎攻擊 option（他域） |
| 戰俘 | D | combat capture（他域） |
| mint 完整 | E | 供給鏈 dormant=G1a arc backlog（非他域,獨立） |

**下一步建議**：開頭掃到藍圖回 `otherdomain-coordination` ruling → 即開他域 spec、連鎖完成剩餘 A/B/D/E。若藍圖未回 → 可做獨立 backlog（mint 供給鏈 G1a / Pattern B refinement）。

## 系統域 backlog（不卡藍圖，獨立可做）
- **mint 供給鏈 dormant**（known_issues）：mint 碼可運作（harness mint=1）但 default 無金礦 tile + 無 AI 建鑄幣廠路徑 → 供給斷。= G1a mint arc（挖金礦觸發 + AI 建鑄幣廠）。
- **anon_treasury off-map leak**（known_issues）：隊死 off-map 無 valid tile→coin 靜默丟（degenerate）。小修：擴搜尋/全域 sink/ledger。
- **Pattern B refinement**：outpost race-policy（同 tick 多寫誰勝）+ `pending_owner_change_tick` 退役；**coin_eq 註冊進 InvariantAudit**（現 coin_eq 是獨立 headless 測，未進 audit framework；subagent 建議）；transfer 原子抽象（非守恆必需）。
- **gate→權重續**：返家補給的 is_merchant（結構性暫留）；其餘角色 gate 已遷。

## 工作流提醒（本 session 教訓）
- **merge class_name 後 main 跑 `--import`**（見開頭坑）。
- **估算錯兩次教訓**（[[feedback_avoid_rabbithole]]）：根因建在算術/util 比較上 → 落 spec 前讀碼驗每常數 + 實算兩邊 + trace 實測，別憑公式。
- 每塊 merge 前自審 diff + 自跑回歸（worktree）+ 守恆閘（coin_eq/InvariantAudit）+ grep 驗（banker 無裸寫）。
- 子 session 在 worktree（cwd 預設 main repo，每次 Godot run 前 `Set-Location` 進 worktree）。
- world_sim unseeded：`order_fulfilled` 等絕對數 run-to-run 變異（[[reference_multi_sanity_unseeded]]）→ 看機制指標趨勢，別當絕對閾。
- 量測回呈藍圖走 handback；別問技術微決策；ctx ~90% 才提醒交接。
