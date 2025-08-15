const SPREADSHEET_ID = '1KvKSxkKIv28pb0swoSyRFjwn9IV3OrZtxBCnz0kHUR0';
const ABA_ADO = 'adolescentes';
const ABA_PRE = 'presencas';

function _getSpreadsheet() {
  try {
    const active = SpreadsheetApp.getActiveSpreadsheet();
    if (active) return active;
  } catch (_) {}
  return SpreadsheetApp.openById(SPREADSHEET_ID);
}

function _getSheetOrFail(ss, name) {
  const sh = ss.getSheetByName(name);
  if (!sh) {
    const existentes = ss.getSheets().map(s => s.getName()).join(', ');
    throw new Error(`Aba "${name}" não encontrada. Abas existentes: ${existentes}`);
  }
  return sh;
}

// Garante que a aba 'presencas' tenha as colunas esperadas; cria cabeçalho se faltar
function _ensurePresencasHeader(sh) {
  const headerEsperado = ['data_culto', 'id_adolescente', 'presente', 'registrado_por', 'timestamp', 'tipo_evento'];
  const range = sh.getRange(1, 1, 1, sh.getLastColumn() || headerEsperado.length);
  const valores = range.getValues()[0].map(v => String(v).trim());
  const vazio = valores.every(v => v === '');

  if (vazio) {
    // Planilha nova sem cabeçalho
    sh.getRange(1, 1, 1, headerEsperado.length).setValues([headerEsperado]);
    return;
  }

  // Se o cabeçalho não bate, tenta atualizar (sem bagunçar quem já usa)
  const faltaTipoEvento = valores.indexOf('tipo_evento') === -1;
  if (faltaTipoEvento) {
    sh.getRange(1, valores.length + 1).setValue('tipo_evento');
  }
}

function doGet(e) {
  const action = (e && e.parameter && e.parameter.action || '').trim();
  if (action === 'ping') return respostaJson({ ok: true, via: 'GET' }, 200);
  if (action === 'getAdolescentes') return getAdolescentes();
  return respostaJson({ error: 'action not found' }, 404);
}

function doPost(e) {
  const action = (e && e.parameter && e.parameter.action || '').trim();
  if (action === 'ping') return respostaJson({ ok: true, via: 'POST' }, 200);
  if (action === 'registrarPresenca') {
    const p = e.parameter || {};
    const id = (p.id || '').trim();
    const data = (p.data || '').trim();
    const por = (p.registrado_por || 'App').trim();
    const tipo = (p.tipo_evento || '').trim(); // <- NOVO

    if (!id || !data) return respostaJson({ error: 'id e data obrigatórios' }, 400);
    return registrarPresenca(id, data, por, tipo);
  }
  return respostaJson({ error: 'action not found' }, 404);
}

function getAdolescentes() {
  const ss = _getSpreadsheet();
  const sh = _getSheetOrFail(ss, ABA_ADO);

  const vals = sh.getDataRange().getValues();
  if (!vals || vals.length === 0) return respostaJson([], 200);

  const header = vals.shift();
  const idx = {
    id: header.findIndex(h => String(h).toLowerCase().trim() === 'id'),
    nome: header.findIndex(h => String(h).toLowerCase().trim() === 'nome'),
    data_nascimento: header.findIndex(h => String(h).toLowerCase().trim() === 'data_nascimento'),
    telefone: header.findIndex(h => String(h).toLowerCase().trim() === 'telefone'),
  };

  if (idx.id < 0 || idx.nome < 0) {
    throw new Error('Cabeçalhos obrigatórios não encontrados na aba "adolescentes". Esperado: id, nome, data_nascimento, telefone');
  }

  const out = vals
    .filter(r => String(r[idx.id] || '').trim() !== '')
    .map(r => ({
      id: String(r[idx.id] || '').trim(),
      nome: String(r[idx.nome] || '').trim(),
      data_nascimento: r[idx.data_nascimento] ? _fmtData(r[idx.data_nascimento]) : '',
      telefone: String(r[idx.telefone] || '').trim(),
    }));

  return respostaJson(out, 200);
}

function registrarPresenca(id, dataCulto, registradoPor, tipoEvento) {
  const ss = _getSpreadsheet();
  const sh = _getSheetOrFail(ss, ABA_PRE);

  _ensurePresencasHeader(sh);

  // data_culto | id_adolescente | presente | registrado_por | timestamp | tipo_evento
  const agora = new Date();
  sh.appendRow([dataCulto, id, true, registradoPor, agora, tipoEvento || '']);

  return respostaJson({ ok: true }, 200);
}

function _fmtData(valor) {
  if (Object.prototype.toString.call(valor) === '[object Date]') {
    return Utilities.formatDate(valor, Session.getScriptTimeZone(), 'yyyy-MM-dd');
  }
  return String(valor).trim();
}

function respostaJson(obj, status) {
  return ContentService
    .createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}
