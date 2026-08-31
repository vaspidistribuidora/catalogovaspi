// buscar_do_firebase.js
//
// Busca o catalogo direto do Firestore (sem precisar do usuario baixar
// produtos.js e mandar o arquivo). Usa a mesma REST API publica que o
// admin.html usa via SDK, so que direto por HTTPS.
//
// Uso:
//   node buscar_do_firebase.js > saida.json
//   node buscar_do_firebase.js saida.json   (grava direto no arquivo)
//
// Sai um array plano de itens, no mesmo formato do produtos.json.

const PROJECT_ID = "catalogotestevaspi";
const API_KEY = "AIzaSyApBVLKgpwz75KOh7Sr7b3SWRjy1O0PVts";
const URL = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/catalogo/produtos?key=${API_KEY}`;

// Converte um "Value" do formato REST do Firestore num valor JS normal.
function fromFirestoreValue(v) {
  if (v === undefined || v === null) return null;
  if ("stringValue" in v) return v.stringValue;
  if ("integerValue" in v) return parseInt(v.integerValue, 10);
  if ("doubleValue" in v) return v.doubleValue;
  if ("booleanValue" in v) return v.booleanValue;
  if ("nullValue" in v) return null;
  if ("timestampValue" in v) return v.timestampValue;
  if ("arrayValue" in v) {
    const vals = (v.arrayValue.values || []);
    return vals.map(fromFirestoreValue);
  }
  if ("mapValue" in v) {
    const fields = v.mapValue.fields || {};
    const obj = {};
    for (const k of Object.keys(fields)) obj[k] = fromFirestoreValue(fields[k]);
    return obj;
  }
  return null;
}

async function main() {
  const res = await fetch(URL);
  if (!res.ok) {
    console.error(`Erro HTTP ${res.status} ao buscar do Firestore`);
    process.exit(1);
  }
  const doc = await res.json();
  if (!doc.fields || !doc.fields.items) {
    console.error("Documento sem campo 'items' - resposta:", JSON.stringify(doc).slice(0, 500));
    process.exit(1);
  }
  const items = fromFirestoreValue(doc.fields.items);
  const json = JSON.stringify(items);

  const outPath = process.argv[2];
  if (outPath) {
    require("fs").writeFileSync(outPath, json, { encoding: "utf8" });
    console.error(`OK - ${items.length} itens salvos em ${outPath}`);
  } else {
    process.stdout.write(json);
  }
}

main().catch(e => { console.error(e); process.exit(1); });
