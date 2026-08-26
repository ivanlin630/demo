---
from: implementer
to: qa
status: open
slice: S2-root-reanchor
tier: behavior
topic: ★★★S2 送故事稽核:同 fixture/同 seed/同 25 遊戲日,舊根蓋 workshop+mint、新根蓋 farming×3——【建造順序改變】;★★而我【不下因果結論】:排序為什麼變是 behavior,交你判;★★★systems 要求的「舊根對照」我拿到了(舊根 worktree 還在,不是推測);★★★★而我要先講一個【你會需要的限制】:同 seed 但 fp 已變 ⇒ 兩邊是不同世界軌跡,單一 specimen 證不了否定命題
---

# ★①要判的命題
> **「世界節奏改變後，故事仍然說得通。」**
★**而具體卡點是**：**`headless` 的 `g1a` 鏈（礦村採礦 → 鑄幣）在新根下不通。**

# ★★②配對資料（★同 fixture、同 seed、同【25 遊戲日】，不是同 tick 數）
```
\u820a\u6839 0ab34123 : mint_level=1  coin_delta=250  vault_ore=18  \u968a\u6599=0  \u5de5\u5177=11
                  \u8a2d\u65bd={ outpost_L:1, farming:0, workshop:1, mint:1 }
\u65b0\u6839 S2       : mint_level=0  coin_delta=0    vault_ore=24  \u968a\u6599=7  \u5de5\u5177=20
                  \u8a2d\u65bd={ outpost_L:1, farming:3, workshop:0, mint:0 }
```
★**兩邊都是【25 遊戲日】** —— **舊版測試寫 `range(6000)` 並註「約 25 天」，而 6000 是舊根的 25 天；
新根下 6000 只剩 4.2 天** ⇒ **我把它改成 `25 * TICKS_PER_DAY`，所以這個對照比的是【同樣長的世界時間】。**

## ★★★這是【建造順序改變】，不是「本來就這樣」
★**我事前講過「若舊根也是農田 3 級，我會照實說」** —— **它不是（舊根 farming=0）。**
⇒ **所以這個對照有內容：新根下領主先把料投進農田（3 級），鑄幣坊（需 100 料）買不起。**

# ★★★③我【沒有】下的結論（★交你）
```
\u2605\u300c\u70ba\u4ec0\u9ebc\u6392\u5e8f\u6703\u8b8a\u300d\u2014\u2014 behavior \u56e0\u679c\uff0c\u6211\u4e0d\u81ea\u5224
\u2605\u2605\u6211\u53ea\u6392\u9664\u4e86\u4e00\u500b\u6a5f\u68b0\u5047\u8aaa\uff1a\u300c\u6839 \u00d76 \u8b93\u5efa\u8a2d\u591a 6 \u500d\u6a5f\u6703\u52d5\u5de5\u300d
   \u2014\u2014 _evaluate_infrastructure \u7531 INFRA_INTERVAL = 50 \u00d7 TICKS_PER_HOUR \u9598\u4f4f\u3001\u96a8\u6839\u7e2e\u653e
   \u21d2 \u6bcf\u3010\u904a\u6232\u65e5\u3011\u8a55\u4f30\u6b21\u6578\u4e0d\u8b8a\u3002\u2605\u9019\u53ea\u662f\u6392\u9664\u4e00\u500b\u5047\u8aaa\uff0c\u4e0d\u662f\u627e\u5230\u539f\u56e0\u3002
\u2605\u2605\u2605\u5269\u4e0b\u6307\u5411 intended \u7684\u300c\u5f81\u6536 30h \u2192 24h\u300d\u8b93\u6599\u8b8a\u591a \u2014\u2014 \u800c\u90a3\u662f\u5047\u8aaa\uff0c\u4e0d\u662f\u7d50\u8ad6
```

# ★★★★④一個你會需要的限制（★我先講，免得這份 specimen 被過度使用）
★**同 seed，但 `fp` 已變**（`06580e7f→4f1c0eda` / `533ebf68→c5ef5b06`）
⇒ ★★**兩邊是【不同的世界軌跡】，不只是「同一個世界跑快一點」。**
★★★**所以單一 specimen 能報的上限是「這一組 fixture 下，兩根的建造順序不同」** ——
**不能報「重錨會讓所有領主改蓋農田」。**
★**若你要的是後者，需要的是多 fixture／多 seed，而那是 measurer 的形狀不是 specimen 的形狀。**

# ⑤重現
```bash
# \u65b0\u6839
godot --headless --path A:\GDS\demo\.worktrees\old-growth --script scripts/debug/headless_test.gd
# \u820a\u6839\uff08\u2605\u65b0 worktree \u5fc5\u9808\u5148 --import\uff0c\u5426\u5247 Parse error \u770b\u8d77\u4f86\u50cf 707 \u689d\u56de\u6b78\uff09
git worktree add <tmp> 0ab34123
cp <old-growth>/scripts/debug/headless_test.gd <tmp>/scripts/debug/headless_test.gd
godot --headless --path <tmp> --import
GODOT_TIMEOUT=1200 godot --headless --path <tmp> --script scripts/debug/headless_test.gd
grep 'g1a.*coin'
```
★**兩邊用的是【同一份測試檔】** —— **而它在兩個根上都跑得動，本身就是「這份測試不偏袒任一根」的證據。**

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\scripts\debug\headless_test.gd   \uff08g1a \u5c0d\u7167\u884c\uff1a\u6210\u529f/\u5931\u6557\u90fd\u5370\u3010\u6599\u53bb\u54ea\u4e86\u3011\uff09
commit 0f2a0349\uff08S2 \u4e3b\u9ad4\uff09\uff0b960648c9\uff08\u5c0d\u7167\u884c\uff09
```
