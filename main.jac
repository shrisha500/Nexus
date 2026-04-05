"""hackathon_project - Entry Point.

Combines server-side endpoints with client-side UI.
"""

# Import server-side data models and walkers
sv {
    import from endpoints { UserProfile, ExplanationSession, ConceptNode, HasConcept, DependsOn, UsesTerm, TermExtractorWalker, DependencyWalker, ExplanationBuilderWalker }
}

# Client-side UI
cl {
    import from .frontend { app as ClientApp }

    def:pub app -> JsxElement {
        return
            <ClientApp />;
    }
}