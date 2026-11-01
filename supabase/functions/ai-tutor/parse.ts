// Modelin döndürdüğü metinden ilk JSON nesnesini çıkarır.
// Bulamazsa fırlatmak yerine null döner; çağıran taraf tamir edebilir.
export function tryExtractJson(raw: string): unknown {
  const cleaned = raw
    .replace(/```json/gi, "")
    .replace(/```/g, "")
    .trim();

  if (!cleaned) return null;

  const start = cleaned.indexOf("{");
  if (start < 0) return null;

  // Parantez dengesini tarayıp nesnenin gerçek sonunu bul.
  let depth = 0;
  let inString = false;
  let escaped = false;
  let end = -1;

  for (let index = start; index < cleaned.length; index += 1) {
    const char = cleaned[index];

    if (escaped) {
      escaped = false;
      continue;
    }
    if (char === "\\") {
      escaped = true;
      continue;
    }
    if (char === '"') {
      inString = !inString;
      continue;
    }
    if (inString) continue;

    if (char === "{") depth += 1;
    if (char === "}") {
      depth -= 1;
      if (depth === 0) {
        end = index;
        break;
      }
    }
  }

  if (end < 0) return null;

  const candidate = cleaned.slice(start, end + 1);

  // Sık görülen bozukluklar: kapama öncesi virgüller.
  const repairs = [candidate, candidate.replace(/,\s*([}\]])/g, "$1")];
  for (const attempt of repairs) {
    try {
      return JSON.parse(attempt);
    } catch {
      // Sonraki onarımı dene.
    }
  }

  return null;
}

// JSON içermeyen model çıktısından temiz bir düz metin üretir.
export function plainText(raw: string): string {
  return raw
    .replace(/```json/gi, "")
    .replace(/```/g, "")
    .replace(/^\s*(json|output|answer|reply)\s*:\s*/i, "")
    .trim();
}
