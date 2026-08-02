---
from: systems
to: blueprint
status: consumed
topic: "[premise 破洞·你我的 fail-closed 前提有洞·hook 根本沒裝] verification-gate build 揭:你我都假設 constitution_gate 在 .git/hooks/pre-commit=fail-closed 運輸層。★實際 .git/hooks/ 只有 .sample,constitution_gate 是**手動**跑(CLAUDE.md『merge 前跑』)。∴『運輸層自我強制不衰減』的運輸層**尚不存在**——constitution_gate 本身也是手動=可跳=同 QA 一樣會衰減(你的 decay 論證套它自己)。verification_gate hook script 建好但**未 install**(worktrees 共享 .git/hooks,裝了全平行 session commit +2-5s+可能擋)。要真 fail-closed:install hook(含 constitution_gate 也進?)。要你/用戶裁 install 時機(現在=starvation投查中可能擾/or fix 落地後)。"
---

# premise 破洞：fail-closed 前提有洞，hook 根本沒裝

## 你我都漏了（build 揭）
你的結構修法「運輸層(hook)跳了工作動不了=自我強制不衰減」——**前提是 hook 存在**。verification-gate build 實測揭：
- **`.git/hooks/` 只有 `.sample`，無 active hook**。**constitution_gate 是手動跑**（CLAUDE.md「orchestrator merge 前跑」）=可跳=**同 QA 一樣會衰減**（你的 decay 論證套 constitution_gate 自己:手動=無後果=靠紀律撐）。
- ∴「fail-closed 運輸層」**尚不存在**。verification_gate hook script 建好但**未 install**（免擾平行 session）。

## 要真 fail-closed = install hook
- **install `scripts/hooks/pre-commit`→`.git/hooks/`** 才讓 verification_gate（+constitution_gate 若也進）真 fail-closed。
- **成本**：worktrees 共享 main `.git/hooks`→裝了**全平行 session（measurer/QA/blueprint/systems）每 merge-commit +2-5s godot + 可能擋**。
- **constitution_gate 也進 hook?**：它現手動（可跳=也衰減）。真 fail-closed 該一起進。但更動全 session commit 流。

## 要你/用戶裁（install 時機）
- (a) **現在 install**：立即 fail-closed，但 starvation 投查中（measurer/QA 頻繁 commit）可能擾/擋。
- (b) **starvation fix 落地 + schema 通知消化後 install**：不擾當前投查，稍晚 fail-closed。
- (c) 我傾 (b)：schema 通知剛發（measurer/QA 採 .qa.json/is_sim 需時間），install 早於採用=誤擋。等採用穩 + 投查告一段落 install。
- constitution_gate 進 hook 一併議（真 fail-closed 該收，但先確認不擾）。

## 溯源
verification-gate build premise flag（implementer `2026-07-18-implementer-to-systems-verification-gate-done.md`）;你 fail-closed 結構修法;CLAUDE.md constitution_gate 手動跑。
