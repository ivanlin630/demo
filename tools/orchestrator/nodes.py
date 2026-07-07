"""真節點 — stub 換 headless claude（07 increment 4）。

三類節點，兩個共用函式（DRY：水管 bug 單點可修，非散六處）：
  judge_node  = 讀 code → 判決 → 寫 verdict JSON（查證N1/挑毛病N3/品管N5 共用）。PROFILE_REVIEW（不 bypass）。
  write_node  = 讀 spec → 寫檔/建造 → commit（寫規格N2/建造N4 共用）。PROFILE_WRITE（bypass 限 worktree）。
N0 藍圖=互動(你我)非 headless；N6 閘=script(gate.py)非 claude。
"""
from __future__ import annotations
import os, json
from runner import run_node, effect_check, PROFILE_REVIEW, PROFILE_WRITE, MAIN_REPO
import bus


# ── 共用①：判決節點（讀+判→verdict）──
def judge_node(role: str, slice_id: str, node_name: str, task: str,
               reads: str, scope_dir: str = MAIN_REPO,
               model=None, effort=None, timeout=900) -> dict:
    """headless claude 讀 code、判決、寫 verdict JSON。回 verdict dict（router 讀它分流）。

    verdict 寫在 scope_dir/docs/process/verdicts/（整條線同 worktree → 不跨 repo）。
    verdict schema：{verdict:"clean"|"issues", premise_contradiction:bool,
                     issues:[{claim,file_line,truth}], note:str}
    """
    vpath = os.path.join(scope_dir, bus.VERDICT_DIR, f"{slice_id}.{node_name}.json")
    os.makedirs(os.path.dirname(vpath), exist_ok=True)
    if os.path.exists(vpath):
        os.remove(vpath)
    rel_v = os.path.relpath(vpath, scope_dir).replace("\\", "/")

    prompt = f"""你是 pipeline 的「{role}」對抗審查節點（slice={slice_id}）。skeptical、預設反駁、只信 file:line 證據。

任務：{task}

讀這些：{reads}

★用 Read/Grep/Glob 工具查證每個斷言（不要臆測、不要憑記憶）。任何 code 事實斷言必須有 file:line。

寫出你的判決到檔案 `{rel_v}`（純 JSON，覆蓋寫）：
{{
  "verdict": "clean" 或 "issues",
  "premise_contradiction": true/false,   // 前提被 code 打臉（如「X不存在」但 grep 到 X）→ true
  "issues": [{{"claim": "...", "file_line": "path:line", "truth": "..."}}],
  "note": "一句總結"
}}
只寫這個 JSON 檔，別的都別做。寫完回 DONE。"""

    res = run_node(PROFILE_REVIEW, role, prompt, scope_dir=scope_dir,
                   output_format="json", model=model, effort=effort, timeout=timeout)

    verdict = bus.read_verdict(slice_id, node_name, repo=scope_dir)
    effect_check(res, lambda: verdict is not None and "verdict" in verdict)
    bus.log_metric({
        "slice": slice_id, "node": node_name, "role": role,
        "ok": res.ok, "effect_ok": res.effect_ok, "dur_s": round(res.duration_s, 1),
        "cost_usd": res.cost_usd,
        "verdict": (verdict or {}).get("verdict"),
        "premise_contradiction": (verdict or {}).get("premise_contradiction"),
        "found_issue": bool((verdict or {}).get("issues")),
    })
    # effect 沒發生（verdict 沒寫成）= 硬 fail，當 issues+contradiction 逼 interrupt（不悶頭過）
    if not res.effect_ok:
        return {"verdict": "issues", "premise_contradiction": True,
                "note": f"節點 effect 失敗（verdict 未寫成）：ok={res.ok} err={res.error}"}
    return verdict


# ── 共用②：寫檔節點（讀 spec→建造→commit）──
def write_node(role: str, slice_id: str, task: str, reads: str, worktree: str,
               out_handback_to: str = "systems", model=None, effort=None, timeout=1800) -> dict:
    """headless claude 在 worktree 寫檔/建造，commit，寫 handback。回 {ok, commit_before/after, handback}。

    effect-check = worktree 有新 commit。
    """
    def _head():
        import subprocess
        try:
            return subprocess.run(["git", "rev-parse", "HEAD"], cwd=worktree,
                                  capture_output=True, text=True, timeout=30).stdout.strip()
        except Exception:
            return None

    before = _head()
    hb_name = f"{slice_id}-{role}-handback"
    prompt = f"""你是 pipeline 的「{role}」節點（slice={slice_id}），在 git worktree 工作。

任務：{task}

讀這些：{reads}

要求：
1. 寫/改 code（用 Read/Edit/Write），跑測試驗（用 Bash 跑 .\\tools\\godot.ps1 --headless --import 後測）。
2. **逐步 git commit**（別全積最後——死也丟最少）。
3. 寫 handback `docs/superpowers/handbacks/<date>-{role}-to-{out_handback_to}-{slice_id}.md`
   （frontmatter from/to/status:open/topic；body=做了啥+驗了啥+殘留疑點）。
4. 完成回 DONE。若遇設計矛盾停下、在 handback 記疑點呈報，別硬幹。"""

    res = run_node(PROFILE_WRITE, role, prompt, scope_dir=worktree,
                   output_format="json", model=model, effort=effort, timeout=timeout)
    after = _head()
    made_commit = bool(before and after and before != after)
    effect_check(res, lambda: made_commit)
    bus.log_metric({
        "slice": slice_id, "node": role, "role": role,
        "ok": res.ok, "effect_ok": res.effect_ok, "dur_s": round(res.duration_s, 1),
        "cost_usd": res.cost_usd, "made_commit": made_commit,
        "commit_before": before, "commit_after": after,
    })
    return {"ok": res.ok, "made_commit": made_commit,
            "commit_after": after, "effect_ok": res.effect_ok, "error": res.error}
