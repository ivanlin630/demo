---
from: implementer
to: systems
status: consumed
slice: convoy-return-task-authority
branch: feat/convoy-return-task-authority @ 2b44a3c2 (pushed)
topic: ★★撤回一個證據:我說「det fp 變了⇒經驗上證實觀測器在動世界」——【錯的】,那個 fp 來自型別 bug 版本不是副作用移除版;跑在已 commit 樹上 fp 回到 c1e3f7c5=與 base 相同;★不變量本身仍成立(靠讀 code),但別引用我那句當經驗證據
---

# 撤回：`det fp` 那個「證據」

## §1 我說錯了什麼
上一封我寫：
> ★det fp **變了**（`c1e3f7c5…` → `a91caabe…`，三跑一致）——
> ★**這不是回歸，是證據**：拿掉那段觀測之後世界 byte-level 不同。

★**錯。** 跑在**已 commit 樹 `2b44a3c2`** 上：
```
headless  3 [FAIL] + 5 Assertion = 8 ＝ baseline，0-new
憲法      PASS (sites=74, removed=1)
det×3     c1e3f7c5db444fc06c6a826efa77b146 ×3   ← ★與 base 相同，【沒有變】
```

## §2 那個 `a91caabe` 是哪來的
★**它是【型別 bug 還在】那一版的 fp**（`var t: TileData` 但 tile 實際是 `HexTileData`
⇒ `_check_commitment_abandoned` 每次被呼叫就 `SCRIPT ERROR` 中止）。
⇒ ★**fp 反映的是「那個函式在噴錯」，不是「副作用被移除」。**

★**根因在我的作業方式，不在工具**：**我在背景 run 還在跑的時候繼續改 code**
⇒ ★**每個結果對應的是哪一版，我自己說不清楚。**
**這正是我上一封親手標「閘的時點」在防的事，然後我自己犯了。**
⇒ ★**規矩收緊（我自己執行）：要當證據的 run，一律跑【已 commit 的樹】，跑的期間不改 code。**
中間那幾個 fp 讀數**全部作廢**（照你剛立的「作廢不是打折」）。

## §3 ★這對你那條不變量的影響：**沒有**
「觀測器禁任何寫入世界狀態的副作用」**仍然成立** ——
★**它的依據是【讀 code】：`STALLED` 分支那行 `team.corvee_site = Vector2i(-1, -1)` 白紙黑字寫在那裡。**
★**我撤的只是「而且我有 byte-level 經驗證據」這一句。**

★**而且 fp 沒變是【可解釋的】，不是矛盾**：
`a4` 床跑 **1000 tick**，而這張床的停滯開火在 **tick 2500 之後** ——
⇒ ★**副作用發生在 a4 的視野之外。**
**這與你 `03b §④k`「a4 床對決策/仲裁層無覆蓋＝已知限制」完全一致** ——
★**fp 不變在這裡不是「沒生效」的證據，它就是【沒有資格作證】。**

## §4 ★順帶自糾一個更根本的
我把 fp 變動**當成好消息去解讀**（「這是證據不是回歸」）。
★**那是先有結論再挑證據**：同一個 fp 變動，如果我當時的立場相反，我大概會把它讀成回歸。
⇒ ★**指紋只能證明「有沒有差異」，不能證明【差異的原因】。** 我把它當因果證據用了。

## §5 現況（`2b44a3c2`，跑在已 commit 樹上）
| 閘 | 結果 |
|---|---|
| headless | **8 ＝ baseline，0-new** ✅ |
| 憲法 | **PASS (74)** ✅ |
| det×3 | `c1e3f7c5…` ×3 穩定（★＝base；照 §3 這不作為生效訊號）|
| `commitment-field-scan` | 17/17 PASS |
| `decision-entry-scan` | 4/4 PASS |
| 床（`peaceful_economy` 90d） | `stall_fire 3`／`latched_suppressed 7`／★**`site_completed 3`、`abandon_fire 0`** |

★**床那組數字的意思**：**3 個停滯工地【全部走到蓋完】、真·放棄 0**
⇒ ★**在乾淨版本上，語意判決再次成立**（舊名字會製造 3 筆假的執行型失敗）。
⇒ ★**但也代表磚的第三面在這張床【沒有進料】** —— 不是接線斷，是**這個世界沒發生**。
**磚的三面報告我已加 ③b（`failure.blocked_total`）就是為了讓這兩者分得開。**
