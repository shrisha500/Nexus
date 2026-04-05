"""Survey modal component for onboarding."""

def:pub SurveyModal(
    knownTopics: str,
    style: str,
    depth: int,
    retention: bool,
    onTopicsChange: any,
    onStyleChange: any,
    onDepthChange: any,
    onRetentionChange: any,
    onSubmit: any
) -> JsxElement {

    return
        <div
            style={{
                "position": "fixed",
                "inset": "0",
                "background": "rgba(0,0,0,0.5)",
                "display": "flex",
                "alignItems": "center",
                "justifyContent": "center",
                "zIndex": "1000"
            }}
        >
            <div
                style={{
                    "background": "white",
                    "borderRadius": "12px",
                    "padding": "2rem",
                    "width": "100%",
                    "maxWidth": "480px",
                    "boxShadow": "0 8px 32px rgba(0,0,0,0.2)",
                    "fontFamily": "system-ui, -apple-system, sans-serif"
                }}
            >
                <h2 style={{"marginTop": "0", "color": "#1a1a2e"}}>
                    Quick Setup
                </h2>

                <p style={{"color": "#666", "marginBottom": "1.5rem"}}>
                    Help us personalize your experience.
                </p>

                <label style={{"display": "block", "fontWeight": "600", "marginBottom": "0.4rem"}}>
                    Topics you already know (comma-separated)
                </label>
                <input
                    type="text"
                    value={knownTopics}
                    onChange={onTopicsChange}
                    placeholder="e.g. Python, calculus, Roman history"
                    style={{
                        "width": "100%",
                        "padding": "0.6rem",
                        "borderRadius": "6px",
                        "border": "1px solid #ddd",
                        "marginBottom": "1rem",
                        "boxSizing": "border-box"
                    }}
                />

                <label style={{"display": "block", "fontWeight": "600", "marginBottom": "0.4rem"}}>
                    Writing style you understand best
                </label>
                <input
                    type="text"
                    value={style}
                    onChange={onStyleChange}
                    placeholder="e.g. casual, textbook-like, Feynman technique"
                    style={{
                        "width": "100%",
                        "padding": "0.6rem",
                        "borderRadius": "6px",
                        "border": "1px solid #ddd",
                        "marginBottom": "1rem",
                        "boxSizing": "border-box"
                    }}
                />

                <label style={{"display": "block", "fontWeight": "600", "marginBottom": "0.4rem"}}>
                    Explanation depth: {depth} / 5
                </label>
                <input
                    type="range"
                    min="1"
                    max="5"
                    value={depth}
                    onChange={lambda e: int -> None { onDepthChange(int(e.target.value)); }}
                    style={{"width": "100%", "marginBottom": "0.4rem"}}
                />
                <div
                    style={{
                        "display": "flex",
                        "justifyContent": "space-between",
                        "fontSize": "0.8rem",
                        "color": "#888",
                        "marginBottom": "1rem"
                    }}
                >
                    <span>1 — Surface level</span>
                    <span>5 — Deep dive</span>
                </div>

                <label style={{"display": "block", "fontWeight": "600", "marginBottom": "0.4rem"}}>
                    Retention mode (quiz me on topics)?
                </label>
                <div style={{"display": "flex", "gap": "1rem", "marginBottom": "1.5rem"}}>
                    <button
                        onClick={lambda -> None { onRetentionChange(True); }}
                        style={{
                            "flex": "1",
                            "padding": "0.6rem",
                            "background": "#4CAF50" if retention else "#f0f0f0",
                            "color": "white" if retention else "#333",
                            "border": "none",
                            "borderRadius": "8px",
                            "cursor": "pointer",
                            "fontWeight": "600"
                        }}
                    >
                        Yes
                    </button>

                    <button
                        onClick={lambda -> None { onRetentionChange(False); }}
                        style={{
                            "flex": "1",
                            "padding": "0.6rem",
                            "background": "#e53e3e" if not retention else "#f0f0f0",
                            "color": "white" if not retention else "#333",
                            "border": "none",
                            "borderRadius": "8px",
                            "cursor": "pointer",
                            "fontWeight": "600"
                        }}
                    >
                        No
                    </button>
                </div>

                <button
                    onClick={onSubmit}
                    style={{
                        "width": "100%",
                        "padding": "0.75rem",
                        "background": "#4CAF50",
                        "color": "white",
                        "border": "none",
                        "borderRadius": "8px",
                        "fontSize": "1rem",
                        "fontWeight": "600",
                        "cursor": "pointer"
                    }}
                >
                    Get Started
                </button>
            </div>
        </div>;
}