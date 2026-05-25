const downloadForm = document.getElementById("downloadForm");
const downloadButton = document.getElementById("downloadButton");
const buttonText = downloadButton.querySelector(".button-text");
const buttonLoader = downloadButton.querySelector(".button-loader");
const feedback = document.getElementById("downloadFeedback");
const sessionPill = document.getElementById("sessionPill");
const sessionPillText = sessionPill.querySelector(".session-pill-text");
const assetSuggestions = document.getElementById("assetSuggestions");
const previewBody = document.getElementById("previewBody");
const quickAssets = document.getElementById("quickAssets");

const filePathValue = document.getElementById("filePathValue");
const rowsValue = document.getElementById("rowsValue");
const startValue = document.getElementById("startValue");
const endValue = document.getElementById("endValue");

let knownAssets = [];

function setLoading(isLoading) {
    downloadButton.disabled = isLoading;
    buttonText.classList.toggle("d-none", isLoading);
    buttonLoader.classList.toggle("d-none", !isLoading);
}

function setFeedback(message, type = "") {
    feedback.textContent = message;
    feedback.className = "feedback mt-3";
    if (type) {
        feedback.classList.add(type);
    }
}

function setSessionStatus(data) {
    const connected = Boolean(data?.connected);
    sessionPill.classList.toggle("is-connected", connected);

    if (!connected) {
        sessionPillText.textContent = "Sessao desconectada";
        return;
    }

    const balanceType = data.balance_type || "N/A";
    const balance = data.balance ?? "--";
    const currency = data.currency || "";
    sessionPillText.textContent = `Conectado | ${balanceType} | ${currency}${balance}`;
}

function renderPreview(rows) {
    if (!rows?.length) {
        previewBody.innerHTML = `
            <tr>
                <td colspan="6" class="empty-state">Nenhum dado baixado ainda.</td>
            </tr>
        `;
        return;
    }

    previewBody.innerHTML = rows.map((row) => `
        <tr>
            <td>${row.timestamp_utc}</td>
            <td>${row.open}</td>
            <td>${row.close}</td>
            <td>${row.min}</td>
            <td>${row.max}</td>
            <td>${row.volume}</td>
        </tr>
    `).join("");
}

function fillSummary(data) {
    filePathValue.textContent = data.file_path || "-";
    rowsValue.textContent = data.rows ?? "0";
    startValue.textContent = data.started_at || "-";
    endValue.textContent = data.ended_at || "-";
    renderPreview(data.preview || []);
}

function renderQuickAssets(assets) {
    if (!assets.length) {
        quickAssets.innerHTML = `<span class="quick-assets-empty">Nenhum ativo carregado.</span>`;
        return;
    }

    quickAssets.innerHTML = assets
        .slice(0, 18)
        .map((asset) => `<button type="button" class="quick-asset" data-symbol="${asset.symbol}">${asset.symbol}</button>`)
        .join("");
}

async function refreshSessionStatus() {
    const response = await fetch("/api/session");
    if (!response.ok) {
        window.location.href = "/";
        return;
    }

    const data = await response.json();
    setSessionStatus(data);
    if (!data.connected) {
        window.location.href = "/";
    }
}

async function loadAssets() {
    try {
        const response = await fetch("/api/market/assets?limit=160");
        if (!response.ok) {
            return;
        }

        const payload = await response.json();
        knownAssets = payload.assets || [];
        assetSuggestions.innerHTML = knownAssets
            .map((asset) => `<option value="${asset.symbol}">${asset.symbol} - ${asset.category}</option>`)
            .join("");
        renderQuickAssets(knownAssets);
    } catch (error) {
        console.error(error);
        renderQuickAssets([]);
    }
}

quickAssets.addEventListener("click", (event) => {
    const target = event.target;
    if (!(target instanceof HTMLElement)) {
        return;
    }

    const symbol = target.dataset.symbol;
    if (!symbol) {
        return;
    }

    downloadForm.asset.value = symbol;
    setFeedback(`Ativo selecionado: ${symbol}`, "");
});

downloadForm.addEventListener("submit", async (event) => {
    event.preventDefault();

    const asset = downloadForm.asset.value.trim().toUpperCase();
    const intervalSeconds = Number(downloadForm.interval.value);
    const count = Number(downloadForm.count.value);

    if (!asset) {
        setFeedback("Informe o ativo para baixar os candles.", "is-error");
        return;
    }

    if (!Number.isInteger(count) || count < 10 || count > 5000) {
        setFeedback("Quantidade deve ficar entre 10 e 5000 candles.", "is-error");
        return;
    }

    if (knownAssets.length) {
        const exists = knownAssets.some((item) => item.symbol === asset);
        if (!exists) {
            setFeedback("Ativo nao encontrado no catalogo aberto da IQ Option. Escolha um ativo sugerido.", "is-error");
            return;
        }
    }

    try {
        setLoading(true);
        setFeedback("Baixando candles historicos...");

        const response = await fetch("/api/market/download", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ asset, interval_seconds: intervalSeconds, count }),
        });

        const payload = await response.json();
        setFeedback(payload.message || "Processo concluido.", response.ok ? "is-success" : "is-error");

        if (response.ok) {
            fillSummary(payload.data || {});
            downloadForm.asset.value = payload.data?.asset || asset;
        }
    } catch (error) {
        console.error(error);
        setFeedback("Falha ao baixar os dados do ativo.", "is-error");
    } finally {
        setLoading(false);
    }
});

refreshSessionStatus();
loadAssets();
