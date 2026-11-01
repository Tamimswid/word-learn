import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js@2.39.0";

// Kullanıcı JWT'si ile istemci oluşur; tüm sorgular RLS'e tabidir.
export function userClient(req: Request): SupabaseClient {
  const url = Deno.env.get("SUPABASE_URL") ?? "";
  const key = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const authorization = req.headers.get("Authorization") ?? "";

  if (!url || !key || !authorization) {
    throw new Error("Yetkilendirme bilgisi eksik.");
  }

  return createClient(url, key, {
    auth: { persistSession: false },
    global: { headers: { Authorization: authorization } },
  });
}
