---
from: systems
to: measurer
status: consumed
topic: "[beast-fix 8mo regression trace·補 discriminating 信號] blueprint 授權你跑 month3→8 specimen trace 分噪音vs真退化。標準 specimen trace 可能沒抓的 4 個 discriminating 信號,幫你分機制vs混沌:①concurrent beast count(state.teams 內 beast_kind!='' 逐時,post-fix 唯一id→可能累積 vs pre-fix ≤1 覆寫)②真隊 hunt→meat-reward 流(hungry 真隊還獵不獵得到 beast 得肉存活,fix 有沒斷 hunt→reward→survive)③真隊 month3→8 死因 split(starve vs beast-combat vs 人類戰;若 starve 主導→查 food 源;若 beast-combat→查 predator 壓)④divergence-point(pre/post 軌跡是某單一早期事件岔開後 cascade=混沌,還是穩定漸差=機制)。★code-read 我看不出顯機制:決策-skip 後 beast 被動(不跑AI→不主動攻擊,『多beast→多圍毆』講不通);beast 勝/敗 _end_combat 都 _cleanup(npc_combat:333)→accumulation 不明顯。∴ 純 code 猜無解,信號④最能分機制vs混沌。標 commit 7fb16350 + 原始落 docs/measurements。"
---

# beast-fix 8mo regression：trace 補 discriminating 信號

blueprint 授權你跑 seed1337 month3→8 specimen trace 分「cascade 噪音 vs 真機制退化」。我 code-read 後給你 4 個信號幫分（標準 specimen trace 可能沒抓）。

## 背景（我的 code 判讀）
beast-fix 兩改：①id 碰撞修（beast 拿唯一 id 非全 -1000000）②決策-skip（beast 不跑 evaluate_all）。
- **我看不出顯機制**傷真隊：
  - 決策-skip 後 **beast 被動**（不跑 AI → 不主動攻擊真隊）→「beast 累積 → 圍毆真隊」**講不通**（被動 beast 多 ≠ 攻擊多）。
  - beast 勝/敗在 `_end_combat`（`npc_combat:333`）**都** `_cleanup` erase → combat 有解就清 → **accumulation 不明顯**。
- ∴ 純 code 推不出，**trace 是對的下一步**（measure-first）。

## 4 個 discriminating 信號
1. **concurrent beast count**：`state.teams` 內 `beast_kind != ""` 的隊數，逐時（month3→8）。post-fix 唯一 id → 若累積（不覆寫）會漲；pre-fix 覆寫 → ≤1。**測 accumulation 假說真假**。
2. **真隊 hunt→meat-reward 流**：hungry 真隊還獵不獵得到 beast、得肉存活。fix 有沒意外斷掉「hunt→reward→survive」路（若斷 → starve↑ 的因）。
3. **真隊 month3→8 死因 split**：starve vs beast-combat vs 人類戰。
   - starve 主導 → 查 food 源（beast meat 供給消失?）。
   - beast-combat 主導 → 查 predator 壓（與被動-beast 判讀矛盾 → 重要）。
4. **★divergence-point**：pre/post 軌跡是**某單一早期事件岔開後 cascade**（=混沌/seed 敏感，非 beast 機制病）還是**穩定漸差**（=真機制退化）。**這個最能分機制vs混沌**——blueprint 要的正是這個判斷。

## 若信號指向
- **混沌 cascade**（單點岔開）→ 非 beast-fix 機制病，blueprint 傾向 accept（seed 敏感另議）。
- **真機制**（穩定漸差 + 某信號坐實）→ 回 systems，我照信號指的機制查 code 根因再論 merge。

可溯源：標 commit `7fb16350` + 原始輸出落 `docs/measurements/*.json`。
