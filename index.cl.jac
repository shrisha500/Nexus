sv import from .services.appService { generate_explanation }

def:pub ClientApp() -> JsxElement {
    has selected_text: str = "Docker uses OS-level virtualization to package software into containers.";
    has prior_knowledge: str = "I know basic web development, but not infrastructure.";
    has preferred_style: str = "Explain it like a clear YouTube tutorial mixed with casual internet language.";
    has learning_style: str = "Hands-on + visual";
    has depth: str = "Level 2";
    has retention_mode: bool = True;
    has loading: bool = False;
    has error: str = "";
    has result: dict = {};

    async can with entry {
        await run_demo();
    }

    def handle_text(e: any) -> None { selected_text = e.target.value; }
    def handle_prior(e: any) -> None { prior_knowledge = e.target.value; }
    def handle_style(e: any) -> None { preferred_style = e.target.value; }
    def handle_learning(e: any) -> None { learning_style = e.target.value; }
    def set_level_1() -> None { depth = "Level 1"; }
    def set_level_2() -> None { depth = "Level 2"; }
    def set_level_3() -> None { depth = "Level 3"; }
    def set_level_4() -> None { depth = "Level 4"; }
    def toggle_retention() -> None { retention_mode = not retention_mode; }

    async def run_demo() -> None {
        loading = True;
        error = "";
        try {
            result = await generate_explanation(selected_text);
        } except Exception as ex {
            error = "Could not generate explanation: " + str(ex);
        }
        loading = False;
    }

    sections = result["sections"] if result and result["sections"] else [];
    unknown_terms = result["unknown_terms"] if result and result["unknown_terms"] else [];
    retention_items = result["retention"] if result and result["retention"] else [];
    profile = result["profile"] if result and result["profile"] else {};

    return <div className="min-h-screen text-foreground">
        <div className="max-w-7xl mx-auto px-5 py-8 md:px-8 md:py-10">
            <section className="rounded-[2rem] border border-border bg-card shadow-card overflow-hidden">
                <div className="px-6 py-8 md:px-10 md:py-12 bg-[linear-gradient(135deg,rgba(109,94,252,0.12),rgba(56,189,248,0.08))]">
                    <div className="max-w-3xl">
                        <div className="inline-flex items-center gap-2 rounded-full border border-primary/20 bg-white/70 px-3 py-1 text-xs font-semibold uppercase tracking-[0.18em] text-primary">Adaptive Explanation Engine</div>
                        <h1 className="mt-4 text-4xl md:text-6xl font-extrabold tracking-tight leading-[1.02]">Build understanding, not just simpler text.</h1>
                        <p className="mt-4 max-w-2xl text-base md:text-lg text-muted-foreground leading-7">A Chrome-extension-style learning engine that rebuilds confusing ideas from zero, adapts to how the user actually understands language, and helps them retain what they learn.</p>
                        <div className="mt-6 flex flex-wrap gap-3 text-sm">
                            <span className="rounded-full bg-secondary px-4 py-2 font-medium text-primary">Why → Problem → Before → What → How → Tradeoffs</span>
                            <span className="rounded-full bg-muted px-4 py-2 font-medium text-foreground">Terminology bridging</span>
                            <span className="rounded-full bg-muted px-4 py-2 font-medium text-foreground">Retention mode</span>
                        </div>
                    </div>
                </div>
            </section>

            <section className="mt-8 grid grid-cols-1 xl:grid-cols-[1.05fr_0.95fr] gap-6 items-start">
                <div className="space-y-6">
                    <div className="rounded-[1.5rem] border border-border bg-card p-6 shadow-soft">
                        <div className="flex items-center justify-between gap-4 flex-wrap">
                            <div>
                                <p className="text-sm font-semibold uppercase tracking-[0.16em] text-primary">MVP flow</p>
                                <h2 className="mt-2 text-2xl font-bold">Highlight text → explain better</h2>
                            </div>
                            <button onClick={run_demo} disabled={loading} className="inline-flex items-center justify-center rounded-xl bg-primary px-5 py-3 text-sm font-semibold text-primary-foreground hover:opacity-90 focus:outline-none focus:ring-2 focus:ring-primary disabled:opacity-50">{("Generating..." if loading else "Explain Better")}</button>
                        </div>
                        <div className="mt-5">
                            <label className="block text-sm font-semibold mb-2">Highlighted text</label>
                            <textarea value={selected_text} onChange={handle_text} className="min-h-36 w-full rounded-2xl border border-border bg-background px-4 py-3 text-sm leading-6 outline-none focus:ring-2 focus:ring-primary" placeholder="Paste or simulate highlighted text here" />
                        </div>
                        <div className="mt-5 grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label className="block text-sm font-semibold mb-2">What the user already knows</label>
                                <textarea value={prior_knowledge} onChange={handle_prior} className="min-h-28 w-full rounded-2xl border border-border bg-background px-4 py-3 text-sm leading-6 outline-none focus:ring-2 focus:ring-primary" />
                            </div>
                            <div>
                                <label className="block text-sm font-semibold mb-2">Writing style the user understands</label>
                                <textarea value={preferred_style} onChange={handle_style} className="min-h-28 w-full rounded-2xl border border-border bg-background px-4 py-3 text-sm leading-6 outline-none focus:ring-2 focus:ring-primary" />
                            </div>
                        </div>
                        <div className="mt-5 grid grid-cols-1 md:grid-cols-[1fr_auto] gap-4 items-end">
                            <div>
                                <label className="block text-sm font-semibold mb-2">Learning style</label>
                                <input value={learning_style} onChange={handle_learning} className="h-12 w-full rounded-2xl border border-border bg-background px-4 text-sm outline-none focus:ring-2 focus:ring-primary" />
                            </div>
                            <button onClick={toggle_retention} className={("inline-flex h-12 items-center justify-center rounded-xl border px-4 text-sm font-semibold transition-colors " + ("border-success bg-success/10 text-success" if retention_mode else "border-border bg-background text-foreground hover:bg-card-hover"))}>{("Retention mode: On" if retention_mode else "Retention mode: Off")}</button>
                        </div>
                        <div className="mt-5">
                            <p className="text-sm font-semibold mb-3">Depth control</p>
                            <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                                <button onClick={set_level_1} className={("rounded-xl border px-4 py-3 text-sm font-semibold transition-colors " + ("border-primary bg-primary text-primary-foreground" if depth == "Level 1" else "border-border bg-background hover:bg-card-hover"))}>Level 1<br/><span className="text-xs font-normal opacity-80">Intuition</span></button>
                                <button onClick={set_level_2} className={("rounded-xl border px-4 py-3 text-sm font-semibold transition-colors " + ("border-primary bg-primary text-primary-foreground" if depth == "Level 2" else "border-border bg-background hover:bg-card-hover"))}>Level 2<br/><span className="text-xs font-normal opacity-80">Practical</span></button>
                                <button onClick={set_level_3} className={("rounded-xl border px-4 py-3 text-sm font-semibold transition-colors " + ("border-primary bg-primary text-primary-foreground" if depth == "Level 3" else "border-border bg-background hover:bg-card-hover"))}>Level 3<br/><span className="text-xs font-normal opacity-80">Technical</span></button>
                                <button onClick={set_level_4} className={("rounded-xl border px-4 py-3 text-sm font-semibold transition-colors " + ("border-primary bg-primary text-primary-foreground" if depth == "Level 4" else "border-border bg-background hover:bg-card-hover"))}>Level 4<br/><span className="text-xs font-normal opacity-80">Internal</span></button>
                            </div>
                        </div>
                        {error and (<div className="mt-4 rounded-2xl border border-destructive/20 bg-destructive/8 px-4 py-3 text-sm text-destructive">{error}</div>)}
                    </div>

                    <div className="rounded-[1.5rem] border border-border bg-card p-6 shadow-soft">
                        <div className="flex items-center justify-between gap-3 flex-wrap">
                            <div>
                                <p className="text-sm font-semibold uppercase tracking-[0.16em] text-primary">Structured explanation</p>
                                <h2 className="mt-2 text-2xl font-bold">Docker-style learning flow</h2>
                            </div>
                            <div className="rounded-full bg-secondary px-4 py-2 text-sm font-medium text-primary">{profile["depth"] if profile and profile["depth"] else depth}</div>
                        </div>
                        <div className="mt-5 space-y-4">
                            {[
                                <div key={section["title"]} className="rounded-2xl border border-border bg-background p-5">
                                    <h3 className="text-lg font-bold">{section["title"]}</h3>
                                    <p className="mt-2 text-sm leading-7 text-muted-foreground">{section["body"]}</p>
                                </div>
                                for section in sections
                            ]}
                        </div>
                    </div>
                </div>

                <div className="space-y-6">
                    <div className="rounded-[1.5rem] border border-border bg-card p-6 shadow-soft">
                        <p className="text-sm font-semibold uppercase tracking-[0.16em] text-primary">Why this matters</p>
                        <div className="mt-4 grid grid-cols-1 gap-3">
                            <div className="rounded-2xl bg-background p-4 border border-border">
                                <h3 className="font-bold">Hidden prerequisite knowledge</h3>
                                <p className="mt-1 text-sm text-muted-foreground">The engine explains missing context first instead of assuming the user already knows it.</p>
                            </div>
                            <div className="rounded-2xl bg-background p-4 border border-border">
                                <h3 className="font-bold">Vocabulary mismatch</h3>
                                <p className="mt-1 text-sm text-muted-foreground">It can rewrite explanations in a style closer to what the user already understands.</p>
                            </div>
                            <div className="rounded-2xl bg-background p-4 border border-border">
                                <h3 className="font-bold">Low retention</h3>
                                <p className="mt-1 text-sm text-muted-foreground">It adds optional quizzes, explain-it-back prompts, and application tasks so learning sticks.</p>
                            </div>
                        </div>
                    </div>

                    <div className="rounded-[1.5rem] border border-border bg-card p-6 shadow-soft">
                        <p className="text-sm font-semibold uppercase tracking-[0.16em] text-primary">Terminology bridging</p>
                        <h2 className="mt-2 text-2xl font-bold">Teach the real term and the plain meaning</h2>
                        <div className="mt-5 space-y-3">
                            {[
                                <div key={term["term"]} className="rounded-2xl border border-border bg-background p-4">
                                    <div className="flex items-center justify-between gap-3 flex-wrap">
                                        <span className="text-base font-bold">{term["term"]}</span>
                                        <span className="rounded-full bg-secondary px-3 py-1 text-xs font-semibold text-primary">{term["plain"]}</span>
                                    </div>
                                    <p className="mt-2 text-sm leading-6 text-muted-foreground">{term["usage"]}</p>
                                </div>
                                for term in unknown_terms
                            ]}
                        </div>
                    </div>

                    <div className="rounded-[1.5rem] border border-border bg-card p-6 shadow-soft">
                        <p className="text-sm font-semibold uppercase tracking-[0.16em] text-primary">Personalization profile</p>
                        <div className="mt-4 space-y-3 text-sm">
                            <div className="rounded-2xl bg-background border border-border p-4"><span className="font-semibold">Prior knowledge:</span><p className="mt-1 text-muted-foreground leading-6">{profile["prior_knowledge"] if profile and profile["prior_knowledge"] else prior_knowledge}</p></div>
                            <div className="rounded-2xl bg-background border border-border p-4"><span className="font-semibold">Preferred style:</span><p className="mt-1 text-muted-foreground leading-6">{result["style_preview"] if result and result["style_preview"] else preferred_style}</p></div>
                            <div className="rounded-2xl bg-background border border-border p-4"><span className="font-semibold">Learning style:</span><p className="mt-1 text-muted-foreground leading-6">{profile["learning_style"] if profile and profile["learning_style"] else learning_style}</p></div>
                            <div className="rounded-2xl bg-background border border-border p-4"><span className="font-semibold">Explain from zero rule:</span><p className="mt-1 text-muted-foreground leading-6">{result["context_from_zero"] if result and result["context_from_zero"] else "Define missing terms before using them."}</p></div>
                        </div>
                    </div>

                    <div className="rounded-[1.5rem] border border-border bg-card p-6 shadow-soft">
                        <div className="flex items-center justify-between gap-3 flex-wrap">
                            <div>
                                <p className="text-sm font-semibold uppercase tracking-[0.16em] text-primary">Retention mode</p>
                                <h2 className="mt-2 text-2xl font-bold">Optional memory support</h2>
                            </div>
                            <span className={("rounded-full px-4 py-2 text-sm font-semibold " + ("bg-success/10 text-success" if retention_mode else "bg-muted text-muted-foreground"))}>{("Enabled" if retention_mode else "Disabled")}</span>
                        </div>
                        <div className="mt-5 space-y-3">
                            {retention_items and [
                                <div key={item} className="rounded-2xl border border-border bg-background p-4 text-sm leading-6 text-muted-foreground">{item}</div>
                                for item in retention_items
                            ] or [
                                <div key="retention-off" className="rounded-2xl border border-dashed border-border bg-background p-4 text-sm leading-6 text-muted-foreground">Retention support is optional, so users can keep the experience lightweight when they just want a quick explanation.</div>
                            ]}
                        </div>
                    </div>
                </div>
            </section>
        </div>
    </div>;
}
