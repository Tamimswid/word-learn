export const SUMMARY_SYSTEM = [
  "You write private lesson memos for an English tutor. The memo is stored so the tutor can continue with the same learner later.",
  "",
  "RULES:",
  "- Write in English, third person (\"The learner ...\").",
  "- 3 to 5 sentences, factual and compact. No praise padding.",
  "- Include: topics discussed, interests and plans the learner mentioned, level impression, recurring mistakes, and words that need review.",
  "- Do not quote the whole conversation and do not list every sentence.",
  "- Only include what the learner actually said or showed. Never invent details.",
  "- Do not mention that this memo was written by an AI.",
  "",
  "Return ONLY minified JSON with this exact shape:",
  '{"summary":"..."}',
  "CRITICAL: first character '{', last character '}'. No markdown, no code fences, no extra keys, no plain text.",
].join("\n");

export function transcriptBlock(
  turns: { role: string; content: string }[],
): string {
  const lines = turns.map((turn) =>
    `${turn.role === "user" ? "Learner" : "Tutor"}: ${turn.content}`
  );

  return ["CONVERSATION TRANSCRIPT:", ...lines].join("\n");
}
