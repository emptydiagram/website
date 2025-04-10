---
title: How to compute the width of a DAG
date: 2025-04-10
---

# Antichains and Dilworth's Theorem

There's lots of different possible definitions of "width" for a directed acyclic graph. For an app I'm developing, I wanted a simple way to measure how far from linear a DAG is, with the constraint that it generalizes my intuition that the width of a directed tree is the number of leaves. The definition I settled on is the **maximum antichain size**, where an **antichain** for a DAG $G$ is any set of nodes $S$ such that for any distinct pair $u, v \in S$, $u \neq v$, there is no path from $u$ to $v$ in $G$.

Okay, so how can this maximum-size antichain be found? First, we need [Dilworth's theorem](https://en.wikipedia.org/wiki/Dilworth%27s_theorem), which states:

> in any finite partially ordered set, the maximum size of an antichain of incomparable elements equals the minimum number of chains needed to cover all elements.

The theorem is talking about partially ordered sets (posets), not DAGs, but this works for our purpose because every DAG is secretly a poset: just take the [transitive closure](https://en.wikipedia.org/wiki/Transitive_closure) of the edge relation, and you get a [strict partial order](https://en.wikipedia.org/wiki/Partially_ordered_set#Strict_partial_orders). Using this partial ordering language, another way to define an antichain is any set of nodes that are mutually [incomparable](https://en.wikipedia.org/wiki/Comparability) under the DAG ordering.

We should also be specific about the second part of the theorem: the "chain cover", or more precisely **chain decomposition**, is a partition of the node set into a collection of [chains](https://en.wikipedia.org/wiki/Total_order#Chains) or totally ordered subsets.

For example, I've drawn a DAG below as well as a minimum-size chain decomposition of size 3. This isn't the only such chain decomposition, but there are no smaller decompositions. Note also that an antichain of size 3 is highlighted in red.

![Figure 1: DAG with a chain decomposition of size 3. An antichain of size 3 is highlighted in red.](assets/dag-width-chain-decomp.png)

So thanks to Dilworth's theorem, we just need to find the minimum size of a chain decomposition

# DAG path covers and maximum cardinality matchings of bipartite graphs

Next, we need the idea of a vertex-disjoint [path cover](https://en.wikipedia.org/wiki/Path_cover) of a DAG: a set of paths in the DAG such that every node belongs to exactly one of the paths (i.e. the paths partition the node set).

We also need the notion of turning a DAG into a bipartite graph. This is done by making a new graph, $B$, whose vertex set consists of the disjoint union of two copies of the nodes, $L = G.V$ and $R = G.V$, and whose edge set is formed by taking each $(u, v) \in G.E$ and drawing an edge from the copy of $u$ in $L$ to the copy of $v$ in $R$.

As an example, the above graph is transformed into this bipartite graph:

![Figure 2: The previous DAG transformed into a bipartite graph](assets/dag-width-bipartite-graph.png)

We bring the previous two ideas together with a third idea: a [matching](https://en.wikipedia.org/wiki/Matching_(graph_theory)), or independent edge set: a set of edges such that no two edges share the same vertex. It turns out there is a fundamental relationship between vertex-disjoint path covers of a DAG and the maximum cardinality matching of the bipartite graph version of a DAG:

$$\boxed{\text{min vertex-disjoint path cover size of } G = |G.V| - \text{max matching size of } \text{Bip}(G)}$$

This is because every edge you add in the matching joins two paths that were previously separate, thereby reducing the number of paths in the path cover by 1. Initially there are |G.V| paths, each of consisting of a single node with no edges in it. Finding a matching of maximum cardinality among all matches is another way of saying you can construct a vertex-disjoint path cover of minimum cardinality.

![Figure 3: The path cover corresponding to a matching](assets/dag-width-bipartite-matching-path-cover-1.png)

Note that the above matching is non-maximal: we can add $a \to b$ to the matching to reduce the path cover size by 1. After this addition, however, we are stuck and can't add any more edges, so the resulting matching is maximal. But $|G.V| = 8$, and the resulting maximal matching has a size of 4, so the resulting vertex-disjoint path cover has a size of $8 - 4 = 4$. But we already know from Figure 1 that there's a path cover of size 3. Here the bipartite matching that produces it:

![Figure 4: The maximum bipartite matching corresponding to the path cover (chain decomposition) shown in Figure 1.](assets/dag-width-bipartite-matching-path-cover-2.png)

I included this example just to point out that we will need to be careful when trying to find a maximum matching: if we choose incorrectly, we can get stuck in a locally optimum matching that is not globally optimal.

# Transitive closure DAGs

What is the max antichain size of the DAG below?

![Figure 5: A DAG](assets/dag-width-graph-2.png)

It's clearly 2: either $\{a, b\}$ or $\{d, e\}$ work. But look at the corresponding chain decomposition:

![Figure 6: Chain decomp of the DAG in Figure 5. The max antichain is highlighted in red.](assets/dag-width-graph-2.png)

It may seem counterintuitive at first since we have chains $a \to c \to d$ and $b \to e$, but $b$ and $e$ are not directly connected! However, we have to remember that Dilworth's theorem talks about partially ordered sets, not DAGs. Therefore, the graph we actually care about is the transitive closure graph:

![Figure 7: The transitive closure of the DAG in Figure 5.](assets/dag-width-graph-2-transitive-closure.png)

Therefore, we form the transitive closure graph $G^\ast$, which is the graph with the same nodes as $G$ and edges $(u, v)$ for all non-trivial paths from $u$ to $v$ in $G$. Since edges in $G^\ast$ correspond to paths in $G$, it's easy to see that paths in $G^\ast$ correspond to [subsequences](https://en.wikipedia.org/wiki/Subsequence) of paths in $G$. In other words, paths in $G^\ast$ are *chains* (totally-ordered subsets) under the DAG ordering.

Now apply the equation from the previous section:

$$\text{min vertex-disjoint path cover size of } G^\ast = |G.V| - \text{max matching size of } \text{Bip}(G^\ast)$$

Note that "vertex-disjoint path cover" of $G^\ast$ is just a synonym for "chain decomposition", for reasons just described. So what we have here is:

$$\boxed{\text{min chain decomposition size of } G^\ast = |G.V| - \text{max matching size of } \text{Bip}(G^\ast)}$$

To compute the width of a DAG, we simply need a way to efficiently compute the maximum cardinality matching of a bipartite graph.

# Hopcroft-Karp algorithm

It turns out that the [Hopcroft-Karp algorithm](https://en.wikipedia.org/wiki/Hopcroft%E2%80%93Karp_algorithm) (see also [here](https://algorithms.discrete.ma.tum.de/graph-algorithms/matchings-hopcroft-karp/index_en.html)) does exactly this, and it runs in worst-case $O(|E| \sqrt{|V|})$ time. My particular use case involves analyzing the [BlueSky](https://bsky.social) post graph, where each node can have at most two edges. This means $|E| = O(2 |V|)$, so it runs in worst-case $O(|V|^1.5)$, which isn't too terrible!

TODO: describe
