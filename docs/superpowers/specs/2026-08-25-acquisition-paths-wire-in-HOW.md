# means-end 接線：讓 `AcquisitionPaths` 真的進決策（HOW）

`from: systems` ｜ `slice: acquisition-paths-wire-in` ｜ `tier: full`（改決策行為、`fp` 會變）

## §1 病
**`AcquisitionPaths` 已 merged，但 `dormant-module-scan` 列它為【零 production caller】** ——
★**它算得出「為了取得 X 要先做 Y」，但沒有任何決策讀它 ⇒ 對遊戲行為【零影響】。**
★★**B 型驗收的 ④ 之所以是「空真」，正是這個原因**（被測對象不在場）。

## §2 接入點（★已定位到行）
`goal_resolver.gd:494-496` —— `_resolve_resource_prereq` 的**最後 fallthrough**：
```
	elif Probe.enabled:
		Probe.bump("goal.harvest.not_terrain_produced." + res)   # ★B 型：地形本來就不產（缺的是【製造】那條手段）
	return {}   # S3 無取得手段
```
★**這行既有註解自己就寫著「缺的是【製造】那條手段」** ⇒ **接入點不是我發明的，是前一票留下的接口。**
★★**而既有 tap `goal.harvest.not_terrain_produced.<res>` 已經在數 B 型母體** ⇒ **驗收的前後對照有現成基準。**

## §3 ★★★核心決策點：**阻抗不匹配**（本 spec 唯一的設計選擇）
| | 回傳 |
|---|---|
| `_resolve_resource_prereq` | ★**單一 `Dictionary`**（一個 candidate） |
| `AcquisitionPaths.for_resource` | ★**`Array`**（多條 path） |

**三個選項與裁定**：
| 選項 | 問題 | 裁 |
|---|---|---|
| (a) 在這裡挑一條最划算的回傳 | ★**違反本磚紀律**「只產候選、argmax 由決策層選」 | ✗ |
| (b) 挑【最淺】的一條回傳 | ★不違反紀律（最淺 ≠ 最划算），但★★**丟掉其他路徑 ⇒ 最淺那條不划算時隊伍就什麼都不做** | ✗ |
| ★(c) **回傳多條，全部進 rank 池** | 要動 caller | ★★**採用** |

**(c) 的具體形狀（★最小改動）**：
- ★**新增** `_resource_prereq_candidates(...) -> Array`，**不改** `_resolve_resource_prereq` 的簽名。
- `:101` 的 caller 改 `out.append_array(...)` —— ★**它本來就在收集多個 candidate 進 rank 池，天生相容。**
- `:362` 的 caller（`first-unsatisfied → return c`）**維持不動** —— ★**不為第三種手段去改兩個 caller 的契約**（那是 scope 擴張）。

★★**為什麼多條才對**：**讓 argmax 真的看到「蓋工坊」vs「去採礦」vs「買」在同一個池子裡競爭 —— 那正是這塊磚的價值。**

## §4 三種 `kind` → 三種 candidate
`for_resource` 回傳的 path 有三種 `kind`（★**由那塊磚決定，我不重新定義**）：
| `kind` | 意義 | 對應 candidate |
|---|---|---|
| `facility` | **缺設施**（`blocked_on` ＝ facility_key） | **蓋設施** —— 走既有 build/delegate 路徑 |
| `material` | **缺原料**（`blocked_on` ＝ 資源名） | ★**遞迴結果已在同一個 Array 裡** ⇒ 各自成 candidate |
| `ready` | **可做**（帶 `shape:"rate"` ＋ `gain_daily`） | ★**`TeamData.TASK_MANUFACTURE`** |

★**`stock` 形狀的 path 依既有裁定【不進價值比較】** —— 只標形狀、發 tap（`stock-vs-flow` 另票）。

## §5 感知鐵律（★寫 spec 前重讀，本節是自檢）
- ★**`for_resource` 讀的是 `team.resources`（自己的）＋ `tile.<facility_key>`（腳下的）** ⇒ **自身狀態，非 god-view。**
- ★★**買那條手段（手段 1）本來就 belief-gated**（`ctx.has_specie` ＋ `_nearest_market_outpost_with`）—— **本票不動它。**
- ★**不得**為了 means-end 去掃「世界上哪裡有這個資源」——**那會是新的 god-view。**

## §6 驗收（★`fp` 該變；★★每條附「會變紅的場景」）
| # | 判準 | ★**它會變紅的場景** |
|---|---|---|
| ★① | **`AcquisitionPaths` 從 `dormant-module-scan` 的清單消失** | **仍在清單上 ⇒ 根本沒接** |
| ★★② | **`goal.harvest.not_terrain_produced.<res>` 的隊伍，開始出現 `TASK_MANUFACTURE` / 蓋設施 candidate** | ★**該 tap 非零但 candidate 仍為零 ⇒ 接了但沒產出** |
| ★③ | ★**`fp` 改變** | ★★**見下方【③訂正】—— 原本寫「`fp` 不變 ⇒ 沒被執行」，★實測證明那是【二分法漏了一格】** |
| ④ | **反向：`food`／`material` 的既有行為不退化** | 既有 `emitted.<res>` 掉下來 |
| ★⑤ | **「無手段可取得」桶【縮小】且成員可列舉** | ★**桶變空 ⇒ 可疑（`gem`/`ore_iron` 是 stock，本來就該留在裡面）** |

★★**陽性對照**：**同一次跑要有一個【已知必然非零】的量**（否則儀器沒開時①②⑤會一起「通過」）。
★**報母體四問**：多大／是不是 0／**單位**／**它是哪個問題的母體**。

### ★★★③訂正：**「`fp` 不變」有三格，我原本只寫了一格**（2026-08-25 實測打臉）
**我原本寫**：「`fp` 不變 ⇒ **這條路徑沒被執行**」。
★**實測**：`fp` 不變，★★**但路徑【有】被執行**（`emitted` 非零）—— **真因是 `payoff` 缺失（§9）導致從不贏 argmax。**

| `fp` 不變時的三格 | 意義 | 分辨 |
|---|---|---|
| ★**`emitted = 0`** | **沒執行** | 我原本以為的唯一解 |
| ★★★**`emitted > 0` 且 `won_argmax = 0`** | ★★**執行了、有產出、但從不改變決策** ⇒ **本次實況** | ★**跟 `dormant` 的差別只剩「有產出」** |
| ★**`won_argmax > 0` 且 `fp` 不變** | **贏了但結果相同** ⇒ **可疑，要逐案讀** | — |

⇒ ★**判準改為【一對】**：★★**`emitted` ＋ `won_argmax` 一起報，缺一個就分不出上面三格。**
★★★**教訓**：**我寫「會變紅的場景」時只想了一種紅法** —— **而二分法的判讀規則遇到第三格，就等於沒寫。**

## §7 明確不做（★列出來免得被當漏列）
- ★**不改 `flow_utility` 的 stock 語意**（另票）
- ★**不修 `local_value` 那 ~12 個 blind 呼叫點**（另票）
- ★**不動 `:362` 的 caller 契約**
- ★**不為 `stock` 形狀產 candidate** —— 只標形狀

---

## §8 ★★★世界層驗收（**2026-08-25 追加，基準來自一次被證偽的推論**）

**背景**：我原本推論「A 型 merged 後建材閘應該鬆了」，並排了一次量測**才決定要不要解封 `rooting`**。
★**量測結果證偽了我的推論**：`main` 上 **`dispatch_fail.資源不足` ＝ 33**，
**比 A 型 merge 前（08-21）的 28 還【略增】** ⇒ ★★**建材閘沒有鬆動。**

★**原因清楚**：**A 型動的是 `food` 的取得手段，沒動 `material`／`tools`／`weapon_melee_low`** ——
★★**那條正是【本票】要接的東西**（B 型／`AcquisitionPaths`，先前 dormant 零 caller ⇒ 不可能影響任何 dispatch 判斷）。

### ⇒ ★那個數字改用途：**變成【本票】的世界層驗收基準**
| 項 | 值 |
|---|---|
| ★**baseline** | `main` ＠A型 merged：**`dispatch_fail.資源不足 = 33`**（`peaceful_economy`／`seed 1337`／90 天） |
| ★**期待方向** | ★★**接線後應【下降】** —— **製造品終於有第三種取得手段** |
| ★**它會變紅的場景** | ★★★**接線 merged 後仍是 33（或更高）⇒ 接了但沒有改變任何 dispatch 結果** |
| **落地路徑** | `docs/process/verdicts/rooting-unblock-main-remeasure.measure.json` |

★**為什麼這條合格**：**在因果下游**（本票就是動 material 那條）／**有 baseline**／**有母體**／★**可能失敗**。

### ★★附帶事實（measurer 量到，先前不知道）
**tick 分佈：`tick=10` 有 28 筆，另有 `day48.9`／`day55.1` 各 1 筆。**
⇒ ★**`_dispatch_builder` 並非完全凍結在 day0** —— **只是頻率遠低於 factioned 床（236 次遍佈全程）。**

### ★`rooting-fifth-end-same-ruler` 的 `blocked-by` 改標
**原標「blocked-by: 建材閘（A 型）」⇒ 錯了。**
★**改標：`blocked-by: acquisition-paths-wire-in`** —— **那才是動 `material` 的那條。**

---

## §9 ★★★`payoff` 怎麼給（**blueprint WHAT 裁定 2026-08-25；補我 §4 的缺口**）

### ★我的缺口
**§4 規定了三種 `kind` 對應什麼 candidate，★但【從沒說】`payoff` 該怎麼給。**
⇒ ★**實測後果**：`winner_util` **恰好** ＝ `me_util × 1.5`（**每一筆**，`1.5` ＝ facility goal 的 `payoff`）
⇒ ★★**means-end candidate 少乘了 `payoff` ⇒ 結構性地永遠輸，差距恆定。**
★**那不是實作錯，是我漏寫。**

### ★★★裁定（**2026-08-25 修錨後的最終版**）：**一行動一真值**
> ★**價值屬於【行動的後果全集】，不屬於【提出它的推理路徑】。**
> ★★**同一行動，不論哪條推理路徑提出，★必須同價。**
> ★★★**means-end ＝【發現行動】，不是【重新定價】。**

★**本例**：**工坊是【耐久資產】—— 後果超出「拿到 tools 這一次」** ⇒ ★**`1.5`（其後果流的既有計價）是對的價。**
★★**「繼承鏈終點」只適用【後果 ＝ 單次交付】的行動** —— **這是原錨太窄的地方（blueprint 自修）。**

★**副作用（好的）**：**恆定比值的病源 ＝「同一行動兩價」⇒ 由「一行動一真值」根除**
⇒ ★★**修正後的錨與我的驗收條【同時滿足】，不再互斥。**

<details><summary>★原裁定（已被修錨取代，留檔）</summary>

**`payoff` ＝ 繼承【所服務 goal】的 `payoff`**
</details>
> **「為了取得 X 先做 Y」的價值 ＝ 取得 X 的價值。**
⇒ ★**與既有 candidate【打平】，勝負交給 `delay`／`depth`／成本去分。**

### ★★★而鏈的代價：**只計價一次**
| ★**准** | ★**禁** |
|---|---|
| **真實延遲** → 走 `delay` 折現 | ★★**另設 per-step 折價常數** |
| **真實資源** → 走成本端 | |

★**禁的理由有兩條，缺一都成立**：
1. ★**手抄物理** —— **「每多一層打幾折」是憑空的數字，不從任何真實量導出**（既有法：**估值必 (a) 物理同源推導或 (b) 讀自身狀態**）。
2. ★★★**雙重計價** —— **鏈的長度【已經】透過 `delay` 進了折現**；**再加一個 per-step 折價 ＝ 同一個成本算兩次。**
   ⇒ ★**而兩次的效果是【相乘】的，多層鏈會被指數性地錯殺。**

### ★驗收補一條（**理由已隨新錨改寫**）
★**`winner_util / me_util` 不得出現【恆定比值】。**

| | 原本的理由 | ★**現在的理由** |
|---|---|---|
| 恆定比值代表 | 「某個因子只掛在一邊」 | ★★**「同一行動被兩處定了兩個價」⇒ 違反【一行動一真值】** |

★★**中途我曾把這條放寬成「無法解釋的恆定比值才是紅」** ——
**理由是「兩邊可能服務不同 payoff 的 goal（`工坊 1.5` vs `maintain_tools 1.0`）」。**
⇒ ★★★**新不變量把那一格【消滅了】：同一行動不得有兩價，所以那種「可解釋的恆定比值」不該存在。**
⇒ ★**放寬版作廢，回到原本的嚴格版 —— 但這次它的靠山是【一行動一真值】，不是我當時的診斷。**

★**（元教訓「二分法漏一格」不重複記** —— **`§6③` 已有一個活的實例，夠了。）**

