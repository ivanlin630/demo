---
from: qa
to: blueprint
status: open
topic: V2「征服脊椎斷」判決撤回——QA 機器獨立複現(seed1337 6月)坐實假陽性:happened=2、下游捕俘3+同化2 全 fire、征服脊椎未斷;真🔴矛盾縮為 V1貿易/V3提案accept/V4envoy;新增🟡未知(commander-directive 征服路 0 貢獻);裁修序去 V2
---

# QA 判決修正 — V2 撤回（假陽性，機器獨立複現坐實）

系統 handback `systems-to-qa-v2-false-positive` 報 V2「意圖→行為 征服 1529→0 脊椎斷」=假陽性（根因在其 sufficiency_bed 探針配對錯）。**QA 不收一句話翻判**——按 QA 反轉制，自跑 bed 機器複現後裁。判決：**V2 撤下 🔴矛盾。**

## QA 獨立驗證（不靠系統報數）

自跑 `sufficiency_bed`（seed 1337、6 月、merged 73d167f 後碼）。征服列 = **want/feasible/happened = 1529/0/2**。原始 counter 交叉驗（同跑 delta 求和）：

| counter | 值 | 意義 |
|---|---|---|
| `conq.combat_entered` | 10 | 真交戰 |
| `conq.prosperity_reached` | **2** | 攻擊真派出（=happened） |
| `conq.retreat_captured` | 3 | 俘虜真發生 |
| `capture.total` | 3 | 俘虜實產生 |
| `asm.created` / `asm.completed` | 3 / 2 | 同化真啟動 |

**happened=2>0，下游捕俘/同化全非零 → 征服脊椎在跑，非斷鏈。假陽性 CONFIRMED。**

## 為何原判 V2🔴 錯（兩獨立證據）

1. **探針量不同族群**：舊 feasible=`conq.intent` 只在 `_solo_type=="征服"`（隊自身 solo 戰略 intent；bump 於 faction_ai_system 1525+1814）bump。而 want 的 1529=**commander directive**（faction 級，100% commander、`conq.declared=0`）。兩者不同機制 → feasible=0 by construction，與 1529 無關。（系統 handback 稱「只在 _decide_unified」措辭不準——1814 solo path 亦 bump——但「量不同族群」實質成立。）
2. **原表內部矛盾**：原判決表自家 🟢 E5 捕俘=0.3、E6 同化=0.667——**嚴格下游於征服攻擊**。不可能「征服 0 happened 脊椎斷」同時「捕俘/同化健康」。V2🔴 與 E5/E6🟢 自相矛盾 = 假陽性鐵證。

## 新增 🟡 未知（非矛盾，探針 follow-up）

修正列 feasible=`member_atk_eligible+declared`=**0**：commander-directive 征服路（成員 faction_goal 攻擊，faction_ai_system:1486）**0 貢獻**，真征服 2 次全走**獨立 prosperity 路**（1530-1539，`team.faction_id==-1`）。

- 死碼 vs 樣本太少無法分辨：本跑 `g2.faction_found=2`（只 2 faction 立起）→ commander 征服轉化路可能只是**沒足夠 established faction + 帶攻擊 tag-weight 成員**去觸發。
- **非阻塞、非塌房**（征服有獨立 prosperity 路可走）。歸 🟡，探針 follow-up 待排（查 established faction 數 + 成員攻擊 tag-weight）。

## 修正後裁修序（給 blueprint）

**真 🔴 矛盾縮為 3 條，V2 除名：**

1. **V1 貿易**（旗艦）——仍首，卡你 LOD/carrier 兩裁權（見 `lod-carrier-qa-verdict`）。
2. **V3 外交提案 accept=0**——獨立，查 accept 路徑可達否。
3. **V4 外交 envoy 送達**——LOD 同根，隨 V1 一起解。
4. **U1-U5 + 新 🟡**（觀測缺/探針 follow-up，不直接修）。

原判決表其餘（E1-E7 可解釋、U1-U5 未知、V1/V3/V4 矛盾）**不變**——本次修正只動 V2。

## 逃逸缺陷帳 + 方法論

- 本次翻判**全機器自抓**（bed 複現 + counter 交叉），非用戶逃逸 → `escaped_defects.md` 無新增。
- 教訓：**率表 harness 自身探針配對也要驗**（機器會錯，這次錯在系統 bed）。新率表列須附「同世界真行為 counter 交叉驗」。判「斷鏈」前先問「feasible counter 是否量同族群」。系統已入 `04_qa` checklist（commit 710ce19），QA 認可採納。
