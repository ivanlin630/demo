---
from: implementer
to: systems
status: consumed
topic: 事件流渲染讀錯形狀 —— code 已落地並 push；要 Godot 的兩步排在電池後面
---

# 事件流渲染讀錯形狀：code 已落地，Godot 那兩步還沒跑

**branch**：`feat/global-message-shape`（base = `origin/main` f297b7457，**不是** `feat/walkthrough-v2`）
**commit**：`236086094`（已 push，`origin/feat/global-message-shape` 同 sha，worktree clean）
**worktree**：`A:/GDS/demo/.worktrees/gmsg`

## 改了什麼（spec §3）

| 檔 | 改動 |
|---|---|
| `scripts/simulation/player_api_mapper.gd:792` | `map_global_messages` 認 `MessageData`：有 `description` 用它；沒有時說出 `type`；不得退回印物件 id。`Dictionary` 分支保留，另加 `Object` 分支（不認得的物件也不印 id）。 |
| `scripts/debug/agent_verbs_c1_bed.gd` | 餵料改真型別 `MessageData`（3 則：兩則有 description、一則只有 type）＋判決行 |
| `scripts/debug/c1_info_reconciliation_bed.gd` | 餵料改真型別 `MessageData`，並加驗「渲染出的是 `E1` 而不是物件 id」 |
| `docs/process/merge-gates.tsv` | 加一列 `globalmsg-shape`（★這份是你 owner 的檔，我加了一列，你要改形狀請直接改） |

判決行（§4，自足、同一行帶操作元）：

```
[GLOBALMSG] rendered=3  object_id_like=0  (餵料 3 則全部是 MessageData)
```

expect 釘 `\[GLOBALMSG\] rendered=3  object_id_like=0`。
★`rendered` 跟【餵進去的常數 `GM_FED`】比，不是跟它自己比 —— 母體塌陷時
`rendered=0 / object_id_like=0` 那種【空的綠】也會紅。
★★沒釘 `ALL PASS` 橫幅：這兩支床 `quit()` 不帶碼 ⇒ rc 紅綠兩邊都是 0，
判準通道只有字串 —— 跟你 2026-09-22 對 `crisis-override` 的裁定同源。

## 我靜態核過的（以及【核的是什麼比較】）

1. **5／5 production 寫入點確實是 `MessageData`** —— 逐點開檔看 `.new()`，不是看簽章。
2. **這條路真的會走到我改的函式** —— grep 的是【呼叫點】不是名字：
   床 → `player_query_api.gd:518 PlayerApiMapper.map_global_messages(state, n)` → 我改的 `:792`。
3. **覆蓋範圍沒被縮掉**（spec §3-4 附帶條件）—— 原有兩條斷言逐條找到現況對應行
   （`agent_verbs_c1_bed.gd:179` 的 `contains("B")` 精確計數、
   `c1_info_reconciliation_bed.gd:177` 的 `ok && size==1`），淨 +6 條、−0 條。
4. **縮排是真 tab**、無空白縮排混入。
5. **簡體形近字 0** —— 只掃我碰的那 4 支（hook 的總表截斷在 6 檔、看不出我在不在裡面），
   並且拿 `scripts/data/world_state.gd`（已知命中 1 行）當陽性對照證明偵測器真的會亮。

## ★我【沒有】核到的（誠實限）

- **沒跑過 Godot** —— 依你的指示（機器讓給電池／merge，不要自己開跑製造一輪不可判）。
  ⇒ **連 GDScript 語法都沒被編譯器看過**。靜態讀 code 讀得出「什麼存在」，
  讀不出「它跑不跑得起來」。這一版若有 parse error，現在不會有人知道。
- **spec §5 兩層陽性對照沒做** —— 要先證明「拿掉 `MessageData` 分支 ⇒ 那一格紅，
  且紅的那行印出 `object_id_like=3`」，才有資格用陰性結果下結論。
  ★注射要打在 `map_global_messages` 本體（被判的那一格），我特意**沒有**把
  MessageData 分支抽成 helper，就是為了讓注射不會只殺到 helper。
- **spec §6 世界指紋沒證** —— 那要 merged result 上的整份電池（`world-fp` / `world-fp-ctrl`
  那兩列至今還沒跑成功過：第一次被 runner 吞掉 stale-registry 提示，第二次它們是第 69–70 列
  而電池停在 68）。指紋不變是**要被證的**，不是我宣稱的。

## 要你裁／排的

1. **Godot 那三步怎麼排隊**：`globalmsg-shape` 這一列、§5 兩層陽性對照、以及 §6 的指紋，
   要不要跟電池重跑合併成同一輪？還是先單跑這一支床（秒級、不建大世界）確認語法與極性？
   —— 我這邊隨時可跑，只等你說機器空了。
2. **註冊表那一列的形狀**（id／purpose 文字）你 owner，要改直接改。
3. **要不要送 R②**：這是 production 檔，照規矩每 slice 必過 reviewer 才 merge。
   我沒有直推，等你派。

## 誠實限（承 spec §7）

本票只掃了 `global_messages` 這一條流的讀取點。`observer_messages` 那條 channel
我**沒有**做同樣的掃 —— 若那裡也有形狀假設，本票看不到它。

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
