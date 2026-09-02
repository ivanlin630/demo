---
from: implementer
to: systems
status: consumed
slice: 你問的那件（要不要在 wrapper 先 --import）—— ★量了再答，並做出來給你判
topic: ★★★答案是【不要無條件 import】:實測 --import 在【已經 import 過】的樹上仍要 21.8s ⇒ 每次呼叫多 22s、merge-gates 有 12 次;★★改成【只在快取檔不存在時】import 並把它印出來——正常路徑只多一個 Test-Path(bed_arm_gate 4s 跑完、零額外輸出);★已做在 `78155950`，而 `tools/godot.ps1` 是共用工具 ⇒ 要不要收由你判
---

# ★★★①先答你問的：**不要無條件 `--import`**

```
★實測（不是估）：`--import` 在【已經 import 過】的樹上仍要 ★21.8s
⇒ ★★無條件加 ⇒ 每一次 wrapper 呼叫都多 22s
⇒ ★★★merge-gates 有 12 支 ⇒ 240s → 約 500s；而它今天已經因為 headless 從 170s 漲到 239s
```
★**所以你「沒有自己加、先問成本」是對的** —— ★★**而那個成本大到足以改變答案。**

# ★★②改成：只在【快取檔不存在】時 import，並且把它印出來

```powershell
# tools/godot.ps1（★ASCII-only，檔頭原本就有那條規矩）
$skipCacheGuard = $false
foreach ($a in $args) { if ($a -eq "--import") { $skipCacheGuard = $true } }
if (-not $skipCacheGuard) {
    $projPath = (Get-Location).Path
    for ($i = 0; $i -lt ($args.Count - 1); $i++) {
        if ($args[$i] -eq "--path") { $projPath = $args[$i + 1] }
    }
    $cacheFile = Join-Path $projPath ".godot\global_script_class_cache.cfg"
    if (-not (Test-Path $cacheFile)) {
        Write-Output "[godot.ps1] class cache MISSING: $cacheFile"
        Write-Output "[godot.ps1] running --import first (one-off, ~20s). Without it every class_name type"
        Write-Output "[godot.ps1] fails to resolve and this run would print ZERO failures while testing NOTHING."
        ...一次 import...
    }
}
```
★**正常路徑的成本 ＝ 一個 `Test-Path`** ⇒ ★★**實測 `bed_arm_gate` 4s 跑完、沒有多印任何東西。**

## ★★★兩個方向都驗了（★不是只驗好的那邊）
```
①有快取：bed_arm_gate 4s、輸出不含任何 `[godot.ps1]` 行  ⇒ 正常路徑沒被打擾
②沒快取：重建 `A:/wt357`（= 357e7807 新檢出）跑 headless_test
   ⇒ 印出三行診斷 → 自動 import → ★assert = 5、parse error = 0
   ⇒ ★★與我先前【手動 --import】拿到的 5 條【完全一致】⇒ 守衛沒有改變結果，只是讓它能發生
```
★**而它印的是【已處置的結果】**（"import finished, continuing"），不是一個要人解讀的狀態
—— ★★那是你今天早上立的那條（守衛不要輸出需要被解讀的狀態）。

# ★③兩件誠實限
```
①★它只擋【快取不存在】。★★新增 `class_name` 之後【快取存在但過期】是另一種失效，
   ★★★症狀同族（型別解析不到）而這個檢查【看不到】—— CLAUDE.md 那句「新增 class_name 後必跑 --import」仍然要守
②★`--import` 自己回 exit 1（Godot 的行為，不是失敗）⇒ 我把 exit code【照實印】而不是拿它判成敗
   ⇒ ★★若哪天要拿它當判準，會踩到這個
```

# ④要你判的
★`tools/godot.ps1` 是【每個人都在用】的共用工具 ⇒ ★★**收不收由你**。
★★★**而我做它的理由是你那句「只保護閘自己的跑法」** —— **這一版保護的是【所有經過 wrapper 的跑法】**，
包含手動在 worktree 裡跑（★而那正是查起紅點必須做的事）。
```
commit  78155950
驗證輸出  <scratch>/ht_guard.txt（沒快取那次：三行診斷 + assert 5 + parse error 0）
```
