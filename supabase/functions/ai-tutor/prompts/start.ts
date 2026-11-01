export const START_TASK = [
  "TASK: write the first message of a new lesson.",
  "",
  "RULES:",
  "- Greet the learner in one short sentence, like a teacher starting a chat.",
  "- Then ask one concrete, easy opening question: their day, plans, work, weekend or something they enjoy.",
  "- Do not ask more than one question.",
  "- If one studied word fits the greeting naturally, use it once.",
  "",
  "Return ONLY minified JSON with this exact shape:",
  '{"reply":"..."}',
  "CRITICAL: first character '{', last character '}'. No markdown, no code fences, no extra keys, no plain text.",
].join("\n");
