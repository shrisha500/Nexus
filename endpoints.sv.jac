"""Adaptive Explanation Engine — Server-Side Data Layer.

Each authenticated user gets their own persistent graph rooted at their
personal root node. Public walkers are exposed as REST endpoints by
`jac start`. Private walkers are internal pipeline steps only.
"""

import from jaclang.runtimelib.builtin { jid }

# ============================================================
# NODES
# Nodes are persistent data objects stored in the graph.
# Think of them as your database tables, but connected
# to each other directly instead of through foreign keys.
# ============================================================

node UserProfile {
    # Stores long-term preferences for one user.
    # Connected directly to root so it persists forever.
    has known_topics: list[str],    # e.g. ["python", "REST APIs"] — skipped during prereq discovery
        style_example: str,         # a passage of text the user understands well — used to match tone
        depth_pref: int,            # default depth level 1–4 used when no depth override is sent
        retention_mode: bool = False; # whether the user wants a quiz after each explanation
}

node ExplanationSession {
    # Created once per explain request. The anchor for everything
    # produced during that request — concepts, terms, quiz.
    has raw_text: str,              # the exact text the user submitted
        source_url: str,            # page URL the text came from (empty string for direct paste)
        depth: int,                 # depth level used for this specific request
        created_at: str;            # ISO timestamp string — used to sort session history
}

node ConceptNode {
    # One node per concept in the explanation chain.
    # The user's actual selection has is_prereq=False.
    # Every prerequisite discovered by DependencyWalker has is_prereq=True.
    has concept_name: str,          # label e.g. "Docker", "OS-level virtualization"
        depth_level: int,           # depth at this node: main concept = session.depth, prereqs decrement
        explanation: str = "",      # filled in by ExplanationBuilderWalker — empty until then
        is_prereq: bool = False;    # False = user's selection, True = discovered prerequisite
}

node TermNode {
    # One node per jargon term found inside a concept's explanation.
    # Attached to the ConceptNode whose explanation the term appears in.
    has word: str,                  # the term as it appeared e.g. "SDLC"
        plain_meaning: str,         # plain-English meaning e.g. "the steps to build and ship software"
        real_name: str,             # proper technical name (may differ from word)
        usage_context: str;         # when and where this term is used in practice
}


# ============================================================
# EDGES
# Edges are the typed connections between nodes.
# They can carry their own data fields, just like nodes.
# ============================================================

# [UserProfile] --HasSession--> [ExplanationSession]
edge HasSession {
    has created_at: str,            # timestamp on the edge — lets us sort history without loading session nodes
        explanation_depth: int;     # depth for this session — lets us filter history without loading session nodes
}

# [ExplanationSession] --HasConcept--> [ConceptNode]
edge HasConcept {
    has order: int,                 # render sequence: 0 = first shown (deepest prereq), highest = user's concept
        user_actually_chose: bool;       # True only for the concept the user actually selected
}

# [ConceptNode A] --DependsOn--> [ConceptNode B]
# Means: A cannot be understood without first understanding B.
edge DependsOn {
    has priority: int,              # when A has multiple prereqs, lower number = explain first
        relationship: str,          # why A depends on B e.g. "Docker is built on top of this"
        auto_discovered: bool;      # True = found by LLM, False = manually set (reserved for future use)
}

# [ConceptNode] --UsesTerm--> [TermNode]
edge UsesTerm {
    has position_in_text: int,      # char index where this term first appears in ConceptNode.explanation
        is_defined_before_use: bool; # True if an earlier ConceptNode already introduced this term
}


# ============================================================
# ENUMS
# ============================================================

enum SectionType {
    # The seven structured sections every concept explanation follows.
    # ExplanationBuilderWalker loops over these in order for each ConceptNode.
    WHY_IT_EXISTS = "why_it_exists",
    PROBLEM_IT_SOLVES = "problem_it_solves",
    WHAT_CAME_BEFORE = "what_came_before",
    WHAT_IT_IS = "what_it_is",
    HOW_IT_WORKS = "how_it_works",
    TRADEOFFS = "tradeoffs",
    HOW_TO_USE = "how_to_use"       # only generated at depth 3 or 4
}


# ============================================================
# LLM FUNCTIONS
# These use Jac's `by llm()` syntax — no prompt strings needed.
# The function name, parameter names, types, and `sem` annotation
# together form the full specification the LLM receives.
# ============================================================

def extract_unknown_terms(raw_text: str, known_topics: list[str]) -> list[str] by llm();
sem extract_unknown_terms = "Given a block of text and a list of topics the user already understands, identify technical jargon, acronyms, or domain-specific terms in the text that the user likely does not know. Return only the terms themselves as a list of strings, ordered by first appearance in the text.";

def discover_prerequisites(concept_name: str, known_topics: list[str], depth_remaining: int) -> list[str] by llm();
sem discover_prerequisites = "Given a concept name and a list of topics the user already understands, return a list of prerequisite concept names a person must understand before they can understand this concept. Exclude any concepts already in known_topics. Order the list from most foundational to least foundational. If depth_remaining is 0 or the concept has no meaningful prerequisites, return an empty list.";

def build_section(concept_name: str, section_type: str, style_example: str, depth_level: int, known_terms: list[str]) -> str by llm();
sem build_section = "Write one section of an explanation for the given concept. section_type controls what this section covers: why_it_exists is the motivation, problem_it_solves is what problem it fixes, what_came_before is prior approaches, what_it_is defines it plainly, how_it_works explains the mechanism, tradeoffs covers limitations, how_to_use gives practical guidance. Match the vocabulary and tone of style_example. depth_level controls detail: 1 is high-level intuition, 2 is practical understanding, 3 is technical detail, 4 is deep internals. Do not re-explain any terms in known_terms. Return only the section text with no headers.";

def explain_term(word: str, concept_context: str, style_example: str) -> dict[str, str] by llm();
sem explain_term = "Given a technical term found inside an explanation of concept_context, return a dictionary with exactly three keys: plain_meaning (plain-English definition), real_name (proper technical name, may differ from word), and usage_context (short phrase describing when and where this term is used). Match the tone of style_example.";

def describe_relationship(dependent_concept: str, prerequisite_concept: str) -> str by llm();
sem describe_relationship = "In one short phrase, describe why understanding prerequisite_concept is necessary before understanding dependent_concept. Example: 'Docker is built on top of this' or 'Docker replaces this approach'. Return only the phrase.";

def generate_quiz(concept_explanations: list[dict[str, str]]) -> list[dict[str, list[str]]] by llm();
sem generate_quiz = "Given concept_explanations, a list of dicts where each dict has one key (concept name) mapped to its explanation text, generate a multiple choice quiz covering the key ideas. Return a list of dicts where each dict has one key (the question text) mapped to a list of 4 answer strings. The correct answer must always be first in the list.";


# ============================================================
# PUBLIC WALKERS
#
# WHY PUBLIC VS PRIVATE — explained for beginners:
#
# When you run `jac start main.jac`, Jac reads your file and
# automatically creates an HTTP REST API. Every PUBLIC walker
# becomes an endpoint the frontend can call over the internet.
# For example, `walker Explain` becomes POST /Explain.
# The frontend sends JSON (the walker's `has` fields), Jac runs
# the walker, and whatever the walker `report`s comes back as
# the HTTP response.
#
# PRIVATE walkers (`walker:priv`) are NOT exposed as endpoints.
# They can only be spawned from inside other Jac code. The user's
# browser has no way to call them directly.
#
# WHY DOES THIS MATTER?
# Security and correctness. You never want the frontend to be
# able to call DependencyWalker directly and skip the session
# setup. Private walkers enforce that the pipeline always runs
# in the right order with properly validated data. They also
# keep your API surface small and easy to reason about.
#
# SIMPLE RULE:
#   Public  = things the frontend calls (your API).
#   Private = internal steps only Jac orchestrates.
# ============================================================

# ----------------------------------------------------------
# Explain
# The main entry point for the entire pipeline.
# Called when the user submits text on the website.
# Creates the session, orchestrates all private walkers in
# sequence, and returns the finished explanation payload.
# ----------------------------------------------------------
walker Explain {
    # These three fields are the ONLY things the frontend sends.
    # Everything else (known_topics, style_example, etc.) lives
    # in the UserProfile node and is read from the graph.
    has raw_text: str,
        source_url: str = "",
        depth: int = 2;

    can start with Root entry {
        # Step 1: Find or create this user's UserProfile.
        # Because Jac gives each authenticated user their own root node,
        # [root()-->][?:UserProfile] only ever finds THIS user's profile —
        # never another user's.
        profile_nodes = [root()-->][?:UserProfile];

        if not profile_nodes {
            # First visit — create a profile with safe defaults.
            # The user should call SetupProfile to fill in real values.
            new_profile = UserProfile(
                known_topics=[],
                style_example="",
                depth_pref=depth, # should this be here.depth or just depth fromline 171?
                retention_mode=False
            );
            root() ++> new_profile;
            profile = new_profile;
        } else {
            profile = profile_nodes[0];
        }

        # Step 2: Decide the effective depth for this request.
        effective_depth = depth if depth > 0 else profile.depth_pref;

        # Step 3: Create the ExplanationSession node.
        import from datetime { datetime, UTC };
        now = datetime.now(UTC);

        session = ExplanationSession(
            raw_text=raw_text,
            source_url=source_url,
            depth=effective_depth,
            created_at=now
        );

        # Connect session to profile via a HasSession edge.
        profile +>: HasSession(created_at=now, explanation_depth=effective_depth) :+> session;

        # Capture the session's unique ID so every downstream walker can
        # find exactly this session, even if the user has many sessions.
        session_id = jid(session);

        # Step 4: Flag unknown jargon terms early.
        # Returns a flat list of strings e.g. ["SDLC", "artifact", "container"].
        # Does NOT create TermNodes yet — that happens in the builder below.
        terms = root() spawn TermExtractorWalker(
            session_id=session_id,
            known_topics=profile.known_topics
        );

        # Step 5: Build the prerequisite ConceptNode graph.
        root() spawn DependencyWalker(
            session_id=session_id,
            known_topics=profile.known_topics,
            depth_remaining=effective_depth
        );

        # Step 6: Generate the actual explanation text for every concept.
        result = root() spawn ExplanationBuilderWalker(
            session_id=session_id,
            known_topics=profile.known_topics,
            style_example=profile.style_example,
            flagged_terms=terms
        );

        # Step 7: Optionally generate a quiz.
        if profile.retention_mode {
            quiz_result = root() spawn RetentionWalker(session_id=session_id);
            report { "explanation": result, "quiz": quiz_result };
        } else {
            report { "explanation": result, "quiz": [] };
        }
    }
}


# ----------------------------------------------------------
# SetupProfile
# Called during onboarding (the survey screen).
# Can also be called again to update preferences later.
# ----------------------------------------------------------
walker SetupProfile {
    has known_topics: list[str],
        style_example: str,
        depth_pref: int = 2,
        retention_mode: bool = False;

    can setup with Root entry {
        existing = [root()-->][?:UserProfile];

        if existing {
            # Update the existing profile in place.
            p = existing[0];
            p.known_topics=known_topics;
            p.style_example =style_example;
            p.depth_pref = here.depth_pref;
            p.retention_mode = here.retention_mode;
            report { "status": "updated", "profile_id": jid(p) };
        } 
        else {
            new_profile = UserProfile(
                known_topics=here.known_topics,
                style_example=here.style_example,
                depth_pref=here.depth_pref,
                retention_mode=here.retention_mode
            );
            root() ++> new_profile;
            report { "status": "created", "profile_id": jid(new_profile) };
        }
    }
}


# ----------------------------------------------------------
# GetSessions
# Returns a preview list of all past sessions for this user,
# newest first. Used to populate a history/sidebar view.
# ----------------------------------------------------------
walker GetSessions {
    can fetch with Root entry {
        profile_nodes = [root()-->][?:UserProfile];

        if not profile_nodes {
            report { "sessions": [] };
            disengage;
        }

        profile = profile_nodes[0];

        # Traverse through HasSession edges to reach all ExplanationSession nodes.
        sessions = [profile->:HasSession:->][?:ExplanationSession];

        result = [];
        for s in sessions {
            result.append({
                "session_id": jid(s),
                "raw_text_preview": s.raw_text[:120],
                "depth": s.depth,
                "created_at": s.created_at
            });
        }

        # ISO timestamp strings sort correctly lexicographically.
        result = sorted(result, key=lambda x: str { return x["created_at"]; }, reverse=True);
        report { "sessions": result };
    }
}


# ----------------------------------------------------------
# GetSessionDetail
# Returns the full explanation data for one specific session.
# Called when the user clicks a session in their history.
# ----------------------------------------------------------
walker GetSessionDetail {
    has session_id: str;

    can fetch with Root entry {
        profile_nodes = [root()-->][?:UserProfile];

        if not profile_nodes {
            report { "error": "no profile found" };
            disengage;
        }

        profile = profile_nodes[0];
        all_sessions = [profile->:HasSession:->][?:ExplanationSession];

        # Find the one session matching the requested ID.
        target = null;
        for s in all_sessions {
            if str(jid(s)) == here.session_id {
                target = s;
                break;
            }
        }

        if not target {
            report { "error": "session not found" };
            disengage;
        }

        # Collect all ConceptNodes, sorted by their render order.
        concept_nodes = [target->:HasConcept:->][?:ConceptNode];
        ordered = sorted(
            concept_nodes,
            key=lambda c: ConceptNode -> int { return [target->:HasConcept:->c][0].order; }
        );

        concepts_out = [];
        for c in ordered {
            edge_data = [target->:HasConcept:->c][0];

            term_nodes = [c->:UsesTerm:->][?:TermNode];
            terms_out = [];
            for t in term_nodes {
                ue = [c->:UsesTerm:->t][0];
                terms_out.append({
                    "word": t.word,
                    "plain_meaning": t.plain_meaning,
                    "real_name": t.real_name,
                    "usage_context": t.usage_context,
                    "position_in_text": ue.position_in_text,
                    "is_defined_before_use": ue.is_defined_before_use
                });
            }

            concepts_out.append({
                "concept_name": c.concept_name,
                "is_prereq": c.is_prereq,
                "user_actually_chose": edge_data.user_actually_chose,
                "order": edge_data.order,
                "depth_level": c.depth_level,
                "explanation": c.explanation,
                "terms": terms_out
            });
        }

        report {
            "session_id": here.session_id,
            "raw_text": target.raw_text,
            "source_url": target.source_url,
            "depth": target.depth,
            "created_at": target.created_at,
            "concepts": concepts_out
        };
    }
}


# ============================================================
# PRIVATE WALKERS
# Not exposed as HTTP endpoints.
# Only spawnable from other Jac walkers (like Explain above).
# ============================================================

# ----------------------------------------------------------
# TermExtractorWalker
# Finds the session by session_id, calls extract_unknown_terms,
# and returns a flat list of jargon strings.
# Does NOT create TermNodes — the builder does that later
# once it knows which ConceptNode each term belongs to.
# ----------------------------------------------------------
walker:priv TermExtractorWalker {
    has session_id: str,
        known_topics: list[str];

    can extract with Root entry {
        profile = [root()-->][?:UserProfile][0];
        all_sessions = [profile->:HasSession:->][?:ExplanationSession];

        target = null;
        for s in all_sessions {
            if str(jid(s)) == here.session_id {
                target = s;
                break;
            }
        }

        if not target {
            report [];
            disengage;
        }

        terms = extract_unknown_terms(
            raw_text=target.raw_text,
            known_topics=here.known_topics
        );

        report terms;
    }
}


# ----------------------------------------------------------
# DependencyWalker
# Builds the full ConceptNode graph for one session.
# Creates the main concept node, BFS-discovers prereqs,
# links them with DependsOn edges, then runs a topological
# sort to assign final order integers to HasConcept edges.
# ----------------------------------------------------------
walker:priv DependencyWalker {
    has session_id: str,
        known_topics: list[str],
        depth_remaining: int;   # decrements each BFS level; stops discovering at 1

    can build with Root entry {
        profile = [root()-->][?:UserProfile][0];
        all_sessions = [profile->:HasSession:->][?:ExplanationSession];

        target = null;
        for s in all_sessions {
            if str(jid(s)) == here.session_id {
                target = s;
                break;
            }
        }

        if not target { disengage; }

        # Create the main ConceptNode for the user's selected text.
        main_concept = ConceptNode(
            concept_name=target.raw_text[:80], # TODO: Should instead make a by llm() function to parse raw text for the concept name
            depth_level=here.depth_remaining,
            is_prereq=False
        );
        # order=-1 is a placeholder; topo sort will overwrite it below.
        target +>: HasConcept(order=-1, user_actually_chose=True) :+> main_concept; # TODO: change name to user_actually_chose

        # BFS queue: each item is [ConceptNode, remaining_depth].
        queue = [[main_concept, here.depth_remaining]];
        visited_names = [target.raw_text[:80]]; # ??????
        all_nodes = [main_concept];

        while queue {
            current_node = queue[0][0];
            remaining = queue[0][1];
            queue = queue[1:];

            # At depth 1 we explain the concept but discover no deeper prereqs.
            if remaining <= 1 {
                continue; # goes to next while iteration
            }

            prereqs = discover_prerequisites(
                concept_name=current_node.concept_name,
                known_topics=here.known_topics + visited_names,
                depth_remaining=remaining - 1
            );

            for idx in range(len(prereqs)) {
                prereq_name = prereqs[idx];

                if prereq_name in visited_names { continue; }
                visited_names.append(prereq_name);

                rel = describe_relationship(
                    dependent_concept=current_node.concept_name,
                    prerequisite_concept=prereq_name
                );

                prereq_node = ConceptNode(
                    concept_name=prereq_name,
                    depth_level=remaining - 1,
                    is_prereq=True
                );

                # current_node depends on prereq_node.
                # priority is 1-indexed; lower = more foundational = explain first.
                current_node +>: DependsOn(
                    priority=idx + 1,
                    relationship=rel,
                    auto_discovered=True
                ) :+> prereq_node;

                # Also connect the prereq to the session so we can query
                # all concepts for this session from one place.
                target +>: HasConcept(order=-1, user_actually_chose=False) :+> prereq_node;

                all_nodes.append(prereq_node);
                queue.append([prereq_node, remaining - 1]);
            }
        }

        # Run topological sort and assign order to HasConcept edges.
        sorted_nodes = here.topo_sort(all_nodes);
        for idx in range(len(sorted_nodes)) {
            edge = [target->:HasConcept:->sorted_nodes[idx]][0];
            edge.order = idx;
        }
    }

    # Kahn's algorithm for topological sort.
    # In-degree = how many ConceptNodes point TO this node via DependsOn.
    # Nodes with in-degree 0 (nobody depends on them) are the most foundational
    # prerequisites — they get the lowest order numbers and render first.
    def topo_sort(nodes: list) -> list {
        in_degree = {};
        for n in nodes {
            in_degree[n.concept_name] = 0;
        }

        for n in nodes {
            prereqs = [n->:DependsOn:->][?:ConceptNode];
            for p in prereqs {
                if p.concept_name in in_degree {
                    in_degree[p.concept_name] += 1;
                }
            }
        }

        queue = [n for n in nodes if in_degree[n.concept_name] == 0];
        sorted_list = [];

        while queue {
            node = queue[0];
            queue = queue[1:];
            sorted_list.append(node);

            dependents = [node<-:DependsOn:<-][?:ConceptNode];
            for d in dependents {
                in_degree[d.concept_name] -= 1;
                if in_degree[d.concept_name] == 0 {
                    queue.append(d);
                }
            }
        }

        return sorted_list;
    }
}


# ----------------------------------------------------------
# ExplanationBuilderWalker
# Walks the ordered ConceptNode chain and generates the actual
# text. For each concept it calls build_section() by llm for
# each section type, writes the result onto the ConceptNode,
# then creates TermNodes for flagged terms that appear in the
# explanation and attaches them via UsesTerm edges.
# ----------------------------------------------------------
walker:priv ExplanationBuilderWalker {
    has session_id: str,
        known_topics: list[str],
        style_example: str,
        flagged_terms: list[str];   # list of jargon strings from TermExtractorWalker

    # Walker-level state — persists across the whole traversal.
    # seen_terms grows as we visit each concept so later concepts
    # correctly set is_defined_before_use=True on their UsesTerm edges.
    has seen_terms: list[str] = [],
        built_concepts: list = [];

    can build with Root entry {
        profile = [root()-->][?:UserProfile][0];
        all_sessions = [profile->:HasSession:->][?:ExplanationSession];

        target = null;
        for s in all_sessions {
            if str(jid(s)) == here.session_id {
                target = s;
                break;
            }
        }

        if not target { disengage; }

        # Get all ConceptNodes sorted by HasConcept.order (set by DependencyWalker).
        concept_nodes = [target->:HasConcept:->][?:ConceptNode];
        ordered = sorted(
            concept_nodes,
            key=lambda c: ConceptNode -> int { return [target->:HasConcept:->c][0].order; }
        );

        for concept in ordered {
            # Decide which sections to generate based on this concept's depth_level.
            section_types = [
                SectionType.WHY_IT_EXISTS,
                SectionType.PROBLEM_IT_SOLVES,
                SectionType.WHAT_CAME_BEFORE,
                SectionType.WHAT_IT_IS,
                SectionType.HOW_IT_WORKS,
                SectionType.TRADEOFFS
            ];
            if concept.depth_level >= 3 {
                section_types.append(SectionType.HOW_TO_USE);
            }

            sections_out = [];
            full_explanation = "";

            for section_type in section_types {
                section_text = build_section(
                    concept_name=concept.concept_name,
                    section_type=section_type.value,
                    style_example=here.style_example,
                    depth_level=concept.depth_level,
                    known_terms=here.known_topics + here.seen_terms
                );
                full_explanation += section_text + "\n\n";
                sections_out.append({
                    "type": section_type.value,
                    "content": section_text
                });
            }

            # Write the finished explanation onto the ConceptNode.
            # This caches it in the graph — future sessions could reuse it.
            concept.explanation = full_explanation.strip();

            # Find flagged terms that appear in this explanation,
            # create TermNodes, and attach them via UsesTerm edges.
            terms_out = [];
            for term_word in here.flagged_terms {
                pos = full_explanation.find(term_word);
                if pos == -1 { continue; } # NOTE: Look at this again

                already_defined = term_word in here.seen_terms;

                term_data = explain_term(
                    word=term_word,
                    concept_context=concept.concept_name,
                    style_example=here.style_example
                );

                term_node = TermNode(
                    word=term_word,
                    plain_meaning=term_data["plain_meaning"],
                    real_name=term_data["real_name"],
                    usage_context=term_data["usage_context"]
                );

                concept +>: UsesTerm(
                    position_in_text=pos,
                    is_defined_before_use=already_defined
                ) :+> term_node;

                if not already_defined {
                    here.seen_terms.append(term_word);
                }

                terms_out.append({
                    "word": term_word,
                    "plain_meaning": term_data["plain_meaning"],
                    "real_name": term_data["real_name"],
                    "usage_context": term_data["usage_context"],
                    "position_in_text": pos,
                    "is_defined_before_use": already_defined
                });
            }

            edge_data = [target->:HasConcept:->concept][0];
            here.built_concepts.append({
                "concept_name": concept.concept_name,
                "is_prereq": concept.is_prereq,
                "user_actually_chose": edge_data.user_actually_chose,
                "order": edge_data.order,
                "depth_level": concept.depth_level,
                "sections": sections_out,
                "terms": terms_out
            });
        }

        report here.built_concepts;
    }
}


# ----------------------------------------------------------
# RetentionWalker
# Only spawned if UserProfile.retention_mode is True (checked
# in Explain before this walker is ever called).
# Reads all completed concept explanations and generates a quiz.
# ----------------------------------------------------------
walker:priv RetentionWalker {
    has session_id: str;

    can quiz with Root entry {
        profile = [root()-->][?:UserProfile][0];
        all_sessions = [profile->:HasSession:->][?:ExplanationSession];

        target = null;
        for s in all_sessions {
            if str(jid(s)) == here.session_id {
                target = s;
                break;
            }
        }

        if not target {
            report [];
            disengage;
        }

        concept_nodes = [target->:HasConcept:->][?:ConceptNode];

        concept_explanations = [];
        for c in concept_nodes {
            if c.explanation {
                concept_explanations.append({ c.concept_name: c.explanation });
            }
        }

        if not concept_explanations {
            report [];
            disengage;
        }

        quiz = generate_quiz(concept_explanations=concept_explanations);
        report quiz;
    }
}