"""SessionHistory component — sidebar showing past explanation sessions."""

def:pub SessionHistory(
    sessions: list,
    selectedSessionId: str,
    loading: bool,
    onSelect: any
) -> JsxElement {

    return
        <div style={{
            "display": "flex",
            "flexDirection": "column",
            "height": "100%",
            "width": "280px"
        }}>
            <div style={{
                "padding": "1rem 1rem 0.75rem",
                "borderBottom": "1px solid #2a2a4a",
                "flexShrink": "0"
            }}>
                <h3 style={{
                    "margin": "0",
                    "fontSize": "0.85rem",
                    "fontWeight": "700",
                    "color": "#888",
                    "textTransform": "uppercase",
                    "letterSpacing": "0.08em"
                }}>
                    Past Explanations
                </h3>
            </div>

            <div style={{
                "flex": "1",
                "overflowY": "auto",
                "padding": "0.5rem"
            }}>

                {(
                    <div style={{
                        "padding": "1.5rem 1rem",
                        "textAlign": "center",
                        "color": "#555",
                        "fontSize": "0.85rem"
                    }}>
                        Loading...
                    </div>
                )
                if loading
                else None}

                {(
                    <div style={{
                        "padding": "1.5rem 1rem",
                        "textAlign": "center",
                        "color": "#444",
                        "fontSize": "0.85rem"
                    }}>
                        No past sessions yet.
                    </div>
                )
                if (not loading and not sessions)
                else None}

                {[
                    <div
                        key={session["session_id"]}
                        onClick={lambda -> None { onSelect(session["session_id"]); }}
                        style={{
                            "padding": "0.75rem 0.85rem",
                            "borderRadius": "8px",
                            "cursor": "pointer",
                            "marginBottom": "0.3rem",
                            "background": ("#1e0a3c" if session["session_id"] == selectedSessionId else "transparent"),
                            "border": ("1px solid #7c3aed" if session["session_id"] == selectedSessionId else "1px solid transparent"),
                            "transition": "background 0.15s"
                        }}
                    >
                        <p style={{
                            "margin": "0 0 0.3rem",
                            "fontSize": "0.85rem",
                            "color": "#ddd",
                            "lineHeight": "1.4",
                            "overflow": "hidden",
                            "display": "-webkit-box",
                            "WebkitLineClamp": "2",
                            "WebkitBoxOrient": "vertical"
                        }}>
                            {session["raw_text_preview"]}
                        </p>
                        <div style={{
                            "display": "flex",
                            "gap": "0.5rem",
                            "alignItems": "center"
                        }}>
                            <span style={{
                                "fontSize": "0.7rem",
                                "color": "#666",
                                "background": "#1a1a2e",
                                "padding": "0.15rem 0.4rem",
                                "borderRadius": "4px"
                            }}>
                                {"Depth " + str(session["depth"])}
                            </span>
                            <span style={{"fontSize": "0.7rem", "color": "#444"}}>
                                {str(session["created_at"])[:10]}
                            </span>
                        </div>
                    </div>
                    for session in sessions
                ]}

            </div>
        </div>;
}
