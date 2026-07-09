# Spec — combat-into-engine（逃/戰/追 決策入統一決策腦）

## 願景（blueprint owner，scope signoff `combat-into-engine-scope-signoff`）
戰場決策（逃/戰/追）跟其他 NPC 決策**同一顆腦**秤——同決策機器（`rank_scored_ctx`）+ 同人格 term/weight 詞彙 + 人格連貫湧現。**非**字面把 combat 丟進全 task argmax（戰鬥中隊不重秤去種田/交易；combat option 集=子集）。

## 地板守則（blueprint signoff 硬條件，不可退化）
1. **rev2 三端配比保住**：逃常態(~83%)/俘中頻/殲滅稀但機制在。統一 utility 須**重現**膽量秤語意，非砍掉重來。
2. **殲滅端質感不變**：雙勇均等死戰專屬，不藉統一偷渡放寬 courage 窗。
3. **追擊三管道語意保留**（放血 `_apply_pursuit`／俘殘 `capture_routed_as_captive`／跨tick逐擊 `_refresh_attack_pursuit`），但**追多凶改人格秤**（殘忍/貪婪）。
4. determinism/融合閘/憲法 site-freeze 綠。

## 架構 HOW（systems，走既有 subset-rank pattern）
引擎已有 `rank_threat`/`rank_survival`/`rank_ambient` = 限定 option 子集 + 同 `rank_scored_ctx`（Σ 人格weight×drive-term argmax）。combat 走同型 `rank_combat(ctx)`（S2 建），**引擎不解鎖全 task dispatch**（團仍 PRIO_COMBAT 鎖，combat 只在子集內選）。

## Slice 序（blueprint 批 S1 先）

### ★S1 追擊放血人格化（de-patch，behavior-CHANGING=地板3；本 slice 開工）
**現況**：`npc_combat_system.gd:544 _apply_pursuit`——`pursuit_loss=int(loser.pop * PURSUIT_RATE(0.05))` 固定 5%，無人格。gate=`winner.pop >= loser.pop*2`（reachability，保留不動）。
**de-patch**：追擊放血率隨勝方領袖 **殘忍/貪婪** 秤。中性(0.5/0.5)→factor≈1.0 **保 5% mean baseline**（純按人格重分配非全面膨脹）。殘忍主、貪婪次（呼應 terms.gd:209 attack=好戰+殘忍、:218 loot=殘忍/好戰/貪婪 詞彙）。
```gdscript
# 新常數（TEST VALUE）
const PURSUIT_CRUELTY_W: float = 1.2   # 殘忍主導（person_data:40 殘忍高→戰後屠殺）
const PURSUIT_GREED_W:   float = 0.6   # 貪婪次（窮追為劫）
const PURSUIT_FACTOR_MIN: float = 0.0  # 慈悲領袖幾乎不追（受降傾向，S3 深化）
const PURSUIT_FACTOR_MAX: float = 2.5  # 殘忍軍閥上限（safety cap，防無差別暴漲=blueprint 要的 weight 上限）
```
- `pursuit_factor = clampf(1.0 + (殘忍-0.5)*PURSUIT_CRUELTY_W + (貪婪-0.5)*PURSUIT_GREED_W, MIN, MAX)`
- winner leader null → factor=1.0（保 baseline）。

**★S1 rev2（2026-07-10，measurer 揭截斷病第 3 次 + blueprint 裁 de-patch）**：`pursuit_loss = int(loser.pop * PURSUIT_RATE * factor)` 需 loser.pop≥18 才 ≥1 → organic 敗方多小隊 → **14/14 全 truncate 0，`loss_sum=0`=cosmetic 假過關**（cruelty weight 算了永不咬）。**de-patch = 跨 pursuit 事件分數累積器**（比照 `_cas_carry`）：
```
# 每 pursuit 事件：real = loser.pop * PURSUIT_RATE * factor；跨事件 carry
var real: float = float(loser.population) * PURSUIT_RATE * factor
var carry: float = _pursuit_carry.get(loser_id, 0.0) + real
var pursuit_loss: int = int(carry)          # floor
_pursuit_carry[loser_id] = carry - float(pursuit_loss)
```
- `_pursuit_carry` = static dict（同 `_cas_carry` 模式，key=loser team_id）。10-pop 隊被反覆追→漸進掉血（比 truncate 永零 / round 每次必殺1 兩極都對）。**★釘死不變量（reviewer §D4 教訓）：track 清除點顯式 erase**——`_pursuit_carry.erase(loser_id)` 於隊滅絕/erase_team 時（避免 team_id 重用洩漏），或註解釘「靠 X 保」。determinism 保（無新 randf）。

**★機制事實（measurer 量對東西、blueprint 判準）**：`_apply_pursuit` 在 `_end_combat`(:410)/`_force_retreat`(:489) 內 = **combat 結束後放血**，**不重入殲滅檢查**。∴ S1 **不直接動 `combat.end_annihilation` count**（三端在 combat 內決）。「殘忍軍閥靠窮追殲滅」機制上=窮追把潰逃隊放血到後續**滅絕**（`extinct.*` 獨立路）或加重 attrition，非 end_annihilation 三端。
**探針（S1 驗人格集中）**：`pursuit.n`、`pursuit.loss_sum`、`pursuit.cruelty_sum`、`pursuit.greed_sum`（追擊時勝方領袖值加權）；沿用既有 `end_annihilation`/`end_mortal_flee`/`capture.total` + `extinct.*`。
**驗（→measurer→blueprint）**：
- ①放血按人格分配：高殘忍/貪婪 pursuer 放血 factor>1、慈悲<1（`cruelty_sum/n` 對照）。
- ②**三端 organic 不打亂**（地板1）：`end_annihilation`/`mortal_flee`/`capture` ≈ S1 前（預期 end_annihilation 幾乎不動=機制事實）；若 `extinct.*`/attrition 因殘忍窮追升→標明分布（blueprint 判軍閥暴虐湧現 vs 打亂）。
- ③determinism（無新 randf，pursuit_loss 確定性）/融合閘/憲法綠。

### S2 逃/戰入 rank_combat（behavior-PRESERVING 重構，地板1/2 硬；S1 後）
`_mortal_flee_check`+`_abandon_threshold` → `rank_combat` COMBAT_OPTION_SET{血戰/逃} + `flee_drive` term（courage-weighed criticality+outnumber）+ DecisionContext 擴 round-level 欄（self/敵 eff、criticality、readiness、round）。**大架構 call → spec-lock 前召 reviewer 異質 refute 框外審**（三對齊觸發）。
- **★靶A（reviewer 框①/blueprint 裁）地板1 升真硬 gate**：argmax 競秤 ≠ 顯式閾值、數學不天然等價、有翻譯漂移。∴ **逐 seed 重現 rev2 三端對不上 = 整案打回設計層重審，禁微調 weight 湊近似通過**（近似≠重現）。S2 spec 須寫明「重現失敗處置=design reject 非 tune」。
- **★靶C（blueprint 裁）接受範圍缺口**：COMBAT_OPTION_SET{血戰/逃} 無「逃向補給/家」跨域路由=結構漏，但**現行 `_mortal_flee_check` 本就只戰場逃**→ S2 behavior-preserving=維持現狀非退化，缺口不綁進 S2。→ 記 **S4**。

### S4 斷糧求生路由（未來 slice，blueprint 裁 defer；掛絕境經濟/consolidation arc）
combat 中逃向 food/home 的跨域決策（擴 COMBAT_OPTION_SET 含補給路由）。=淨新 feature 非 S2 退化。別丟。

### S3 戰後受降 vs 屠殺（真新湧現；序末，別當 nice-to-have 砍）
殘忍 term 決屠殺 vs 受降，接 capture/subjugate。慈悲領袖受降（俘虜升）、殘忍領袖屠殺（放血/滅絕升）。

## 觸及檔（S1）
| 檔 | 改點 |
|---|---|
| `scripts/simulation/npc_combat_system.gd` | `_apply_pursuit` rate 人格化 + 4 常數 + pursuit 探針 |
| `scripts/debug/warring_harness.gd` | +`pursuit.*` 探針 key（n/loss_sum/cruelty_sum/greed_sum）|
