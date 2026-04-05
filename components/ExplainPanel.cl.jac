"""ExplainPanel.cl.jac — Input form + explanation/quiz display."""

import from "./DepthSelector.cl.jac"   { DepthSelector   }
import from "./ExplanationView.cl.jac" { ExplanationView }
import from "./QuizView.cl.jac"        { QuizView        }
import from "../styles/panel.css" { panel_css }

def:pub ExplainPanel(
    activeSessionId: str,
    onExplainDone:   any
) -> JsxElement {
    has raw_text:        str  = "";
    has source_url:      str  = "";
    has depth:           int  = 2;
    has loading:         bool = False;
    has error:           str  = "";
    has session_data:    any  = None;
    has loading_session: bool = False;
    has active_tab:      str  = "explanation";

    sv import from ....main { Explain, GetSessionDetail }

    # Load detail whenever activeSessionId changes
    async can with [activeSessionId] entry {
        if activeSessionId {
            await load_session(activeSessionId);
        } else {
            session_data = None;
        }
    }

    async def load_session(sid: str) -> None {
        loading_session = True;
        error = "";
        try {
            result = root() spawn GetSessionDetail(session_id=sid);
            if result.reports and result.reports.length > 0 {
                session_data = result.reports[0];
                active_tab = "explanation";
            }
        } except Exception as ex {
            error = f"Could not load session: {ex}";
        }
        loading_session = False;
    }

    async def submit_explain(e: any) -> None {
        e.preventDefault();
        if not raw_text.strip() {
            error = "Please enter some text to explain.";
            return;
        }
        loading = True;
        error = "";
        session_data = None;
        try {
            result = root() spawn Explain(
                raw_text=raw_text,
                source_url=source_url,
                depth=depth
            );
            if result.reports and result.reports.length > 0 {
                resp = result.reports[0];
                session_data = {
                    "raw_text": raw_text,
                    "depth": depth,
                    "concepts": resp["explanation"],
                    "quiz": resp["quiz"]
                };
                active_tab = "explanation";
                sid = result.session_id if result.session_id else "";
                onExplainDone(sid);
            }
        } except Exception as ex {
            error = f"Something went wrong: {ex}";
        }
        loading = False;
    }

    # ── Loading session ─────────────────────────────────
    if loading_session {
        return <div className="panel panel--loading">
            <div className="panel-spinner">
                <div className="spinner-ring" />
                <p>Loading session…</p>
            </div>
        </div>;
    }

    # ── Session detail view ─────────────────────────────
    if session_data {
        concepts  = session_data["concepts"];
        quiz      = session_data.get("quiz", []) if hasattr(session_data, "get") else [];
        has_quiz  = quiz and len(quiz) > 0;
        raw_prev  = str(session_data["raw_text"]);
        preview   = (raw_prev[:80] + "…") if len(raw_prev) > 80 else raw_prev;

        return <div className="panel">
            <div className="panel__header">
                <p className="panel__subtitle">"{preview}"</p>
                {has_quiz and
                    <div className="tab-bar">
                        <button
                            className={("tab" + (" tab--active" if active_tab == "explanation" else ""))}
                            onClick={lambda -> None { active_tab = "explanation"; }}
                        >Explanation</button>
                        <button
                            className={("tab" + (" tab--active" if active_tab == "quiz" else ""))}
                            onClick={lambda -> None { active_tab = "quiz"; }}
                        >Quiz</button>
                    </div>
                }
            </div>
            <div className="panel__body">
                {active_tab == "explanation" and
                    <ExplanationView concepts={concepts} />
                }
                {active_tab == "quiz" and has_quiz and
                    <QuizView questions={quiz} />
                }
            </div>
        </div>;
    }

    # ── Input form ──────────────────────────────────────
    return <div className="panel panel--input">
        <div className="panel__hero">
            <div className="panel__eyebrow">
                <span className="panel__eyebrow-dot" />
                AI-powered knowledge restructuring
            </div>
            <h1 className="panel__title">
                Understand<br/>
                <span className="panel__title-accent">anything.</span>
            </h1>
            <p className="panel__lead">
                Paste confusing text and we'll rebuild it from first principles —
                adapted to your knowledge, vocabulary, and preferred depth.
            </p>
            <div className="panel__pills">
                <span className="pill">⚡ Prerequisites auto-discovered</span>
                <span className="pill">🎯 Adapts to your knowledge</span>
                <span className="pill">📖 Terminology bridging</span>
            </div>
        </div>

        <form
            className="explain-form"
            onSubmit={lambda e: any -> None { submit_explain(e); }}
        >
            <div className="form-field">
                <label className="form-label">Text to explain</label>
                <textarea
                    className="explain-textarea"
                    value={raw_text}
                    onChange={lambda e: any -> None { raw_text = e.target.value; }}
                    placeholder={"Paste a confusing paragraph, concept, or technical snippet…"}
                    rows={6}
                    disabled={loading}
                />
            </div>

            <div className="form-field">
                <label className="form-label">
                    Source URL
                    <span className="form-optional"> — optional</span>
                </label>
                <input
                    className="explain-input"
                    type="text"
                    value={source_url}
                    onChange={lambda e: any -> None { source_url = e.target.value; }}
                    placeholder="https://..."
                    disabled={loading}
                />
            </div>

            <div className="form-field">
                <label className="form-label">Depth level</label>
                <DepthSelector
                    value={depth}
                    onChange={lambda v: int -> None { depth = v; }}
                    disabled={loading}
                />
            </div>

            {error and <p className="form-error">{error}</p>}

            <button
                type="submit"
                className="btn-explain"
                disabled={loading}
            >
                {loading and <span className="btn-spinner" />}
                {("Building explanation…" if loading else "Explain →")}
            </button>
        </form>

        {loading and
            <div className="loading-overlay">
                <div className="loading-steps">
                    <LoadingStep label="Identifying unknown terms"   delay="0s"   />
                    <LoadingStep label="Discovering prerequisites"    delay="0.5s" />
                    <LoadingStep label="Building section explanations" delay="1.0s" />
                    <LoadingStep label="Annotating terminology"       delay="1.5s" />
                    {depth >= 3 and
                        <LoadingStep label="Generating practical guidance" delay="2.0s" />
                    }
                </div>
            </div>
        }
    </div>;
}

def:pub LoadingStep(label: str, delay: str) -> JsxElement {
    return <div className="loading-step" style={{"animationDelay": delay}}>
        <span className="loading-step__dot" />
        <span className="loading-step__label">{label}</span>
    </div>;
}
