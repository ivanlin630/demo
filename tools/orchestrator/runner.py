"""node-runner primitive — langgraph 編排機器的地基（07_orchestrator_machine.md increment 1）。

每個 pipeline 節點 = 一次 headless `claude -p` 呼叫，帶 role、在指定 cwd（main 或 worktree）、
可寫檔/commit（bypassPermissions）。node 跑完**驗 effect 發生**（檔/commit 出現）才算過——
不是「claude 回了就算」（驗效果非能力，本專案鐵律）。

承重假設（已驗 2026-07-07）：claude 2.1.202 headless、langgraph 1.2.8、python 3.11。
"""
from __future__ import annotations
import subprocess, os, time, json
from dataclasses import dataclass, field
from typing import Callable, Optional, Any

# main repo root（runner.py 在 <repo>/tools/orchestrator/）
MAIN_REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

# ── 節點權限剖面（b：最小權限，用戶定 2026-07-07）──
# WRITE  = 實作/merge：能寫檔+commit，但 bypassPermissions **限 worktree**（cwd+add_dirs 框死，禁 main root）。
# REVIEW = fact-check/系統spec/對抗審/QA：**不給 bypass**（acceptEdits：可寫 verdict/spec，Bash 等仍 gated）。
#          讀 code 用 Read/Grep/Glob 工具（唯讀，acceptEdits 下放行），不走 Bash grep。
PROFILE_WRITE = "write"
PROFILE_REVIEW = "review"


@dataclass
class RoleResult:
    role: str
    ok: bool                      # returncode==0 且未 timeout
    result: Any                   # json 模式=解析後 .result；text 模式=raw stdout
    raw: str                      # 原始 stdout
    returncode: int
    duration_s: float
    timed_out: bool = False
    effect_ok: Optional[bool] = None   # caller 跑 effect_check 後填
    session_id: Optional[str] = None
    cost_usd: Optional[float] = None
    error: Optional[str] = None


def run_role(
    role: str,
    prompt: str,
    cwd: Optional[str] = None,
    permission_mode: str = "bypassPermissions",
    output_format: str = "text",
    model: Optional[str] = None,
    effort: Optional[str] = None,
    add_dirs: Optional[list[str]] = None,
    append_system_prompt: Optional[str] = None,
    resume_session: Optional[str] = None,
    timeout: int = 600,
) -> RoleResult:
    """一個節點 = 一次 headless claude 呼叫。

    output_format="json" → 回 claude 的 result envelope，解析出 .result / .session_id / .total_cost_usd。
    permission_mode="bypassPermissions" → 節點能自主寫檔/commit（自動流程無人批准）。
    resume_session → 續前一次同角色 session（--resume，帶前次 context，免重讀；批次1.6 同角色續）。
    """
    env = dict(os.environ)
    env["SESSION_ROLE"] = role

    cmd = ["claude", "-p", prompt,
           "--permission-mode", permission_mode,
           "--output-format", output_format]
    if resume_session:
        cmd += ["--resume", resume_session]
    if model:
        cmd += ["--model", model]
    if effort:
        cmd += ["--effort", effort]
    for d in (add_dirs or []):
        cmd += ["--add-dir", d]
    if append_system_prompt:
        cmd += ["--append-system-prompt", append_system_prompt]

    t0 = time.time()
    timed_out = False
    raw = ""
    rc = -1
    err = None
    try:
        proc = subprocess.run(
            cmd, cwd=cwd, env=env,
            capture_output=True, text=True, encoding="utf-8", errors="replace",
            timeout=timeout,
        )
        rc = proc.returncode
        raw = proc.stdout or ""
        if rc != 0:
            err = (proc.stderr or "")[-2000:]
    except subprocess.TimeoutExpired as e:
        timed_out = True
        raw = (e.stdout.decode("utf-8", "replace") if isinstance(e.stdout, bytes) else (e.stdout or "")) if e.stdout else ""
        err = f"timeout after {timeout}s"
    except FileNotFoundError:
        err = "claude CLI not found on PATH"
    dur = time.time() - t0

    result: Any = raw
    session_id = None
    cost = None
    if output_format == "json" and raw.strip():
        try:
            env_obj = json.loads(raw)
            result = env_obj.get("result", env_obj)
            session_id = env_obj.get("session_id")
            cost = env_obj.get("total_cost_usd")
        except json.JSONDecodeError:
            pass  # 保留 raw

    return RoleResult(
        role=role, ok=(rc == 0 and not timed_out), result=result, raw=raw,
        returncode=rc, duration_s=dur, timed_out=timed_out,
        session_id=session_id, cost_usd=cost, error=err,
    )


def run_node(
    profile: str,
    role: str,
    prompt: str,
    scope_dir: str,
    **kw,
) -> RoleResult:
    """依權限剖面跑節點（b：最小權限）。

    PROFILE_WRITE：bypassPermissions，但硬性 scope 到 worktree（cwd=scope_dir + add_dirs=[scope_dir]）。
        安全 guard：scope_dir 缺、或 == MAIN_REPO root → 拒（禁自主寫節點碰 main）。
    PROFILE_REVIEW：acceptEdits（不 bypass）。cwd=scope_dir（通常 = MAIN_REPO，唯讀+寫 verdict）。
    """
    if profile == PROFILE_WRITE:
        if not scope_dir:
            raise ValueError("PROFILE_WRITE 必須帶 scope_dir（worktree）")
        if os.path.abspath(scope_dir) == MAIN_REPO:
            raise ValueError(f"PROFILE_WRITE 禁止 scope 到 main repo root（{MAIN_REPO}）；自主寫節點只能在 worktree")
        # ★防洩漏 guard：scope_dir 必須是真 git worktree（toplevel==自己）。裸目錄會被 git 往上解析到 main
        # → commit 洩漏到 main（A2a revise 教訓）。toplevel != 自己 = 假 worktree，拒。
        try:
            top = subprocess.run(["git", "-C", scope_dir, "rev-parse", "--show-toplevel"],
                                 capture_output=True, text=True, timeout=15).stdout.strip()
        except Exception:
            top = ""
        if not top or os.path.abspath(top) != os.path.abspath(scope_dir):
            raise ValueError(f"scope_dir 非真 git worktree（git toplevel={top!r} != {scope_dir}）"
                             f"——拒絕寫節點（防 commit 洩漏到 main）。先建真 worktree。")
        return run_role(role, prompt, cwd=scope_dir,
                        permission_mode="bypassPermissions",
                        add_dirs=[scope_dir], **kw)
    elif profile == PROFILE_REVIEW:
        return run_role(role, prompt, cwd=(scope_dir or MAIN_REPO),
                        permission_mode="acceptEdits", **kw)
    else:
        raise ValueError(f"未知 profile: {profile}")


_API_ERR_MARKS = ("rate limit", "rate_limit", "ratelimit", "quota", "usage limit",
                  "session limit", "overloaded", "too many requests", "insufficient", "credit")

def is_api_error(res: RoleResult) -> bool:
    """API 限流/超時/額度判定（裁3：這類禁自動重試，原地定格）。網路瞬斷另計不在此。

    ★A2a 教訓：429/session-limit 訊息在 result/raw envelope（"api_error_status":429、"session limit"），
    不在 stderr。原本只掃 stderr → 漏 → 整條 pipeline 空跑到 ②垃圾。改：掃 raw 結構標記 + result/error 訊息。
    """
    if res.timed_out:
        return True
    raw = str(res.raw or "")
    # 結構標記（明確，不誤判）：claude -p 的 4xx/5xx error envelope
    if '"is_error":true' in raw and ('"api_error_status":4' in raw or '"api_error_status":5' in raw):
        return True
    # 訊息標記：掃 result + error（不掃 raw 全文，避 quota/credit 等字在正常內容誤判）
    msg = (str(res.result or "") + " " + str(res.error or "")).lower()
    if any(m in msg for m in _API_ERR_MARKS):
        return True
    # 零花費+失敗+空輸出（底層重試耗盡）
    if not res.ok and (res.cost_usd in (0, None)) and not str(res.result).strip():
        return True
    return False


def effect_check(res: RoleResult, predicate: Callable[[], bool]) -> RoleResult:
    """驗 effect 發生（檔/commit 出現）。predicate 拋錯=視為 False（保守）。

    這是「過節點的硬證」——node.ok（claude 回了）≠ effect_ok（世界真的變了）。
    """
    try:
        res.effect_ok = bool(predicate())
    except Exception:
        res.effect_ok = False
    return res
