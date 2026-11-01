import {
  DEFAULT_SETTINGS,
  MAX_HISTORY_TURNS,
  MAX_TARGET_WORDS,
  type ChatTurn,
  type Correction,
  type CorrectionLevel,
  type EnglishLevel,
  type TargetWord,
  type TutorSettings,
} from "./types.ts";

const LEVELS: EnglishLevel[] = ["A1", "A2", "B1", "B2", "C1", "C2"];
const CORRECTION_LEVELS: CorrectionLevel[] = ["low", "medium", "high"];

const str = (value: unknown): string =>
  typeof value === "string" ? value.trim() : "";

export function toSettings(raw: unknown): TutorSettings {
  if (!raw || typeof raw !== "object") return DEFAULT_SETTINGS;

  const record = raw as Record<string, unknown>;
  const level = str(record.english_level).toUpperCase() as EnglishLevel;
  const correction = str(
    record.correction_level,
  ).toLowerCase() as CorrectionLevel;

  return {
    english_level: LEVELS.includes(level)
      ? level
      : DEFAULT_SETTINGS.english_level,
    correction_level: CORRECTION_LEVELS.includes(correction)
      ? correction
      : DEFAULT_SETTINGS.correction_level,
  };
}

export function toTurns(
  raw: unknown,
  limit = MAX_HISTORY_TURNS,
): ChatTurn[] {
  if (!Array.isArray(raw)) return [];

  const turns: ChatTurn[] = [];

  for (const entry of raw) {
    if (!entry || typeof entry !== "object") continue;

    const record = entry as Record<string, unknown>;
    const role = str(record.role);
    const content = str(record.content);

    if (!content) continue;
    if (role !== "user" && role !== "assistant") continue;

    turns.push({ role, content });
  }

  return turns.slice(-limit);
}

export function toWords(raw: unknown): TargetWord[] {
  if (!Array.isArray(raw)) return [];

  const words: TargetWord[] = [];
  const seen = new Set<string>();

  for (const entry of raw) {
    if (!entry || typeof entry !== "object") continue;

    const record = entry as Record<string, unknown>;
    const word = str(record.word);
    const key = word.toLowerCase();

    if (!key || seen.has(key)) continue;

    seen.add(key);
    words.push({ word, translation: str(record.translation) });

    if (words.length >= MAX_TARGET_WORDS) break;
  }

  return words;
}

export function toSummaries(raw: unknown): string[] {
  if (!Array.isArray(raw)) return [];

  return raw
    .map((entry) => str(entry))
    .filter((entry) => entry.length > 0)
    .slice(0, 2);
}

export function toCorrections(raw: unknown): Correction[] {
  if (!Array.isArray(raw)) return [];

  const corrections: Correction[] = [];

  for (const entry of raw) {
    if (!entry || typeof entry !== "object") continue;

    const record = entry as Record<string, unknown>;
    const original = str(record.original);
    const corrected = str(record.corrected);

    if (!original || !corrected) continue;

    corrections.push({
      original,
      corrected,
      suggestion: str(record.suggestion),
      explanation: str(record.explanation),
    });

    if (corrections.length >= 3) break;
  }

  return corrections;
}
