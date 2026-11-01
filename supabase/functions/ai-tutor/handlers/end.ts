import { userClient } from "../auth.ts";
import { readSettings, saveSummary } from "../db.ts";
import { fail, json } from "../http.ts";
import { chatJson } from "../llm.ts";
import { plainText } from "../parse.ts";
import { toSettings, toTurns, toWords } from "../normalize.ts";
import { targetWordBlock } from "../prompts/persona.ts";
import { SUMMARY_SYSTEM, transcriptBlock } from "../prompts/end.ts";

const SUMMARY_TURNS = 40;

export async function handleEnd(
  req: Request,
  body: Record<string, unknown>,
): Promise<Response> {
  const turns = toTurns(body.messages, SUMMARY_TURNS);

  if (!turns.some((turn) => turn.role === "user")) {
    return fail("Özetlenecek konuşma yok.", 400);
  }

  const db = userClient(req);
  const settings = body.settings
    ? toSettings(body.settings)
    : await readSettings(db);
  const words = toWords(body.targetWords);

  const system = [
    SUMMARY_SYSTEM,
    `LEARNER LEVEL: ${settings.english_level}`,
    targetWordBlock(words),
    transcriptBlock(turns),
  ].join("\n\n");

  const data = await chatJson<{ summary?: unknown }>(
    [
      { role: "system", content: system },
      { role: "user", content: "Write the memo now." },
    ],
    {
      maxTokens: 500,
      repair: (raw) => {
        const summary = plainText(raw);
        return summary ? { summary } : null;
      },
    },
  );

  const summary = typeof data.summary === "string" ? data.summary.trim() : "";
  if (!summary) throw new Error("Konuşma özeti üretilemedi.");

  await saveSummary(db, summary);

  return json({ success: true, summary });
}
