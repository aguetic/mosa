import type { ProvenanceEvidence, ProvenanceStatement } from "./provenance";

export interface EvidenceContextGroup {
  contextKey: string;
  label: "Reported together";
  evidence: ProvenanceEvidence;
  statements: ProvenanceStatement[];
}

export interface GroupedProvenanceStatements {
  groups: EvidenceContextGroup[];
  ungrouped: ProvenanceStatement[];
}

interface CandidateContext {
  contextKey: string;
  evidence: ProvenanceEvidence;
  statementIds: Set<string>;
}

export function evidenceContextKey(evidence: ProvenanceEvidence): string | null {
  if (!evidence.excerpt || evidence.excerpt.trim().length === 0) {
    return null;
  }

  return JSON.stringify([evidence.sourceId, evidence.locator, evidence.excerpt]);
}

export function groupProvenanceStatementsByEvidenceContext(
  statements: readonly ProvenanceStatement[],
): GroupedProvenanceStatements {
  const statementOrder = new Map(statements.map((statement, index) => [statement.id, index]));
  const candidates = new Map<string, CandidateContext>();
  const statementContextKeys = new Map<string, Set<string>>();

  for (const statement of statements) {
    const seenForStatement = new Set<string>();

    for (const evidence of statement.evidence) {
      const contextKey = evidenceContextKey(evidence);
      if (!contextKey || seenForStatement.has(contextKey)) {
        continue;
      }

      seenForStatement.add(contextKey);
      const candidate = candidates.get(contextKey) ?? {
        contextKey,
        evidence,
        statementIds: new Set<string>(),
      };
      candidate.statementIds.add(statement.id);
      candidates.set(contextKey, candidate);

      const keys = statementContextKeys.get(statement.id) ?? new Set<string>();
      keys.add(contextKey);
      statementContextKeys.set(statement.id, keys);
    }
  }

  const sharedCandidates = [...candidates.values()].filter(
    (candidate) => candidate.statementIds.size >= 2,
  );
  const sharedKeys = new Set(sharedCandidates.map((candidate) => candidate.contextKey));

  const assignedByContext = new Map<string, ProvenanceStatement[]>();

  for (const statement of statements) {
    const matchingKeys = [...(statementContextKeys.get(statement.id) ?? [])].filter((key) =>
      sharedKeys.has(key),
    );

    if (matchingKeys.length !== 1) {
      continue;
    }

    const [contextKey] = matchingKeys;
    if (!contextKey) {
      continue;
    }

    const grouped = assignedByContext.get(contextKey) ?? [];
    grouped.push(statement);
    assignedByContext.set(contextKey, grouped);
  }

  const assignedStatementIds = new Set<string>();
  const groups = sharedCandidates
    .flatMap((candidate): EvidenceContextGroup[] => {
      const groupedStatements = (assignedByContext.get(candidate.contextKey) ?? []).sort(
        (left, right) => (statementOrder.get(left.id) ?? 0) - (statementOrder.get(right.id) ?? 0),
      );

      if (groupedStatements.length < 2) {
        return [];
      }

      for (const statement of groupedStatements) {
        assignedStatementIds.add(statement.id);
      }

      return [
        {
          contextKey: candidate.contextKey,
          label: "Reported together",
          evidence: candidate.evidence,
          statements: groupedStatements,
        },
      ];
    })
    .sort((left, right) => {
      const leftIndex = Math.min(
        ...left.statements.map((statement) => statementOrder.get(statement.id) ?? 0),
      );
      const rightIndex = Math.min(
        ...right.statements.map((statement) => statementOrder.get(statement.id) ?? 0),
      );
      return leftIndex - rightIndex;
    });

  return {
    groups,
    ungrouped: statements.filter((statement) => !assignedStatementIds.has(statement.id)),
  };
}
