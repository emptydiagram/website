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

![DAG with a chain decomposition of size 3. An antichain of size 3 is also highlighted](assets/dag-width-chain-decomp.png)

So thanks to Dilworth's theorem, we just need to find the minimum size of a chain decomposition

# DAG path covers and maximum cardinality matchings of bipartite graphs

Next, we need the idea of a vertex-disjoint [path cover](https://en.wikipedia.org/wiki/Path_cover) of a DAG: a set of paths in the DAG such that every node belongs to exactly one of the paths (i.e. the paths partition the node set).

We also need the notion of turning a DAG into a bipartite graph. This is done by making a new graph, $B$, whose vertex set consists of the disjoint union of two copies of the nodes, $L = G.V$ and $R = G.V$, and whose edge set is formed by taking each $(u, v) \in G.E$ and drawing an edge from the copy of $u$ in $L$ to the copy of $v$ in $R$.

As an example, the above graph is transformed into this bipartite graph:

![The previous DAG transformed into a bipartite graph](assets/dag-width-bipartite-graph.png)

We bring the previous two ideas together with a third idea: a [matching](https://en.wikipedia.org/wiki/Matching_(graph_theory)), or independent edge set: a set of edges such that no two edges share the same vertex. It turns out there is a fundamental relationship between vertex-disjoint path covers of a DAG and the maximum cardinality matching of the bipartite graph version of a DAG:

$$\text{min vertex-disjoint path cover of } G = |G.V| - \text{max matching size of } \text{Bip}(G)$$

TODO

# Transitive closure DAGs

TODO


# Hopcroft-Karp algorithm

TODO
