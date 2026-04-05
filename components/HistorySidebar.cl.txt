"""HistorySidebar.cl.jac — Collapsible session history sidebar."""

import from "../styles/sidebar.css" { sidebar_css }

def:pub HistorySidebar(
    sessions:        list,
    loading:         bool,
    activeSessionId: str,
    onSelectSession: any,
    onNewExplain:    any,
    onOpenSettings:  any
) -> JsxElement {
    has collapsed: bool = False;

    def fmt_date(iso_str: str) -> str {
        try {
            d = Date(iso_str);
            return d.toLocaleDateString("en-US", {"month": "short", "day": "numeric"});
        } except {
            return str(iso_str)[:10] if iso_str else "";
        }
    }

    def trunc(text: str, n: int) -> str {
        t = str(text);
        return t if len(t) <= n else t[:n] + "…";
    }

    return <aside className={("sidebar" if not collapsed else "sidebar sidebar--collapsed")}>

        {/* ── Header ── */}
        <div className="sidebar__header">
            {not collapsed and
                <span className="sidebar__logo">
                    <span className="logo-mark">⬡</span>
                    <span className="logo-wordmark">Nexus</span>
                </span>
            }
            <button
                className="sidebar__toggle"
                onClick={lambda -> None { collapsed = not collapsed; }}
                title={("Collapse" if not collapsed else "Expand")}
            >
                {("◀" if not collapsed else "▶")}
            </button>
        </div>

        {/* ── Body ── */}
        {not collapsed and
            <div className="sidebar__body">
                <button
                    className="btn-new-explain"
                    onClick={lambda -> None { onNewExplain(); }}
                >
                    <span className="btn-new-explain__icon">＋</span>
                    <span>New Explanation</span>
                </button>

                <div className="sidebar__section-label">History</div>

                {loading and
                    <div className="sidebar__loading">
                        {[<div key={i} className="skeleton-row" /> for i in range(5)]}
                    </div>
                }

                {not loading and len(sessions) == 0 and
                    <p className="sidebar__empty">
                        No sessions yet.<br/>Explain something!
                    </p>
                }

                {not loading and len(sessions) > 0 and
                    <ul className="session-list">
                        {[
                            <li
                                key={s["session_id"]}
                                className={("session-item" + (" session-item--active" if s["session_id"] == activeSessionId else ""))}
                                onClick={lambda -> None { onSelectSession(s["session_id"]); }}
                            >
                                <span className="session-item__preview">
                                    {trunc(s["raw_text_preview"], 58)}
                                </span>
                                <span className="session-item__meta">
                                    <span className={"depth-badge depth-badge--" + str(s["depth"])}>
                                        {"D" + str(s["depth"])}
                                    </span>
                                    <span className="session-item__date">
                                        {fmt_date(s["created_at"])}
                                    </span>
                                </span>
                            </li>
                            for s in sessions
                        ]}
                    </ul>
                }
            </div>
        }

        {/* ── Footer ── */}
        {not collapsed and
            <div className="sidebar__footer">
                <button
                    className="btn-settings"
                    onClick={lambda -> None { onOpenSettings(); }}
                >
                    ⚙ Profile & Settings
                </button>
            </div>
        }
    </aside>;
}
