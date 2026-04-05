"""Survey modal component for onboarding — shown once after signup."""

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

    depth_labels = {
        1: "1 — High-level intuition",
        2: "2 — Practical understanding",
        3: "3 — Technical details",
        4: "4 — Deep internals"
    };

    return
        <div style={{
            "position": "fixed",
            "inset": "0",
            "background": "rgba(0,0,0,0.75)",
            "display": "flex",
            "alignItems": "center",
            "justifyContent": "center",
            "zIndex": "1000"
        }}>
            <div style={{
                "background": "#16162a",
                "borderRadius": "16px",
                "padding": "2rem",
                "width": "100%",
                "maxWidth": "500px",
                "boxShadow": "0 8px 40px rgba(0,0,0,0.6)",
                "border": "1px solid #3a2a6a",
                "fontFamily": "system-ui, -apple-system, sans-serif",
                "color": "#e8e8f0"
            }}>
                <h2 style={{
                    "marginTop": "0",
                    "color": "#c084fc",
                    "fontSize": "1.4rem"
                }}>
                    Personalize Your Experience
                </h2>

                <p style={{
                    "color": "#888",
                    "marginBottom": "1.5rem",
                    "fontSize": "0.9rem"
                }}>
                    This helps us tailor explanations to what you already know.
                </p>

                <label style={{
                    "display": "block",
                    "fontWeight": "600",
                    "marginBottom": "0.4rem",
                    "fontSize": "0.88rem",
                    "color": "#bbb"
                }}>
                    Topics you already know (comma-separated)
                </label>
                <input
                    type="text"
                    value={knownTopics}
                    onChange={onTopicsChange}
                    placeholder="e.g. Python, calculus, REST APIs"
                    style={{
                        "width": "100%",
                        "padding": "0.65rem 0.75rem",
                        "borderRadius": "8px",
                        "border": "1px solid #3a3a5a",
                        "background": "#0d0d20",
                        "color": "#e8e8f0",
                        "marginBottom": "1.1rem",
                        "boxSizing": "border-box",
                        "fontSize": "0.9rem",
                        "outline": "none"
                    }}
                />

                <label style={{
                    "display": "block",
                    "fontWeight": "600",
                    "marginBottom": "0.4rem",
                    "fontSize": "0.88rem",
                    "color": "#bbb"
                }}>
                    Paste an example of writing you understand well
                </label>
                <textarea
                    value={style}
                    onChange={onStyleChange}
                    placeholder="e.g. a blog post, a tweet thread, a textbook excerpt..."
                    rows="3"
                    style={{
                        "width": "100%",
                        "padding": "0.65rem 0.75rem",
                        "borderRadius": "8px",
                        "border": "1px solid #3a3a5a",
                        "background": "#0d0d20",
                        "color": "#e8e8f0",
                        "marginBottom": "1.1rem",
                        "boxSizing": "border-box",
                        "fontSize": "0.9rem",
                        "outline": "none",
                        "resize": "vertical",
                        "fontFamily": "inherit"
                    }}
                />


                <label style={{
                    "display": "block",
                    "fontWeight": "600",
                    "marginBottom": "0.4rem",
                    "fontSize": "0.88rem",
                    "color": "#bbb"
                }}>
                    Default explanation depth:
                    <span style={{
                        "color": "#c084fc",
                        "marginLeft": "0.4rem"
                    }}>
                        {depth_labels[depth] if depth in depth_labels else str(depth)}
                    </span>
                </label>
                <input
                    type="range"
                    min="1"
                    max="4"
                    value={depth}
                    onChange={lambda e: int -> None { onDepthChange(int(e.target.value)); }}
                    style={{
                        "width": "100%",
                        "marginBottom": "0.3rem",
                        "accentColor": "#c084fc"
                    }}
                />
                <div style={{
                    "display": "flex",
                    "justifyContent": "space-between",
                    "fontSize": "0.75rem",
                    "color": "#555",
                    "marginBottom": "1.25rem"
                }}>
                    <span>Surface level</span>
                    <span>Deep internals</span>
                </div>


                <label style={{
                    "display": "block",
                    "fontWeight": "600",
                    "marginBottom": "0.6rem",
                    "fontSize": "0.88rem",
                    "color": "#bbb"
                }}>
                    Quiz me after each explanation?
                </label>
                <div style={{
                    "display": "flex",
                    "gap": "0.75rem",
                    "marginBottom": "1.75rem"
                }}>
                    <button
                        onClick={lambda -> None { onRetentionChange(True); }}
                        style={{
                            "flex": "1",
                            "padding": "0.65rem",
                            "background": ("#7c3aed" if retention else "#1a1a2e"),
                            "color": ("#fff" if retention else "#666"),
                            "border": ("1px solid #7c3aed" if retention else "1px solid #3a3a5a"),
                            "borderRadius": "8px",
                            "cursor": "pointer",
                            "fontWeight": "600",
                            "fontSize": "0.9rem"
                        }}
                    >
                        Yes
                    </button>
                    <button
                        onClick={lambda -> None { onRetentionChange(False); }}
                        style={{
                            "flex": "1",
                            "padding": "0.65rem",
                            "background": ("#7c3aed" if not retention else "#1a1a2e"),
                            "color": ("#fff" if not retention else "#666"),
                            "border": ("1px solid #7c3aed" if not retention else "1px solid #3a3a5a"),
                            "borderRadius": "8px",
                            "cursor": "pointer",
                            "fontWeight": "600",
                            "fontSize": "0.9rem"
                        }}
                    >
                        No
                    </button>
                </div>

                <button
                    onClick={onSubmit}
                    style={{
                        "width": "100%",
                        "padding": "0.85rem",
                        "background": "linear-gradient(135deg, #7c3aed, #a855f7)",
                        "color": "white",
                        "border": "none",
                        "borderRadius": "8px",
                        "fontSize": "1rem",
                        "fontWeight": "700",
                        "cursor": "pointer"
                    }}
                >
                    Get Started
                </button>
            </div>
        </div>;
}